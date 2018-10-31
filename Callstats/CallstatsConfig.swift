//
//  CallstatsConfig.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 9/22/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 Library configurations
 */
public class CallstatsConfig: NSObject {
    
    /// Send keep alive event every x second
    var keepAlivePeriod: TimeInterval = 10
    
    /// Stats submission period
    var statsSubmissionPeriod: TimeInterval = 30
    
    /// Send keep alive event every x second
    var systemStatsSubmissionPeriod: TimeInterval = 30
}
