//
//  LogEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/25/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 You can submit application error logs using this event. You will be able to search for them and also categorize them.
 */
class LogEvent: SessionEvent, Event, Encodable {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    
    let level: String
    let message: String
    let messageType: String
    
    init(level: LoggingLevel, message: String, messageType: LoggingType) {
        self.message = message
        switch level {
        case .debug: self.level = "debug"
        case .info: self.level = "info"
        case .warn: self.level = "warn"
        case .error: self.level = "error"
        case .fatal: self.level = "fatal"
        }
        switch messageType {
        case .text: self.messageType = "text"
        case .json: self.messageType = "json"
        }
    }
    
    override func path() -> String {
        return super.path() + "events/app/logs"
    }
}
