//
//  EndpointInfo.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/3/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

struct EndpointInfo: Encodable {
    let appVersion: String
    let type = "native"
    let os = "iOS"
    let osVersion = UIDevice.current.systemVersion
    let buildVersion = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String
}
