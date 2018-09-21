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
        connection: RTCPeerConnection,
        event: PeerEvent,
        localID: String,
        remoteID: String,
        connectionID: String,
        stats: Array<RTCLegacyStatsReport>)
}
