//
//  IceConnectionDisruptStartEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/16/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 When ICE connection disruption starts, this event should be submitted
 */
class IceConnectionDisruptStartEvent: IceEvent, Event, Encodable {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    
    let remoteID: String
    let connectionID: String
    
    let eventType = "iceConnectionDisruptionStart"
    let currIceConnectionState = "disconnected"
    let prevIceConnectionState = "checking"
    
    init(remoteID: String, connectionID: String) {
        self.remoteID = remoteID
        self.connectionID = connectionID
    }
}
