//
//  IceRestartEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/16/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 When ICE restarts, this event should be submitted
 */
class IceRestartEvent: IceEvent, Event, Encodable {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    
    let remoteID: String
    let connectionID: String
    let prevIceCandidatePair: IceCandidatePair
    let prevIceConnectionState: String
    
    let eventType = "iceRestarted"
    let currIceConnectionState = "new"
    
    init(
        remoteID: String,
        connectionID: String,
        prevIceCandidatePair: IceCandidatePair,
        prevIceConnectionState: String)
    {
        self.remoteID = remoteID
        self.connectionID = connectionID
        self.prevIceCandidatePair = prevIceCandidatePair
        self.prevIceConnectionState = prevIceConnectionState
    }
}
