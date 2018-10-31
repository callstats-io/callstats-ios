//
//  SdpEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/15/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 PRO feature: Whenever there is an updated SDP or a pair of local and remote SDPs, this can be sent to callstats.io.
 */
class SdpEvent: SessionEvent, Event, Encodable {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    
    let remoteID: String
    let connectionID: String
    
    /**
     Stringified SDP of the local user
     */
    var localSDP: String?
    
    /**
     Stringified SDP of the remote user
     */
    var remoteSDP: String?
    
    init(remoteID: String, connectionID: String) {
        self.remoteID = remoteID
        self.connectionID = connectionID
    }
    
    override func path() -> String {
        return super.path() + "events/sdp"
    }
}
