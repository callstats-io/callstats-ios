//
//  SdpInterceptor.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/15/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 Interceptor to send sdp events
 */
class SdpInterceptor: Interceptor {
    
    private var connected = false
    
    func process(
        connection: Connection,
        event: PeerEvent,
        localID: String,
        remoteID: String,
        connectionID: String,
        stats: [WebRTCStats]) -> [Event]
    {
        guard !connected else { return [] }
        guard let event = event as? CSIceConnectionChangeEvent else { return [] }
        guard event.state == .connected else { return [] }
        connected = true
        let sdpEvent = SdpEvent(remoteID: remoteID, connectionID: connectionID)
        sdpEvent.localSDP = connection.localSessionDescription()
        sdpEvent.remoteSDP = connection.remoteSessionDescription()
        return [sdpEvent]
    }
}
