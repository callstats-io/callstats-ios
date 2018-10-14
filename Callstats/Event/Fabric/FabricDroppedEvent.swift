//
//  FabricDroppedEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/4/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 Whenever the fabric is dropped, this should be notified.
 */
class FabricDroppedEvent: FabricEvent, Event, Encodable {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    
    let remoteID: String
    let connectionID: String
    let currIceCandidatePair: IceCandidatePair
    let prevIceConnectionState: String
    let delay: Int64
    
    let currIceConnectionState = "failed"
    
    init(
        remoteID: String,
        connectionID: String,
        currIceCandidatePair: IceCandidatePair,
        prevIceConnectionState: String,
        delay: Int64)
    {
        self.remoteID = remoteID
        self.connectionID = connectionID
        self.currIceCandidatePair = currIceCandidatePair
        self.prevIceConnectionState = prevIceConnectionState
        self.delay = delay
    }
    
    override func path() -> String {
        return super.path() + "/status"
    }
}
