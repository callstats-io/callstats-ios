//
//  CallViewController.swift
//  demo
//
//  Created by Amornchai Kanokpullwad on 5/19/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import UIKit
import WebRTC

class CallViewController: UIViewController, CsioRTCDelegate {
    
    var room = ""
    
    @IBOutlet weak var aliasLabel: UILabel!
    @IBOutlet weak var participantCountLabel: UILabel!
    @IBOutlet weak var localVideoView: CsioRTCVideoView!
    @IBOutlet weak var remoteVideoView: CsioRTCVideoView!
    
    private var csioRTC: CsioRTC!
    private var peerIds: [String] = []
    
    // current renderer
    private var showingVideoFromPeer: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if room == "" { return }
        
        aliasLabel.text = "Your name : ios_murdock"
        
        csioRTC = CsioRTC(room: room)
        csioRTC.delegate = self
        csioRTC.join()
        csioRTC.renderLocalVideo(view: localVideoView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        csioRTC.leave()
        presentingViewController?.dismiss(animated: false, completion: nil)
    }
    
    private func showVideo(peerId: String) {
        if peerId == showingVideoFromPeer { return }
        if let peer = showingVideoFromPeer {
            csioRTC.removeRemoteVideoRenderer(peerId: peer, view: remoteVideoView)
        }
        
        showingVideoFromPeer = peerId
        csioRTC.addRemoteVideoRenderer(peerId: peerId, view: remoteVideoView)
    }
    
    // actions
    
    @IBAction func hangButtonPressed(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func videoButtonPressed(_ sender: UIButton) {
        let selected = !sender.isSelected
        sender.isSelected = selected
        csioRTC.setVideoEnable(!selected)
    }
    
    @IBAction func micButtonPressed(_ sender: UIButton) {
        let selected = !sender.isSelected
        sender.isSelected = selected
        csioRTC.setMute(selected)
    }

    @IBAction func leftButtonPressed(_ sender: Any) {
        if let peer = showingVideoFromPeer {
            let found = peerIds.index(of: peer) ?? -1
            let index = found - 1 < 0 ? peerIds.count - 1 : found - 1
            showVideo(peerId: peerIds[index])
        }
    }
    
    @IBAction func rightButtonPressed(_ sender: Any) {
        if let peer = showingVideoFromPeer {
            let found = peerIds.index(of: peer) ?? -1
            let index = found + 1 == peerIds.count ? 0 : found + 1
            showVideo(peerId: peerIds[index])
        }
    }
    
    // CsioRTC delegate
    
    func onCsioRTCConnect() {
        
    }
    
    func onCsioRTCError() {
        
    }
    
    func onCsioRTCPeerUpdate() {
        // update no. of participants
        let peerIds = csioRTC.getPeerIds()
        participantCountLabel.text = "No. of participant : \(peerIds.count)"
        // save peer ids to navigate
        self.peerIds = peerIds
    }
    
    func onCsioRTCPeerVideoAvailable() {
        let peerIds = csioRTC.getAvailableVideoPeerIds()
        if showingVideoFromPeer == nil && !peerIds.isEmpty {
            showVideo(peerId: peerIds.first!)
        }
    }
    
    func onCsioRTCPeerMessage(peerId: String, message: String) {
        
    }
}
