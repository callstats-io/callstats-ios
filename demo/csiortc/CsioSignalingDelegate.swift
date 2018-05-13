//
//  CsioSignalingDelegate.swift
//  demo
//
//  Created by Amornchai Kanokpullwad on 5/13/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

protocol CsioSignalingDelegate : class {
    func onConnect()
    func onConnectError()
    func onPeerJoin(peerId: String)
    func onPeerLeave(peerId: String)
    func onMessage(fromId: String, message: String)
}
