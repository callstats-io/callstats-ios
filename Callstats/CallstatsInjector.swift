//
//  CallstatsInjector.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 9/22/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

class CallstatsInjector {
    
    func eventSender(appID: String, localID: String, deviceID: String) -> EventSender {
        return EventSenderImpl(appID: appID, localID: localID, deviceID: deviceID)
    }
}
