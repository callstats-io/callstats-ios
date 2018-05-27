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
    var name = "ios_murdock"
    
    @IBOutlet weak var aliasLabel: UILabel!
    @IBOutlet weak var participantCountLabel: UILabel!
    @IBOutlet weak var localVideoView: CsioRTCVideoView!
    @IBOutlet weak var remoteVideoView: CsioRTCVideoView!
    @IBOutlet weak var chatBackgroundView: UIView!
    @IBOutlet var chatView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chatTextField: UITextField!
    
    private var csioRTC: CsioRTC!
    private var peerIds: [String] = []
    private var messages: [String] = []
    
    // current renderer
    private var showingVideoFromPeer: String?
    
    private let chatDrawerWidth: CGFloat = 260
    private var chatDrawerConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatInputBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if room == "" { return }
        UIApplication.shared.isIdleTimerDisabled = true
        
        // views
        chatView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(chatView, at: 0)
        chatDrawerConstraint = chatView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: chatDrawerWidth)
        chatDrawerConstraint.isActive = true
        chatView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        chatView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        chatView.widthAnchor.constraint(equalToConstant: chatDrawerWidth).isActive = true
        
        aliasLabel.text = "Your name : \(name)"
        
        csioRTC = CsioRTC(room: room)
        csioRTC.delegate = self
        csioRTC.join()
        csioRTC.renderLocalVideo(view: localVideoView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(noti:)),
            name: .UIKeyboardWillShow,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillBeHidden),
            name: .UIKeyboardWillHide,
            object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(
            self,
            name: .UIKeyboardWillShow,
            object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: .UIKeyboardWillHide,
            object: nil)
        
        csioRTC.leave()
        presentingViewController?.dismiss(animated: false, completion: nil)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    private func showVideo(peerId: String) {
        if peerId == showingVideoFromPeer { return }
        if let peer = showingVideoFromPeer {
            csioRTC.removeRemoteVideoRenderer(peerId: peer, view: remoteVideoView)
        }
        
        showingVideoFromPeer = peerId
        csioRTC.addRemoteVideoRenderer(peerId: peerId, view: remoteVideoView)
    }
    
    private func showMessage(name: String, message: String) {
        messages.append("\(name) : \(message)")
        tableView.reloadData()
        tableView.scrollToRow(
            at: IndexPath(row: messages.count - 1, section: 0),
            at: .bottom,
            animated: true)
    }
    
    // MARK:- Keyboard
    
    @objc private func keyboardWillShow(noti: Notification) {
        guard let value = noti.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
        let height = value.cgRectValue.height
        chatInputBottomConstraint.constant = -height
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillBeHidden() {
        chatInputBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK:- Actions
    
    @IBAction func chatButtonPressed(_ sender: Any) {
        chatBackgroundView.isHidden = false
        chatBackgroundView.alpha = 0
        view.bringSubview(toFront: chatBackgroundView)
        view.bringSubview(toFront: chatView)
        
        chatDrawerConstraint.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.chatBackgroundView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func chatBackgroundPressed(_ sender: Any) {
        view.endEditing(true)
        chatDrawerConstraint.constant = chatDrawerWidth
        UIView.animate(withDuration: 0.5, animations: {
            self.chatBackgroundView.alpha = 0
            self.view.layoutIfNeeded()
        }) { _ in self.chatBackgroundView.isHidden = true }
    }
    
    @IBAction func chatSendButtonPressed(_ sender: Any) {
        let text = chatTextField.text ?? ""
        if !text.isEmpty {
            csioRTC.sendMessage(message: text)
            showMessage(name: name, message: text)
            chatTextField.text = ""
        }
    }
    
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
    
    //MARK:- CsioRTC delegate
    
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
        DispatchQueue.main.async {
            self.showMessage(name: peerId, message: message)
        }
    }
}

extension CallViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = messages[indexPath.row]
        return cell
    }
}
