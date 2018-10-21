//
//  ConferenceStats.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/21/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 All the conference stats inlcuding tracks, candidatePairs,trasnports, msts, dataChannels, codes and timestamps can be submitted using this event.
 */
class ConferenceStats: SessionEvent, Event, Encodable {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    
    let remoteID: String
    let connectionID: String
    let stats: [[String: String]]
    
    init(remoteID: String, connectionID: String, stats: [[String: String]]) {
        self.remoteID = remoteID
        self.connectionID = connectionID
        self.stats = stats
    }
    
    override func url() -> String {
        return "https://stats.callstats.io"
    }
    
    override func path() -> String {
        return super.path() + "stats"
    }
}
