//
//  StatsInterceptor.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/21/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 Interceptor to handle stats submission events
 */
class StatsInterceptor: Interceptor {
    
    private var startTimestamp: Int64 = 0
    private var lastSentTimestamp: Int64 = 0
    private var statCaches: [String: CsioCache] = [:]
    
    func process(
        connection: Connection,
        event: PeerEvent,
        localID: String,
        remoteID: String,
        connectionID: String,
        stats: [WebRTCStats]) -> [Event]
    {
        // save start time
        if let event = event as? CSIceConnectionChangeEvent,
            startTimestamp == 0,
            event.state == .connected
        {
            startTimestamp = Date().currentTimeInMillis
        }
        
        guard event is CSStatsEvent else { return [] }
        let currentTimestamp = Date().currentTimeInMillis
        
        let statsList: [[String: String]] = stats.map {
            var dict = [
                "reportId": $0.id,
                "timestamp": String($0.timestamp),
                "type": $0.type
            ]
            dict.merge($0.values) { current, _ in current }
            return dict
        }
        
        // TODO: add csio stats
        
        // update states & create stats event
        lastSentTimestamp = currentTimestamp
        return [
            ConferenceStats(
                remoteID: remoteID,
                connectionID: connectionID,
                stats: statsList)
        ]
    }
}

// cache values for calculations
private class CsioCache {
    var rttSum = 0.0
    var rttCount = 0
    var jitterSum = 0.0
    var jitterCount = 0
    var bytesSent: Int64 = 0
    var bytesReceived: Int64 = 0
    var lostPackets: Int64 = 0
    var receivedPackets: Int64 = 0
}
