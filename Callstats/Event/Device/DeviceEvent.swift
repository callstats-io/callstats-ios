//
//  DeviceEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 9/28/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 Information about the connected and/or active media devices.
 */
class DeviceEvent: SessionEvent {
    
    let eventType: String
    let mediaDeviceList: [MediaDevice]
    
    enum EventType: String {
        case connected = "connectedDeviceList"
        case active = "activeDeviceList"
    }
    
    init(eventType: EventType, mediaDeviceList: [MediaDevice]) {
        self.eventType = eventType.rawValue
        self.mediaDeviceList = mediaDeviceList
    }
}
