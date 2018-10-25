//
//  CallstatsEvents.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 9/21/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation
import WebRTC

// MARK:- Enums

/// CSMediaEvent and CSPlaybackEvent media type
@objc public enum MediaEventType: Int { case audio, video, screen }

/// CSPlaybackEvent type
@objc public enum PlaybackEventType: Int { case start, suspended, stalled, oneway }

/// Logging levels when report application logs
@objc public enum LoggingLevel: Int { case debug, info, warn, error, fatal }

/// Logging types when report application logs
@objc public enum LoggingType: Int { case text, json }

// MARK:- Base events

typealias PeerEvent = CSPeerEvent
typealias AppEvent = CSAppEvent

/// base class for peer events
public class CSPeerEvent: NSObject {}

/// base class for app events
public class CSAppEvent: NSObject {}

// MARK:- Peer events

/// event to report when ice connection state changed
public final class CSIceConnectionChangeEvent: CSPeerEvent {
    let state: RTCIceConnectionState
    public init(state: RTCIceConnectionState) {
        self.state = state
    }
}

/// event to report when ice gathering state changed
public final class CSIceGatheringChangeEvent: CSPeerEvent {
    let state: RTCIceGatheringState
    public init(state: RTCIceGatheringState) {
        self.state = state
    }
}

/// event to report when signaling state changed
public final class CSSignalingChangeEvent: CSPeerEvent {
    let state: RTCSignalingState
    public init(state: RTCSignalingState) {
        self.state = state
    }
}

/// event to report when stream is added
public final class CSAddStreamEvent: CSPeerEvent {}

/// event to report when holding the connection to this peer
public final class CSHoldEvent: CSPeerEvent {}
/// event to report when resuming the connection to this peer
public final class CSResumeEvent: CSPeerEvent {}

/// internal use
final class CSStatsEvent: CSPeerEvent {}

/// event to report when media state is changed
public class CSMediaEvent: CSPeerEvent {
    let mediaDeviceID: String
    let type: MediaEventType
    let enable: Bool
    init(type: MediaEventType, enable: Bool, deviceID: String) {
        self.type = type
        self.enable = enable
        self.mediaDeviceID = deviceID
    }
}

/// event to report when media playback state is changed
public class CSPlaybackEvent: CSPeerEvent {
    let mediaType: MediaEventType
    let eventType: PlaybackEventType
    init(mediaType: MediaEventType, eventType: PlaybackEventType) {
        self.mediaType = mediaType
        self.eventType = eventType
    }
}

// MARK:- App events
