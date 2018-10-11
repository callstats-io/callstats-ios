//
//  UserLeftEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/11/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 User left event should be sent when a user leaves the conference.
 */
class UserLeftEvent: SessionEvent {
    override func path() -> String {
        return super.path() + "events/user/left"
    }
}
