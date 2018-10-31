//
//  SsrcInterceptor.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/23/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 Interceptor to send SSRC map after connected
 */
class SsrcInterceptor: Interceptor {
    
    private var connected = false
    
    func process(
        connection: Connection,
        event: PeerEvent,
        localID: String,
        remoteID: String,
        connectionID: String,
        stats: [WebRTCStats]) -> [Event]
    {
        // only continue if the event is ice and stream added
        guard event is CSIceConnectionChangeEvent || event is CSAddStreamEvent else { return [] }
        // if event is ice connection change but already connected, do not send
        if event is CSIceConnectionChangeEvent && connected { return [] }
        // if event is ice connection change but not connect yet, set connected
        if let e = event as? CSIceConnectionChangeEvent, e.state == .connected { connected = true }
        
        let ssrcs = stats.ssrcs(connection: connection, localID: localID, remoteID: remoteID)
        if !ssrcs.isEmpty {
            let ssrcEvent = SsrcEvent(remoteID: remoteID, connectionID: connectionID)
            ssrcEvent.ssrcData.append(contentsOf: ssrcs)
            return [ssrcEvent]
        }
        return []
    }
}
