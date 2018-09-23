//
//  TokenRequest.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 9/22/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

class TokenRequest: Event, AuthenticationEvent {
    
    let code: String
    let clientID: String
    let grantType: String
    
    init(code: String, clientID: String) {
        self.grantType = "authorization_code"
        self.code = code
        self.clientID = clientID
    }
    
    override func url() -> String { return "https://auth.callstats.io" }
    override func path() -> String { return "authenticate" }
}
