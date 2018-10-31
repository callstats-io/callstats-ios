//
//  MediaActionEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/24/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 When a participant mutes/unmute the audio, pauses/resumes the video,
 or starts/stops screen sharing, this event can be submitted
 */
class MediaActionEvent: MediaEvent, Event, Encodable {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    
    let remoteID: String
    let connectionID: String
    let eventType: String
    let mediaDeviceID: String
    let remoteIDList: [String]
    
    enum EventType: String {
        case mute = "audioMute"
        case unmute = "audioUnmute"
        case videoPause = "videoPause"
        case videoResume = "videoResume"
        case screenStart = "screenShareStart"
        case screenStop = "screenShareStop"
    }
    
    init(remoteID: String, connectionID: String, eventType: EventType, mediaDeviceID: String) {
        self.remoteID = remoteID
        self.connectionID = connectionID
        self.eventType = eventType.rawValue
        self.mediaDeviceID = mediaDeviceID
        // api required remoteIDList so use the one from the event
        self.remoteIDList = [remoteID]
    }
    
    override func path() -> String {
        return super.path() + "/actions"
    }
}
