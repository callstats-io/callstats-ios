//
//  RTCStats.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/6/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation
import WebRTC

extension Array where Element == WebRTCStats {
    
    /**
     Extract the selected candidate pair ID
     - Returns: selected candidate pair ID
     */
    func selectedCandidatePairId() -> String? {
        return filter { $0.type == "googCandidatePair" }
            .first { $0.values["googActiveConnection"] == "true" }?
            .id
    }
    
    /**
     Extract all candidate pairs from RTCStats
     - Returns: list of IceCandidatePair
     */
    func candidatePairs() -> [IceCandidatePair] {
        return filter { $0.type == "googCandidatePair" }
            .map { IceCandidatePair.init(stats: $0) }
    }
    
    /**
     Extract all local ICE candidate from RTCStats
     - Returns: list of [IceCandidate]
     */
    func localCandidates() -> [IceCandidate] {
        return filter { $0.type == "localcandidate" }
            .map { IceCandidate.init(stats: $0) }
    }
    
    /**
     Extract all remote ICE candidate from RTCStats
     - Returns: list of [IceCandidate]
     */
    func remoteCandidates() -> [IceCandidate] {
        return filter { $0.type == "remotecandidate" }
            .map { IceCandidate.init(stats: $0) }
    }
    
    /**
     Extract all SSRC details from stats and PeerConnection
     */
    func ssrcs(connection: Connection, localID: String, remoteID: String) -> [Ssrc] {
        return filter { $0.type == "ssrc" }
            .compactMap { Ssrc(stats: $0, connection: connection, localId: localID, remoteId: remoteID) }
    }
}
