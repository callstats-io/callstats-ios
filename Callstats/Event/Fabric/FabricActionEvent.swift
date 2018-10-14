//
//  FabricActionEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/4/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 When the fabric hold or resume events happen, this event can be submitted
 */
class FabricActionEvent: FabricEvent, Event, Encodable {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    
    let remoteID: String
    let connectionID: String
    let eventType: String
    
    enum EventType: String {
        case hold = "fabricHold"
        case resume = "fabricResume"
    }
    
    init(remoteID: String, connectionID: String, eventType: EventType) {
        self.remoteID = remoteID
        self.connectionID = connectionID
        self.eventType = eventType.rawValue
    }
    
    override func path() -> String {
        return super.path() + "/actions"
    }
}
