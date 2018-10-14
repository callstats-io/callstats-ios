//
//  CallstatsEvents.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 9/21/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation
import WebRTC

typealias PeerEvent = CSPeerEvent
typealias AppEvent = CSAppEvent

public class CSPeerEvent: NSObject {}
public class CSAppEvent: NSObject {}

// MARK:- Peer events

public final class CSIceConnectionChangeEvent: CSPeerEvent {
    let state: RTCIceConnectionState
    public init(state: RTCIceConnectionState) {
        self.state = state
    }
}

public final class CSIceGatheringChangeEvent: CSPeerEvent {
    let state: RTCIceGatheringState
    public init(state: RTCIceGatheringState) {
        self.state = state
    }
}

public final class CSSignalingChangeEvent: CSPeerEvent {
    let state: RTCSignalingState
    public init(state: RTCSignalingState) {
        self.state = state
    }
}

public final class CSHoldEvent: CSPeerEvent {}
public final class CSResumeEvent: CSPeerEvent {}

final class CSStatsEvent: CSPeerEvent {}

// MARK:- App events
