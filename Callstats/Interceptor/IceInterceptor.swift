//
//  IceInterceptor.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/17/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation
import WebRTC

/**
 Interceptor to handle ICE events
 */
class IceInterceptor: Interceptor {
    
    private var iceConnectionState = RTCIceConnectionState.new
    private var iceCandidatePair: IceCandidatePair?
    private var timestamp = [RTCIceConnectionState.new: Date().currentTimeInMillis]
    
    func process(
        connection: Connection,
        event: PeerEvent,
        localID: String,
        remoteID: String,
        connectionID: String,
        stats: [WebRTCStats]) -> [Event]
    {
        guard let event = event as? CSIceConnectionChangeEvent else { return [] }
        var events: [Event] = []
        let newState = event.state
        let newTimestamp = Date().currentTimeInMillis
        let selectedPairId = stats.selectedCandidatePairId()
        let pairs = stats.candidatePairs()
        let newPair = pairs.first { $0.id == selectedPairId }
        
        if let e = sendDisruptionStartEvent(remoteID, connectionID, newState, newPair) { events.append(e) }
        if let e = sendDisruptionEndEvent(remoteID, connectionID, newState, newPair, newTimestamp) { events.append(e) }
        if let e = sendRestartEvent(remoteID, connectionID, newState) { events.append(e) }
        
        if newState == .failed || newState == .closed {
            let locals = stats.localCandidates()
            let remotes = stats.remoteCandidates()
            if let e = sendFailedEvent(remoteID, connectionID, newState, pairs, locals, remotes, newTimestamp) { events.append(e) }
            if let e = sendAbortedEvent(remoteID, connectionID, newState, pairs, locals, remotes, newTimestamp) { events.append(e) }
        }
        
        if let e = sendTerminatedEvent(remoteID, connectionID, newState) { events.append(e) }
        if let e = sendConnectionDisruptionStartEvent(remoteID, connectionID, newState) { events.append(e) }
        if let e = sendConnectionDisruptionEndEvent(remoteID, connectionID, newState, newTimestamp) { events.append(e) }
        
        // finally, update the states
        iceConnectionState = newState
        iceCandidatePair = newPair
        timestamp[newState] = newTimestamp
        
        return events
    }
    
    private func sendDisruptionStartEvent(
        _ remoteID: String,
        _ connectionID: String,
        _ newState: RTCIceConnectionState,
        _ newPair: IceCandidatePair?) -> Event?
    {
        guard newState == .disconnected else { return nil }
        guard iceConnectionState == .connected || iceConnectionState == .completed else { return nil }
        guard let pair = newPair else { return nil }
        return IceDisruptStartEvent(
            remoteID: remoteID,
            connectionID: connectionID,
            currIceCandidatePair: pair,
            prevIceConnectionState: iceConnectionState.toString())
    }
    
    private func sendDisruptionEndEvent(
        _ remoteID: String,
        _ connectionID: String,
        _ newState: RTCIceConnectionState,
        _ newPair: IceCandidatePair?,
        _ newTimestamp: Int64) -> Event?
    {
        guard iceConnectionState == .disconnected else { return nil }
        guard newState == .connected || newState == .completed || newState == .checking else { return nil }
        guard let newPair = newPair,
            let prevPair = iceCandidatePair,
            let startTime = timestamp[.disconnected]
            else { return nil }
        return IceDisruptEndEvent(
            remoteID: remoteID,
            connectionID: connectionID,
            currIceCandidatePair: newPair,
            prevIceCandidatePair: prevPair,
            currIceConnectionState: newState.toString(),
            delay: newTimestamp - startTime)
    }
    
    private func sendRestartEvent(
        _ remoteID: String,
        _ connectionID: String,
        _ newState: RTCIceConnectionState) -> Event?
    {
        guard newState == .new, let prevPair = iceCandidatePair else { return nil }
        return IceRestartEvent(
            remoteID: remoteID,
            connectionID: connectionID,
            prevIceCandidatePair: prevPair,
            prevIceConnectionState: iceConnectionState.toString())
    }
    
    private func sendFailedEvent(
        _ remoteID: String,
        _ connectionID: String,
        _ newState: RTCIceConnectionState,
        _ pairs: [IceCandidatePair],
        _ localCanidates: [IceCandidate],
        _ remoteCandidates: [IceCandidate],
        _ newTimestamp: Int64) -> Event?
    {
        guard newState == .failed else { return nil }
        guard iceConnectionState == .checking || iceConnectionState == .disconnected else { return nil }
        guard let startTime = timestamp[iceConnectionState] else { return nil }
        let event = IceFailedEvent(
            remoteID: remoteID,
            connectionID: connectionID,
            prevIceConnectionState: iceConnectionState.toString(),
            delay: newTimestamp - startTime)
        event.iceCandidatePairs.append(contentsOf: pairs)
        event.localIceCandidates.append(contentsOf: localCanidates)
        event.remoteIceCandidates.append(contentsOf: remoteCandidates)
        return event
    }
    
    private func sendAbortedEvent(
        _ remoteID: String,
        _ connectionID: String,
        _ newState: RTCIceConnectionState,
        _ pairs: [IceCandidatePair],
        _ localCanidates: [IceCandidate],
        _ remoteCandidates: [IceCandidate],
        _ newTimestamp: Int64) -> Event?
    {
        guard newState == .closed else { return nil }
        guard iceConnectionState == .checking || iceConnectionState == .new else { return nil }
        guard let startTime = timestamp[iceConnectionState] else { return nil }
        let event = IceAbortedEvent(
            remoteID: remoteID,
            connectionID: connectionID,
            prevIceConnectionState: iceConnectionState.toString(),
            delay: newTimestamp - startTime)
        event.iceCandidatePairs.append(contentsOf: pairs)
        event.localIceCandidates.append(contentsOf: localCanidates)
        event.remoteIceCandidates.append(contentsOf: remoteCandidates)
        return event
    }
    
    private func sendTerminatedEvent(
        _ remoteID: String,
        _ connectionID: String,
        _ newState: RTCIceConnectionState) -> Event?
    {
        guard newState == .closed else { return nil }
        guard iceConnectionState == .connected
            || iceConnectionState == .completed
            || iceConnectionState == .failed
            || iceConnectionState == .disconnected else { return nil }
        guard let prevPair = iceCandidatePair else { return nil }
        return IceTerminatedEvent(
            remoteID: remoteID,
            connectionID: connectionID,
            prevIceCandidatePair: prevPair,
            prevIceConnectionState: iceConnectionState.toString())
    }
    
    private func sendConnectionDisruptionStartEvent(
        _ remoteID: String,
        _ connectionID: String,
        _ newState: RTCIceConnectionState) -> Event?
    {
        guard newState == .disconnected, iceConnectionState == .checking else { return nil }
        return IceConnectionDisruptStartEvent(remoteID: remoteID, connectionID: connectionID)
    }
    
    private func sendConnectionDisruptionEndEvent(
        _ remoteID: String,
        _ connectionID: String,
        _ newState: RTCIceConnectionState,
        _ newTimestamp: Int64) -> Event?
    {
        guard newState == .checking, iceConnectionState == .disconnected else { return nil }
        guard let startTime = timestamp[iceConnectionState] else { return nil }
        return IceConnectionDisruptEndEvent(
            remoteID: remoteID,
            connectionID: connectionID,
            delay: newTimestamp - startTime)
    }
}
