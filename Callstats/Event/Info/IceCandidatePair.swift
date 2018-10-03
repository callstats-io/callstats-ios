//
//  IceCandidatePair.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/3/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation
import WebRTC

/**
 ICE candidate pair info for some event
 */
struct IceCandidatePair: Encodable {
    let id: String
    let localCandidateId: String
    let remoteCandidateId: String
    let state: String
    let priority: Int
    let nominated: Bool
    
    init(stats: RTCLegacyStatsReport) {
        // Please note that this stats is not updated yet and might not be able to send correct value
        self.id = stats.reportId
        self.localCandidateId = stats.values["localCandidateId"] ?? ""
        self.remoteCandidateId = stats.values["remoteCandidateId"] ?? ""
        
        // `succeeded` will be sent if connection is active, `waiting` otherwise
        let isActive = stats.values["googActiveConnection"] == "true"
        let state = isActive ? "succeeded" : "waiting"
        self.state = state
        self.nominated = isActive
        
        // no priority available
        self.priority = 0
    }
}
