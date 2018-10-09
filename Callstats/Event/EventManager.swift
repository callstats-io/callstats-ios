//
//  EventManager.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/7/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 Manager than handle the events from WebRTC and Application
 */
protocol EventManager {
    func process(event: PeerEvent)
}

final class EventManagerImpl: EventManager {
    
    private let sender: EventSender
    private let localID: String
    private let remoteID: String
    private let connection: Connection
    private let config: CallstatsConfig
    private let interceptors: [Interceptor]
    private let connectionID: String
    
    private var statsTimer: Timer?
    
    init(
        sender: EventSender,
        localID: String,
        remoteID: String,
        connection: Connection,
        config: CallstatsConfig,
        interceptors: [Interceptor])
    {
        self.sender = sender
        self.localID = localID
        self.remoteID = remoteID
        self.connection = connection
        self.config = config
        self.interceptors = interceptors
        self.connectionID = String(Date().currentTimeInMillis)
    }
    
    func process(event: PeerEvent) {
        connection.getStats { [weak self] report in
            guard let self = self else { return }
            self.interceptors.forEach { interceptor in
                let events = interceptor.process(
                    connection: self.connection,
                    event: event,
                    localID: self.localID,
                    remoteID: self.remoteID,
                    connectionID: self.connectionID,
                    stats: report)
                events.forEach {
                    self.sender.send(event: $0)
                    if $0 is FabricSetupEvent { self.startStatsTimer() }
                    if $0 is FabricTerminatedEvent { self.stopStatsTimer() }
                }
            }
        }
    }
    
    // MARK: - Timer
    
    private func startStatsTimer() {
        stopStatsTimer()
        let period = config.statsSubmissionPeriod
        statsTimer = Timer.scheduledTimer(
            timeInterval: period,
            target: self,
            selector: #selector(self.statsTimerRun),
            userInfo: nil,
            repeats: true)
    }
    
    @objc func statsTimerRun() {
        process(event: CSStatsEvent())
    }
    
    private func stopStatsTimer() {
        statsTimer?.invalidate()
        statsTimer = nil
    }
}
