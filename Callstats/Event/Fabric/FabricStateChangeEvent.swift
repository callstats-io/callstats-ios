//
//  FabricStateChangeEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/3/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 Whenever the ICE connection state changes or ICE gathering state changes or signaling state changes then this event should be sent.
 */
class FabricStateChangeEvent: FabricEvent, Event, Encodable {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    
    let remoteID: String
    let connectionID: String
    let prevState: String
    let newState: String
    let changedState: String
    
    init(remoteID: String, connectionID: String, prevState: String, newState: String, changedState: String) {
        self.remoteID = remoteID
        self.connectionID = connectionID
        self.prevState = prevState
        self.newState = newState
        self.changedState = changedState
    }
    
    override func path() -> String {
        return super.path() + "/statechange"
    }
}
