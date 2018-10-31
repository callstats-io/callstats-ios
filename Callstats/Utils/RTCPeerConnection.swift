//
//  RTCPeerConnection.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/6/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation
import WebRTC

/**
 Convert RTCIceConnectionState to string value
 */
extension RTCIceConnectionState {
    func toString() -> String {
        switch self {
        case .new: return "new"
        case .checking: return "checking"
        case .completed: return "completed"
        case .connected: return "connected"
        case .disconnected: return "disconnected"
        case .failed: return "failed"
        case .closed: return "closed"
        case .count: return "count"
        }
    }
}

/**
 Convert RTCIceGatheringState to string value
 */
extension RTCIceGatheringState {
    func toString() -> String {
        switch self {
        case .new: return "new"
        case .gathering: return "gathering"
        case .complete: return "complete"
        }
    }
}

/**
 Convert RTCSignalingState to string value
 */
extension RTCSignalingState {
    func toString() -> String {
        switch self {
        case .stable: return "stable"
        case .haveLocalOffer: return "have-local-offer"
        case .haveRemoteOffer: return "have-remote-offer"
        case .haveLocalPrAnswer: return "have-local-pranswer"
        case .haveRemotePrAnswer: return "have-remote-pranswer"
        case .closed: return "closed"
        }
    }
}
