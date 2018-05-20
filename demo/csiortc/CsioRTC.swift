//
//  CsioRTC.swift
//  demo
//
//  Created by Amornchai Kanokpullwad on 5/13/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation
import WebRTC

private let kMessageIceKey = "ice"
private let kMessageOfferKey = "offer"

class CsioRTC: CsioSignalingDelegate {
    
    weak var delegate: CsioRTCDelegate?
    
    private let localMediaLabel = "ARDAMS"
    private let localAudioTrackLabel = "ARDAMSa0"
    private let localVideoTrackLabel = "ARDAMSv0"
    
    private let signaling: CsioSignaling
    private let peerConnectionFactory = RTCPeerConnectionFactory()
    private var localMediaStream: RTCMediaStream?
    private var localAudioTrack: RTCAudioTrack?
    private var localVideoTrack: RTCVideoTrack?
    private var localVideoCapturer: CsioRTCCameraCapturer?
    
    private var peerConnections: [String: RTCPeerConnection] = [:]
    private var peerDelegates: [String: PeerDelegate] = [:]
    private var peerVideoTracks: [String: RTCVideoTrack] = [:]
    
    init(room: String, alias: String? = nil) {
        signaling = CsioSignaling(room: room)
        signaling.delegate = self        
    }
    
    func join() {
        localMediaStream = peerConnectionFactory.mediaStream(withStreamId: localMediaLabel)
        
        // audio
        localAudioTrack = peerConnectionFactory.audioTrack(withTrackId: localAudioTrackLabel)
        localMediaStream?.addAudioTrack(localAudioTrack!)
        
        // video
        let source = peerConnectionFactory.videoSource()
        localVideoCapturer = CsioRTCCameraCapturer(delegate: source)
        localVideoTrack = peerConnectionFactory.videoTrack(with: source, trackId: localVideoTrackLabel)
        localMediaStream?.addVideoTrack(localVideoTrack!)
        
        signaling.start()
    }
    
    func leave() {
        signaling.stop()
        localVideoCapturer?.stopCapture()
        
        peerConnections.keys.forEach { disconnectPeer(peerId: $0) }
        
        localVideoCapturer = nil
        localVideoTrack = nil
        localAudioTrack = nil
        localMediaStream = nil
    }
    
    func setMute(_ mute: Bool) {
        localAudioTrack?.isEnabled = !mute
    }
    
    func setVideoEnable(_ enable: Bool) {
        localVideoTrack?.isEnabled = enable
    }
    
    // MARK:- Video Rendering
    
    func renderLocalVideo(view: CsioRTCVideoView) {
        if let capturer = localVideoCapturer {
            view.setLocalCaptureSession(session: capturer.captureSession)
            capturer.startCapture()
        }
    }
    
    func addRemoteVideoRenderer(peerId: String, view: CsioRTCVideoView) {
        peerVideoTracks[peerId]?.add(view.remoteVideoView)
    }
    
    func removeRemoteVideoRenderer(peerId: String, view: CsioRTCVideoView) {
        peerVideoTracks[peerId]?.remove(view.remoteVideoView)
    }
    
    // MARK:- Peers
 
    func getPeerIds() -> [String] {
        return Array(peerConnections.keys)
    }
    
    func getAvailableVideoPeerIds() -> [String] {
        return Array(peerVideoTracks.keys)
    }
    
    // MARK:- Peer Connection
    
    private func offer(peerId: String) {
        let peerDelegate = PeerDelegate(peerId: peerId, outer: self)
        let connection = peerConnectionFactory.peerConnection(
            with: RTCConfiguration(),
            constraints: RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil),
            delegate: peerDelegate)
        
        connection.add(localMediaStream!)
        connection.offer(for: RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)) { sdp, err in
            guard let localSdp = sdp else { return }
            connection.setLocalDescription(localSdp) { err in print(err ?? "set local success") }
            
            let dict = [
                kMessageOfferKey: [
                    "type": "offer",
                    "sdp": localSdp.sdp
                ]
            ]
            self.signaling.send(toId: peerId, message: toJson(dict))
        }
        
        peerConnections[peerId] = connection
        peerDelegates[peerId] = peerDelegate
        delegate?.onCsioRTCPeerUpdate()
    }
    
    private func answer(peerId: String, offerSdp: RTCSessionDescription) {
        let peerDelegate = PeerDelegate(peerId: peerId, outer: self)
        let connection = peerConnectionFactory.peerConnection(
            with: RTCConfiguration(),
            constraints: RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil),
            delegate: peerDelegate)
        
        connection.add(localMediaStream!)
        connection.setRemoteDescription(offerSdp) { err in print(err ?? "set remote success") }
        connection.answer(for: RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)) { sdp, err in
            guard let localSdp = sdp else { return }
            connection.setLocalDescription(localSdp) { err in
                print(err ?? "set local success")
            }
            
            let dict = [
                kMessageOfferKey: [
                    "type": "answer",
                    "sdp": localSdp.sdp
                ]
            ]
            self.signaling.send(toId: peerId, message: toJson(dict))
        }
        
        peerConnections[peerId] = connection
        peerDelegates[peerId] = peerDelegate
        delegate?.onCsioRTCPeerUpdate()
    }
    
    private func disconnectPeer(peerId: String) {
        if let con = peerConnections[peerId] {
            con.remove(localMediaStream!)
            con.close()
            peerConnections.removeValue(forKey: peerId)
            peerDelegates.removeValue(forKey: peerId)
            peerVideoTracks.removeValue(forKey: peerId)
            delegate?.onCsioRTCPeerUpdate()
        }
    }
    
    class PeerDelegate: NSObject, RTCPeerConnectionDelegate {
        
        let peerId: String
        weak var outer: CsioRTC?
        
        init(peerId: String, outer: CsioRTC) {
            self.peerId = peerId
            self.outer = outer
        }
        
        func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
            let jsonStr: [String: Any] = [
                kMessageIceKey: [
                    "sdpMid": candidate.sdpMid ?? "",
                    "sdpMLineIndex": candidate.sdpMLineIndex,
                    "candidate": candidate.sdp
                ]
            ]
            outer?.signaling.send(toId: peerId, message: toJson(jsonStr))
        }
        
        func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
            if let track = stream.videoTracks.first {
                outer?.peerVideoTracks[peerId] = track
                outer?.delegate?.onCsioRTCPeerVideoAvailable()
            }
        }
        
        func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
            
        }
        
        func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {}
        func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {}
        func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {}
        func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {}
        func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {}
        func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {}
    }
    
    // MARK:- Signaling delegate
    
    func onConnect() {
        delegate?.onCsioRTCConnect()
    }
    
    func onConnectError() {
        delegate?.onCsioRTCError()
    }
    
    func onPeerJoin(peerId: String) {
        offer(peerId: peerId)
    }
    
    func onPeerLeave(peerId: String) {
        disconnectPeer(peerId: peerId)
    }
    
    func onMessage(fromId: String, message: String) {
        let dict = fromJson(message)
        if dict.keys.contains(kMessageIceKey) {
            if let con = peerConnections[fromId] {
                let iceDict = dict[kMessageIceKey] as! [String: Any]
                con.add(RTCIceCandidate(
                    sdp: iceDict["candidate"] as! String,
                    sdpMLineIndex: iceDict["sdpMLineIndex"] as! Int32,
                    sdpMid: iceDict["sdpMid"] as? String))
            }
        } else if dict.keys.contains(kMessageOfferKey) {
            let offerDict = dict[kMessageOfferKey] as! [String: String]
            let sdp = RTCSessionDescription(
                type: offerDict["type"] == "offer" ? .offer : .answer,
                sdp: offerDict["sdp"] ?? "")
            if sdp.type == .offer {
                answer(peerId: fromId, offerSdp: sdp)
            } else if sdp.type == .answer {
                peerConnections[fromId]?.setRemoteDescription(sdp) { err in print(err ?? "set remote success") }
            }
        }
    }
}
