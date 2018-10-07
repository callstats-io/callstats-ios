//
//  FabricTransportChangeEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/3/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 Whenever the fabric transport changes this event should be called.
 */
class FabricTransportChangeEvent: FabricEvent {
    
    let remoteID: String
    let connectionID: String
    let currIceCandidatePair: IceCandidatePair
    let prevIceCandidatePair: IceCandidatePair
    let currIceConnectionState: String
    let prevIceConnectionState: String
    let delay: Int64
    
    var localIceCandidates: [IceCandidate] = []
    var remoteIceCandidates: [IceCandidate] = []
    
    /// "turn/udp" "turn/tcp" "turn/tls"
    var relayType: String?
    
    init(
        remoteID: String,
        connectionID: String,
        currIceCandidatePair: IceCandidatePair,
        prevIceCandidatePair: IceCandidatePair,
        currIceConnectionState: String,
        prevIceConnectionState: String,
        delay: Int64)
    {
        self.remoteID = remoteID
        self.connectionID = connectionID
        self.currIceCandidatePair = currIceCandidatePair
        self.prevIceCandidatePair = prevIceCandidatePair
        self.currIceConnectionState = currIceConnectionState
        self.prevIceConnectionState = prevIceConnectionState
        self.delay = delay
    }
}
