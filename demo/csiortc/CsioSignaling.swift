//
//  CsioSignaling.swift
//  demo
//
//  Created by Amornchai Kanokpullwad on 5/13/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation
import SocketIO

let kSignalingUrl = "https://demo.callstats.io"

class CsioSignaling {
    
    weak var delegate: CsioSignalingDelegate?
    
    private let eventJoin = "join"
    private let eventLeave = "leave"
    private let eventMessage = "message"
    
    private let manager = SocketManager(socketURL: URL(string: kSignalingUrl)!, config: [.log(true)])
    private let socket: SocketIOClient
    
    init(room: String) {
        socket = manager.defaultSocket
        
        socket.on(clientEvent: .connect) { _, _ in
            print("connected")
            self.socket.emit(self.eventJoin, room)
            self.delegate?.onConnect()
        }
        
        socket.on(clientEvent: .error) { _, _ in
            print("error")
            self.socket.disconnect()
            self.delegate?.onConnectError()
        }
        
        socket.on(eventJoin) { data, _ in
            let user = data[0] as! String
            print("user joined : \(user)")
            self.delegate?.onPeerJoin(peerId: user)
        }
        
        socket.on(eventLeave) { data, _ in
            let user = data[0] as! String
            print("user left : \(user)")
            self.delegate?.onPeerLeave(peerId: user)
        }
        
        socket.on(eventMessage) { data, _ in
            let user = data[0] as! String
            let msg = data[1] as! String
            print("receive message from \(user)")
            self.delegate?.onMessage(fromId: user, message: msg)
        }
    }
    
    func start() {
        socket.connect()
    }
    
    func stop() {
        socket.emit(eventLeave)
        manager.disconnect()
    }
    
    func send(toId: String, message: String) {
        socket.emit(eventMessage, toId, message)
        print("sent message to \(toId) : \(message)")
    }
}
