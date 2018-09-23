//
//  Callstats.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 9/21/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 Entry point for sending WebRTC stats to callstats.io
 */
public class Callstats: NSObject {
    
    static var dependency = CallstatsInjector()
    
    private let localID: String
    private let username: String?
    private let clientVersion: String?
    private let configuration: CallstatsConfig
    private let sender: EventSender
    
    public init(
        appID: String,
        localID: String,
        deviceID: String,
        jwt: String,
        username: String? = nil,
        clientVersion: String? = nil,
        configuration: CallstatsConfig = CallstatsConfig())
    {
        self.localID = localID
        self.username = username
        self.clientVersion = clientVersion
        self.configuration = configuration
        
        sender = Callstats.dependency.eventSender(appID: appID, localID: localID, deviceID: deviceID)
        sender.send(event: TokenRequest(code: jwt, clientID: "\(localID)@\(appID)"))
    }
}
