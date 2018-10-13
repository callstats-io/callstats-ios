//
//  Callstats.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 9/21/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

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
    
    // timers
    private var aliveTimer: Timer?
    private var systemStatsTimer: Timer?
    
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
        
    }
    
    private func stopSendingSystemStats() {
        systemStatsTimer?.invalidate()
        systemStatsTimer = nil
    }
}
