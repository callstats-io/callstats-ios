//
//  UserDetailsEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/11/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 You can submit the user details such as username using this event.
 */
class UserDetailsEvent: SessionEvent {
    
    let userName: String
    
    init(userName: String) {
        self.userName = userName
    }
    
    override func path() -> String {
        return super.path() + "events/userdetails"
    }
}
