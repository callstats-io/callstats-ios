//
//  Callstats.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 9/21/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation
import WebRTC

/**
 Entry point for sending WebRTC stats to callstats.io
 */
public class Callstats: NSObject {
    
    static var dependency = CallstatsInjector()
    
    private let localID: String
    private let username: String?
    private let clientVersion: String?
    private let configuration: CallstatsConfig
    private let sender: EventSender
    private let systemStatus: SystemStatusProvider
    
    // timers
    private var aliveTimer: Timer?
    private var systemStatsTimer: Timer?
    
    // event manager for each connection
    internal var eventManagers: [String: EventManager] = [:]
    
    public init(
        appID: String,
        localID: String,
        deviceID: String,
        jwt: String,
        username: String? = nil,
        clientVersion: String? = nil,
        configuration: CallstatsConfig = CallstatsConfig())
    {
        self.localID = localID
        self.username = username
        self.clientVersion = clientVersion
        self.configuration = configuration
        
        sender = Callstats.dependency.eventSender(appID: appID, localID: localID, deviceID: deviceID)
        systemStatus = Callstats.dependency.systemStatusProvider()
        
        sender.send(event: TokenRequest(code: jwt, clientID: "\(localID)@\(appID)"))
    }
    
    /**
     Start the user session when creating conference call.
     This will start sending keep alive as well.
     - Parameter confID: local conference identifier for this call session
     */
    public func startSession(confID: String) {
        sender.send(event: UserJoinEvent(confID: confID, appVersion: clientVersion))
        if let u = username { sender.send(event: UserDetailsEvent(userName: u)) }
        startKeepAlive()
        startSendingSystemStats()
    }
    
    /**
     Stop the current session and stop the keep alive.
     */
    public func stopSession() {
        stopSendingSystemStats()
        stopKeepAlive()
        sender.send(event: UserLeftEvent())
    }
    
    /**
     Create new connection. Call this before [reportEvent]
     - Parameter connection: reporting PeerConnection object
     - Parameter remoteUserID: recipient's userID
     */
    public func addNewFabric(connection: RTCPeerConnection, remoteUserID: String) {
        let csConnection = CSConnection(peerConnection: connection)
        addNewFabric(connection: csConnection, remoteID: remoteUserID)
    }
    
    internal func addNewFabric(connection: Connection, remoteID: String) {
        if eventManagers.keys.contains(remoteID) { return }
        eventManagers[remoteID] = Callstats.dependency.eventManager(
            sender: sender,
            localID: localID,
            remoteID: remoteID,
            connection: connection,
            config: configuration)
    }
    
    /**
     Report event for specific peer
     - Parameter remoteUserID: recipient's userID
     - Parameter event: event to be sent
     */
    public func reportEvent(remoteUserID: String, event: CSPeerEvent) {
        eventManagers[remoteUserID]?.process(event: event)
    }
    
    /**
     Report application event
     */
    public func reportEvent(event: CSAppEvent) {
        switch event {
        case is CSDominantSpeakerEvent: sender.send(event: DominantSpeakerEvent())
        case let e as CSDeviceConnectEvent: sender.send(event: DeviceEvent(eventType: .connected, mediaDeviceList: e.devices))
        case let e as CSDeviceActiveEvent: sender.send(event: DeviceEvent(eventType: .active, mediaDeviceList: e.devices))
        default: ()
        }
    }
    
    /**
     Report error
     */
    public func reportError(type: ErrorType, message: String? = nil, stack: String? = nil) {
        let reason: String
        switch type {
        case .mediaPermission: reason = "MediaPermissionError"
        case .sdpGeneration: reason = "SDPGenerationError"
        case .negotiation: reason = "NegotiationFailure"
        case .signaling: reason = "SignalingError"
        }
        let event = FabricSetupFailedEvent(reason: reason)
        event.message = message
        event.stack = stack
        sender.send(event: event)
    }
    
    /**
     Log application event
     - Parameter message: message to be logged
     - Parameter level: level of this log message
     - Parameter type: type of message content
     */
    public func log(message: String, level: LoggingLevel = .info, type: LoggingType = .text) {
        sender.send(event: LogEvent(level: level, message: message, messageType: type))
    }
    
    /**
     Give feedback on this conference call
     - Parameter rating: Rating from 1 to 5
     - Parameter comment: comment from participant
     - Parameter audioQuality: Rating from 1 to 5
     - Parameter videoQuality: Raring from 1 to 5
     - Parameter remoteUserID: Non-empty remoteID means that the feedback was given explicitly
     about the connection between these two parties. Otherwise it is regarded as general conference feedback.
     */
    public func sendUserFeedback(
        rating: Int,
        comment: String? = nil,
        audioQuality: Int? = nil,
        videoQuality: Int? = nil,
        remoteUserID: String? = nil)
    {
        let info = Feedback(
            overallRating: rating,
            remoteID: remoteUserID,
            videoQualityRating: videoQuality,
            audioQualityRating: audioQuality,
            comments: comment)
        sender.send(event: FeedbackEvent(feedback: info))
    }
    
    // MARK:- Timers
    
    private func startKeepAlive() {
        stopKeepAlive()
        let period = configuration.keepAlivePeriod
        aliveTimer = Timer.scheduledTimer(
            timeInterval: period,
            target: self,
            selector: #selector(self.sendKeepAlive),
            userInfo: nil,
            repeats: true)
    }
    
    @objc private func sendKeepAlive() {
        sender.send(event: UserAliveEvent())
    }
    
    private func stopKeepAlive() {
        aliveTimer?.invalidate()
        aliveTimer = nil
    }
    
    private func startSendingSystemStats() {
        stopSendingSystemStats()
        let period = configuration.systemStatsSubmissionPeriod
        systemStatsTimer = Timer.scheduledTimer(
            timeInterval: period,
            target: self,
            selector: #selector(self.sendSystemStats),
            userInfo: nil,
            repeats: true)
    }
    
    @objc private func sendSystemStats() {
        let stats = SystemStatusStats()
        stats.cpuLevel = systemStatus.cpuLevel()
        stats.batteryLevel = systemStatus.batteryLevel()
        stats.memoryAvailable = systemStatus.availableMemory()
        stats.memoryUsage = systemStatus.usageMemory()
        stats.threadCount = systemStatus.threadCount()
        if stats.isValid() {
            sender.send(event: stats)
        }
    }
    
    private func stopSendingSystemStats() {
        systemStatsTimer?.invalidate()
        systemStatsTimer = nil
    }
}
