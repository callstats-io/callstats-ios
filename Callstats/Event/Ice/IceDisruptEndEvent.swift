//
//  IceDisruptEndEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/16/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 When ICE disruption ends, this event should be submitted
 */
class IceDisruptEndEvent: IceEvent, Event, Encodable {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    
    let remoteID: String
    let connectionID: String
    let currIceCandidatePair: IceCandidatePair
    let prevIceCandidatePair: IceCandidatePair
    let currIceConnectionState: String
    let delay: Int64
    
    let eventType = "iceDisruptionEnd"
    let prevIceConnectionState = "disconnected"
    
    init(
        remoteID: String,
        connectionID: String,
        currIceCandidatePair: IceCandidatePair,
        prevIceCandidatePair: IceCandidatePair,
        currIceConnectionState: String,
        delay: Int64)
    {
        self.remoteID = remoteID
        self.connectionID = connectionID
        self.currIceCandidatePair = currIceCandidatePair
        self.prevIceCandidatePair = prevIceCandidatePair
        self.currIceConnectionState = currIceConnectionState
        self.delay = delay
    }
}
