//
//  UserAliveEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/11/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 UserAlive makes sure that the user is present in the conference.
 */
class UserAliveEvent: KeepAliveEvent, Event, Encodable {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    override func path() -> String {
        return super.path() + "events/user/alive"
    }
}
