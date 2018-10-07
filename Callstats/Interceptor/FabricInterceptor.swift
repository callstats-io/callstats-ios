//
//  FabricInterceptor.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/6/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation
import WebRTC

/**
 Interceptor to handle fabric events
 */
class FabricInterceptor: Interceptor {
    
    private var iceConnectionState = RTCIceConnectionState.new
    private var iceGatheringState = RTCIceGatheringState.new
    private var signalingState = RTCSignalingState.closed
    private var timestamp = [RTCIceConnectionState.new: Date().currentTimeInMillis]
    private var iceCandidatePair: IceCandidatePair?
    
    private var connected = false
    
    func process(
        connection: Connection,
        event: PeerEvent,
        localID: String,
        remoteID: String,
        connectionID: String,
        stats: [WebRTCStats]) -> [Event]
    {
        if !checkEvent(event) { return [] }
        var events: [Event] = []
        let newTimestamp = Date().currentTimeInMillis
        
        if let e = sendFabricStateChange(remoteID, connectionID, event) { events.append(e) }
        if let e = sendFabricDropped(remoteID, connectionID, event, newTimestamp) { events.append(e) }
        if let e = sendFabricTerminated(remoteID, connectionID, event) { events.append(e) }
        
        if let event = event as? CSIceConnectionChangeEvent, event.state == .connected {
            let selectedPairId = stats.selectedCandidatePairId()
            let pairs = stats.candidatePairs()
            let newPair = pairs.first { $0.id == selectedPairId }
            let locals = stats.localCandidates()
            let remotes = stats.remoteCandidates()
            if !connected {
                connected = true
                if let e = sendFabricSetup(remoteID, connectionID, event, newTimestamp, selectedPairId, pairs, locals, remotes) {
                    events.append(e)
                }
            } else {
                if let e = sendFabricTransportChange(remoteID, connectionID, event, newTimestamp, newPair, locals, remotes) {
                    events.append(e)
                }
            }
            iceCandidatePair = newPair
        }
        
        if let e = sendFabricAction(remoteID, connectionID, event) { events.append(e) }
        
        // update states
        switch event {
        case let e as CSIceConnectionChangeEvent:
            iceConnectionState = e.state
            timestamp[iceConnectionState] = newTimestamp
        case let e as CSIceGatheringChangeEvent:
            iceGatheringState = e.state
        case let e as CSSignalingChangeEvent:
            signalingState = e.state
        default: ()
        }
        
        return events
    }
    
    private func sendFabricStateChange(_ remoteID: String, _ connectionID: String, _ event: PeerEvent) -> Event? {
        let prevState: String
        let newState: String
        let changedState: String
        switch event {
        case let e as CSIceConnectionChangeEvent:
            if e.state == iceConnectionState { return nil }
            prevState = iceConnectionState.toString()
            newState = e.state.toString()
            changedState = "iceConnectionState"
        case let e as CSIceGatheringChangeEvent:
            if e.state == iceGatheringState { return nil }
            prevState = iceGatheringState.toString()
            newState = e.state.toString()
            changedState = "iceGatheringState"
        case let e as CSSignalingChangeEvent:
            if e.state == signalingState { return nil }
            prevState = signalingState.toString()
            newState = e.state.toString()
            changedState = "signalingState"
        default:
            return nil
        }
        
        return FabricStateChangeEvent(
            remoteID: remoteID,
            connectionID: connectionID,
            prevState: prevState,
            newState: newState,
            changedState: changedState)
    }
    
    private func sendFabricDropped(_ remoteID: String, _ connectionID: String, _ event: PeerEvent, _ newTimestamp: Int64) -> Event? {
        guard connected else { return nil }
        guard iceConnectionState == .completed || iceConnectionState == .disconnected else { return nil }
        guard let e = event as? CSIceConnectionChangeEvent else { return nil }
        guard e.state == .failed else { return nil }
        guard let pair = iceCandidatePair else { return nil }
        guard let startTime = timestamp[iceConnectionState] else { return nil }
        return FabricDroppedEvent(
            remoteID: remoteID,
            connectionID: connectionID,
            currIceCandidatePair: pair,
            prevIceConnectionState: iceConnectionState.toString(),
            delay: newTimestamp - startTime)
    }
    
    private func sendFabricTerminated(_ remoteID: String, _ connectionID: String, _ event: PeerEvent) -> Event? {
        guard connected else { return nil }
        guard iceConnectionState != .closed else { return nil }
        guard let e = event as? CSIceConnectionChangeEvent else { return nil }
        guard e.state == .closed else { return nil }
        return FabricTerminatedEvent(remoteID: remoteID, connectionID: connectionID)
    }
    
    private func sendFabricSetup(
        _ remoteID: String,
        _ connectionID: String,
        _ event: CSIceConnectionChangeEvent,
        _ newTimestamp: Int64,
        _ selectedPairID: String?,
        _ candidatePairs: [IceCandidatePair],
        _ localCandidates: [IceCandidate],
        _ remoteCandidates: [IceCandidate]) -> Event?
    {
        let setupDelay: Int64
        if let time = timestamp[.new] { setupDelay = newTimestamp - time } else { setupDelay = 0 }
        let setupEvent = FabricSetupEvent(remoteID: remoteID, connectionID: connectionID)
        setupEvent.delay = setupDelay
        setupEvent.iceConnectivityDelay = setupEvent.delay
        setupEvent.iceCandidatePairs.append(contentsOf: candidatePairs)
        setupEvent.localIceCandidates.append(contentsOf: localCandidates)
        setupEvent.remoteIceCandidates.append(contentsOf: remoteCandidates)
        setupEvent.selectedCandidatePairID = selectedPairID
        return setupEvent
    }
    
    private func sendFabricTransportChange(
        _ remoteID: String,
        _ connectionID: String,
        _ event: CSIceConnectionChangeEvent,
        _ newTimestamp: Int64,
        _ newPair: IceCandidatePair?,
        _ localCandidates: [IceCandidate],
        _ remoteCandidates: [IceCandidate]) -> Event?
    {
        guard let prevPair = iceCandidatePair else { return nil }
        guard let pair = newPair else { return nil }
        let lastConnectDelay: Int64
        if let time = timestamp[.new] { lastConnectDelay = newTimestamp - time } else { lastConnectDelay = 0 }
        let transportEvent = FabricTransportChangeEvent(
            remoteID: remoteID,
            connectionID: connectionID,
            currIceCandidatePair: pair,
            prevIceCandidatePair: prevPair,
            currIceConnectionState: event.state.toString(),
            prevIceConnectionState: iceConnectionState.toString(),
            delay: lastConnectDelay)
        transportEvent.localIceCandidates.append(contentsOf: localCandidates)
        transportEvent.remoteIceCandidates.append(contentsOf: remoteCandidates)
        return transportEvent
    }
    
    private func sendFabricAction(_ remoteID: String, _ connectionID: String, _ event: PeerEvent) -> Event? {
        guard connected else { return nil }
        switch event {
        case is CSHoldEvent: return FabricActionEvent(remoteID: remoteID, connectionID: connectionID, eventType: .hold)
        case is CSResumeEvent: return FabricActionEvent(remoteID: remoteID, connectionID: connectionID, eventType: .resume)
        default: return nil
        }
    }
    
    private func checkEvent(_ event: PeerEvent) -> Bool {
        return event is CSIceConnectionChangeEvent
            || event is CSIceGatheringChangeEvent
            || event is CSSignalingChangeEvent
            || event is CSHoldEvent
            || event is CSResumeEvent
    }
}
