//
//  IceCandidate.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 9/28/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation
import WebRTC

/**
 ICE candidate info
 */
struct IceCandidate: Encodable {
    let id: String
    let type: String
    let ip: String
    let port: Int
    let candidateType: String
    let transport: String
    
    init(stats: WebRTCStats) {
        id = stats.id
        type = stats.type
        ip = stats.values["ipAddress"] ?? ""
        port = Int(stats.values["portNumber"] ?? "0") ?? 0
        candidateType = stats.values["candidateType"] ?? ""
        transport = stats.values["transport"] ?? ""
    }
}
