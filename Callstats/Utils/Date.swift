
//
//  Date.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 9/23/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

extension Date {
    var currentTimeInMillis: Int64 {
        get { return Int64(self.timeIntervalSince1970 * 1000) }
    }
}
