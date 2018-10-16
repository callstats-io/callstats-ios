//
//  IceDisruptStartEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/16/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 When ICE disruption starts, this event should be submitted
 */
class IceDisruptStartEvent: IceEvent, Event, Encodable {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    
    let remoteID: String
    let connectionID: String
    let currIceCandidatePair: IceCandidatePair
    let prevIceConnectionState: String
    
    let eventType = "iceDisruptionStart"
    let currIceConnectionState = "disconnected"
    
    init(
        remoteID: String,
        connectionID: String,
        currIceCandidatePair: IceCandidatePair,
        prevIceConnectionState: String)
    {
        self.remoteID = remoteID
        self.connectionID = connectionID
        self.currIceCandidatePair = currIceCandidatePair
        self.prevIceConnectionState = prevIceConnectionState
    }
}
