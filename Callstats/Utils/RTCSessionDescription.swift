//
//  RTCSessionDescription.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/3/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation
import WebRTC

extension String {
    
    /**
     Extract SSRC values from ID in session description
     */
    func ssrcValues(id: String) -> [String: String]? {
        var values: [String: String]?
        let lines = split(separator: "\n")
        let prefix = "a=ssrc:\(id) "
        for line in lines {
            if line.starts(with: prefix) {
                if values == nil { values = [:] }
                let array = line.replacingOccurrences(of: prefix, with: "").split(separator: ":")
                values?[String(array[0])] = String(array[1])
            }
        }
        return values
    }
}
