//
//  EventSendingOperation.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 9/23/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 Operation to send event
 */
class EventSendingOperation: Operation {
    
    let event: Event
    
    init(event: Event) {
        self.event = event
    }
    
    override func start() {
        
    }
}
