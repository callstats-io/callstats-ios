//
//  TokenRequest.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 9/22/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

class TokenRequest: AuthenticationEvent, Event, Encodable {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    
    let code: String
    let clientID: String
    let grantType: String
    
    init(code: String, clientID: String) {
        self.grantType = "authorization_code"
        self.code = code
        self.clientID = clientID
    }
    
    func url() -> String { return "https://auth.callstats.io" }
    func path() -> String { return "authenticate" }
}
