//
//  EventSender.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 9/22/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 Event queue for sending events to server
 */
protocol EventSender {
    func send(event: Event)
}

class EventSenderImpl: EventSender {
    
    private let appID: String
    private let localID: String
    private let deviceID: String
    
    init(appID: String, localID: String, deviceID: String) {
        self.appID = appID
        self.localID = localID
        self.deviceID = deviceID
    }
    
    func send(event: Event) {
        event.localID = localID
        event.deviceID = deviceID
    }
}
