//
//  IceFailedEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/16/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 When ICE fails, this event should be submitted
 */
class IceFailedEvent: IceEvent, Event, Encodable {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    
    let remoteID: String
    let connectionID: String
    let prevIceConnectionState: String
    let delay: Int64
    
    let eventType = "iceFailed"
    let currIceConnectionState = "failed"
    
    var localIceCandidates: [IceCandidate] = []
    var remoteIceCandidates: [IceCandidate] = []
    var iceCandidatePairs: [IceCandidatePair] = []
    
    init(
        remoteID: String,
        connectionID: String,
        prevIceConnectionState: String,
        delay: Int64)
    {
        self.remoteID = remoteID
        self.connectionID = connectionID
        self.prevIceConnectionState = prevIceConnectionState
        self.delay = delay
    }
}
