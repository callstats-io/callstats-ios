//
//  IceConnectionDisruptEndEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/16/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 When ICE connection disruption ends, this event should be submitted
 */
class IceConnectionDisruptEndEvent: IceEvent, Event, Encodable {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    
    let remoteID: String
    let connectionID: String
    let delay: Int64
    
    let eventType = "iceConnectionDisruptionEnd"
    let currIceConnectionState = "checking"
    let prevIceConnectionState = "disconnected"
    
    init(remoteID: String, connectionID: String, delay: Int64) {
        self.remoteID = remoteID
        self.connectionID = connectionID
        self.delay = delay
    }
}
