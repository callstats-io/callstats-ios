//
//  Interceptor.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 9/21/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation
import WebRTC

/**
 The interceptor to process the event sent by app
 */
protocol Interceptor {
    
    /**
     Process the incoming type and data stats
     */
    func process(
        connection: Connection,
        event: PeerEvent,
        localID: String,
        remoteID: String,
        connectionID: String,
        stats: [WebRTCStats]) -> [Event]
}

/**
 Connection protocol which provide info that Interceptor might need
 */
protocol Connection {
    func localSessionDescription() -> String?
    func remoteSessionDescription() -> String?
}

/**
 WebRTC stats protocol which provide the stats interceptor needs
 */
protocol WebRTCStats {
    var id: String { get }
    var type: String { get }
    var values: [String: String] { get }
    var timestamp: Double { get }
}

/**
 Connection wrapper implementation
 */
class CSConnection: Connection {
    let peerConnection: RTCPeerConnection
    
    init(peerConnection: RTCPeerConnection) {
        self.peerConnection = peerConnection
    }
    
    func localSessionDescription() -> String? {
        return peerConnection.localDescription?.sdp
    }
    
    func remoteSessionDescription() -> String? {
        return peerConnection.remoteDescription?.sdp
    }
}

/**
 Stats wrapper implementation
 */
class CSWebRTCStats: WebRTCStats {
    
    let id: String
    let type: String
    let timestamp: Double
    let values: [String : String]
    
    init(stats: RTCLegacyStatsReport) {
        id = stats.reportId
        type = stats.type
        timestamp = stats.timestamp
        values = stats.values
    }
}
