//
//  FabricTerminatedEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/4/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 This should be sent when fabric is terminated. This means connection has ended and you cannot send data
 */
class FabricTerminatedEvent: FabricEvent, Event, Encodable {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    
    let remoteID: String
    let connectionID: String
    
    init(remoteID: String, connectionID: String) {
        self.remoteID = remoteID
        self.connectionID = connectionID
    }
    
    override func path() -> String {
        return super.path() + "/terminated"
    }
}
