//
//  MediaInterceptor.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/24/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 Interceptor for media events
 */
class MediaInterceptor: Interceptor {
    
    func process(
        connection: Connection,
        event: PeerEvent,
        localID: String,
        remoteID: String,
        connectionID: String,
        stats: [WebRTCStats]) -> [Event]
    {
        guard event is CSMediaEvent || event is CSPlaybackEvent else { return [] }
        if let e = sendMediaActionEvent(remoteID, connectionID, event) { return [e] }
        if let e = sendMediaPlaybackEvent(remoteID, connectionID, event, connection, localID, stats) { return [e] }
        return []
    }
    
    private func sendMediaActionEvent(
        _ remoteID: String,
        _ connectionID: String,
        _ event: PeerEvent) -> Event?
    {
        guard let event = event as? CSMediaEvent else { return nil }
        let eventType: MediaActionEvent.EventType
        switch event.type {
        case .audio: eventType = event.enable ? .unmute : .mute
        case .video: eventType = event.enable ? .videoResume : .videoPause
        case .screen: eventType = event.enable ? .screenStart : .screenStop
        }
        return MediaActionEvent(
            remoteID: remoteID,
            connectionID: connectionID,
            eventType: eventType,
            mediaDeviceID: event.mediaDeviceID)
    }
    
    private func sendMediaPlaybackEvent(
        _ remoteID: String,
        _ connectionID: String,
        _ event: PeerEvent,
        _ connection: Connection,
        _ localID: String,
        _ stats: [WebRTCStats]) -> Event?
    {
        guard let event = event as? CSPlaybackEvent else { return nil }
        let mediaType: MediaPlaybackEvent.MediaType
        switch event.mediaType {
        case .audio: mediaType = .audio
        case .video: mediaType = .video
        case .screen: mediaType = .screen
        }
        if event.eventType == .oneway {
            return MediaPlaybackEvent(
                remoteID: remoteID,
                connectionID: connectionID,
                eventType: .oneway,
                mediaType: mediaType,
                ssrc: nil)
        } else {
            let ssrcs = stats.ssrcs(connection: connection, localID: localID, remoteID: remoteID)
            let ssrc = ssrcs.first { $0.isLocal() && $0.mediaType == mediaType.rawValue }
            guard let ssrcStr = ssrc?.ssrc else { return nil }
            let eventType: MediaPlaybackEvent.EventType
            switch event.eventType {
            case .start: eventType = .start
            case .suspended: eventType = .suspended
            case .stalled: eventType = .stalled
            case .oneway: eventType = .oneway
            }
            return MediaPlaybackEvent(
                remoteID: remoteID,
                connectionID: connectionID,
                eventType: eventType,
                mediaType: mediaType,
                ssrc: ssrcStr)
        }
    }
}
