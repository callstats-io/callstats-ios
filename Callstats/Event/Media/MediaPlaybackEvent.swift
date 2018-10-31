//
//  MediaPlaybackEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/24/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 When the media playback starts, suspended or stalls, this event can be submitted
 */
class MediaPlaybackEvent: MediaEvent, Event, Encodable {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    
    let remoteID: String
    let connectionID: String
    let eventType: String
    let mediaType: String
    let ssrc: String?
    
    enum EventType: String {
        case start = "mediaPlaybackStart"
        case suspended = "mediaPlaybackSuspended"
        case stalled = "mediaPlaybackStalled"
        case oneway = "oneWayMedia"
    }
    
    enum MediaType: String {
        case video = "video"
        case audio = "audio"
        case screen = "screen"
    }
    
    init(remoteID: String, connectionID: String, eventType: EventType, mediaType: MediaType, ssrc: String?) {
        self.remoteID = remoteID
        self.connectionID = connectionID
        self.eventType = eventType.rawValue
        self.mediaType = mediaType.rawValue
        self.ssrc = ssrc
    }
}
