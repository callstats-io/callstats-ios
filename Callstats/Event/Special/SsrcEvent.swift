//
//  SsrcEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/23/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 Whenever a new media stream track appears,
 for example a new participant joins or a new media source is added, the SSRC Map event MUST be sent.
 */
class SsrcEvent: SessionEvent, Event, Encodable {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    
    let remoteID: String
    let connectionID: String
    
    var ssrcData: [Ssrc] = []
    
    init(remoteID: String, connectionID: String) {
        self.remoteID = remoteID
        self.connectionID = connectionID
    }
    
    override func path() -> String {
        return super.path() + "events/ssrcmap"
    }
}
