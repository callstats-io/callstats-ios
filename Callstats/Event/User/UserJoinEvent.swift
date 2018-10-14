//
//  UserJoinEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/11/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 This is the first step to add a new participant to the list of conference participants
 or start a new conference. If there are no participants in the given conference then
 a new conference will be created with the conferenceID provided.
 */
class UserJoinEvent: AuthenticatedEvent, CreateSessionEvent, Event, Encodable {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    
    let confID: String
    let endpointInfo: EndpointInfo
    
    init(confID: String, appVersion: String? = nil) {
        self.confID = confID
        self.endpointInfo = EndpointInfo(appVersion: appVersion)
    }
}
