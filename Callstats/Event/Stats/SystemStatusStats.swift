
//
//  SystemStatusStats.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/11/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

class SystemStatusStats: AuthenticatedEvent, Event, Encodable {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    
    /// CPU level in percentage
    var cpuLevel: Int?
    
    /// Battery level in percentage
    var batteryLevel: Int?
    
    /// Memory usage in MB
    var memoryUsage: Int?
    
    /// Total memory in MB
    var memoryAvailable: Int?
    
    /// Number of threads
    var threadCount: Int?
    
    /// check if this stats has value to be sent
    func isValid() -> Bool {
        return cpuLevel ?? batteryLevel ?? memoryUsage ?? memoryAvailable ?? threadCount != nil
    }
    
    override func url() -> String {
        return "https://stats.callstats.io"
    }
    
    override func path() -> String {
        return super.path() + "stats/system"
    }
}
