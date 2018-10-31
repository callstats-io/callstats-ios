//
//  FabricSetupFailedEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/3/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 This should be sent when fabric setup fails. This means connection has failed and you cannot send data
 */
class FabricSetupFailedEvent: FabricEvent, Event, Encodable {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    
    let reason: String
    
    var name: String?
    var message: String?
    
    /**
     Stack trace of error
     */
    var stack: String?
    
    /**
     Stream flow direction inside the fabric.
     "sendonly", "receiveonly" or "sendrecv"
     Default is ""sendrecv""
     */
    var fabricTransmissionDirection = "sendrecv"
    
    /**
     Type of remote endpoint a fabric was established to.
     "peer" or "server"
     Default is "peer".
     */
    var remoteEndpointType = "peer"
    
    init(reason: String) {
        self.reason = reason
    }
    
    override func path() -> String {
        return super.path() + "/setupfailed"
    }
}
