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
        
        var statsList: [[String: String]] = stats.map {
            var dict = [
                "reportId": $0.id,
                "timestamp": String($0.timestamp),
                "type": $0.type
            ]
            dict.merge($0.values) { current, _ in current }
            return dict
        }
        
        // add csio stats
        for index in 0..<statsList.count {
            var stat = statsList[index]
            guard let type = stat["type"], type == "ssrc" else { continue }
            // create cache if not exist
            guard let id = stat["reportId"] else { continue }
            if !statCaches.keys.contains(id) { statCaches[id] = CsioCache() }
            guard let cache = statCaches[id] else { continue }
            
            sendCsioAvgBRKbps(stat: &statsList[index], currentTimestamp: currentTimestamp)
            sendCsioIntBRKbps(stat: &statsList[index], cache: cache, currentTimestamp: currentTimestamp)
            
            // outbound
            if id.contains("send") {
                sendCsioAvgRtt(stat: &statsList[index], cache: cache)
                sendCsioIntMs(stat: &statsList[index], currentTimestamp: currentTimestamp)
                sendCsioTimeElapseMs(stat: &statsList[index], currentTimestamp: currentTimestamp)
            } else if id.contains("recv") {
                sendCsioAvgJitter(stat: &statsList[index], cache: cache)
                sendCsioIntFLAndIntPktLoss(stat: &statsList[index], cache: cache)
            }
        }
        
        // update states & create stats event
        lastSentTimestamp = currentTimestamp
        return [
            ConferenceStats(
                remoteID: remoteID,
                connectionID: connectionID,
                stats: statsList)
        ]
    }
    
    private func sendCsioAvgRtt(stat: inout [String: String], cache: CsioCache) {
        guard let str = stat["googRtt"] else { return }
        guard let rtt = Int64(str) else { return }
        cache.rttCount += 1
        cache.rttSum += rtt
        stat["csioAvgRtt"] = String(cache.rttSum / cache.rttCount)
    }
    
    private func sendCsioAvgBRKbps(stat: inout [String: String], currentTimestamp: Int64) {
        guard startTimestamp != 0 else { return }
        guard let value = stat["bytesSent"] ?? stat["bytesReceived"] else { return }
        guard let bytes = Int64(value) else { return }
        stat["csioAvgBRKbps"] = String((bytes * 8) / (currentTimestamp - startTimestamp))
    }
    
    private func sendCsioIntBRKbps(stat: inout [String: String], cache: CsioCache, currentTimestamp: Int64) {
        guard lastSentTimestamp != 0 else { return }
        var cacheVal: Int64 = 0
        let isSent = stat.keys.contains("bytesSent")
        guard let value = isSent ? stat["bytesSent"] : stat["bytesReceived"] else { return }
        guard let bytes = Int64(value) else { return }
        cacheVal = isSent ? cache.bytesSent : cache.bytesReceived
        if isSent {
            cache.bytesSent = bytes
        } else {
            cache.bytesReceived = bytes
        }
        stat["csioIntBRKbps"] = String((bytes - cacheVal) * 8 / (currentTimestamp - lastSentTimestamp))
    }
    
    private func sendCsioIntMs(stat: inout [String: String], currentTimestamp: Int64) {
        guard lastSentTimestamp != 0 else { return }
        stat["csioIntMs"] = String(currentTimestamp - lastSentTimestamp)
    }
    
    private func sendCsioTimeElapseMs(stat: inout [String: String], currentTimestamp: Int64) {
        guard startTimestamp != 0 else { return }
        stat["csioTimeElapseMs"] = String(currentTimestamp - startTimestamp)
    }
    
    private func sendCsioAvgJitter(stat: inout [String: String], cache: CsioCache) {
        guard let str = stat["googJitterReceived"] else { return }
        guard let jitter = Int64(str) else { return }
        cache.jitterCount += 1
        cache.jitterSum += jitter
        stat["csioAvgJitter"] = String(cache.jitterSum / cache.jitterCount)
    }
    
    private func sendCsioIntFLAndIntPktLoss(stat: inout [String: String], cache: CsioCache) {
        guard let packetsLostStr = stat["packetsLost"] else { return }
        guard let packetsReceivedStr = stat["packetsReceived"] else { return }
        guard let currentLostPackets = Int64(packetsLostStr) else { return }
        guard let currentReceivedPackets = Int64(packetsReceivedStr) else { return }
        let intLostPackets = currentLostPackets - cache.lostPackets
        let intReceivedPackets = currentReceivedPackets - cache.receivedPackets
        stat["csioIntFL"] = String(intLostPackets / (intLostPackets + intReceivedPackets))
        stat["csioIntPktLoss"] = String(intLostPackets)
        cache.lostPackets = currentLostPackets
        cache.receivedPackets = currentReceivedPackets
    }
}

// cache values for calculations
private class CsioCache {
    var rttSum: Int64 = 0
    var rttCount: Int64 = 0
    var jitterSum: Int64 = 0
    var jitterCount: Int64 = 0
    var bytesSent: Int64 = 0
    var bytesReceived: Int64 = 0
    var lostPackets: Int64 = 0
    var receivedPackets: Int64 = 0
}
