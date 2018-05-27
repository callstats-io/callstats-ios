//
//  CsioRTCDelegate.swift
//  demo
//
//  Created by Amornchai Kanokpullwad on 5/13/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

protocol CsioRTCDelegate: class {
    func onCsioRTCConnect()
    func onCsioRTCError()
    func onCsioRTCPeerUpdate()
    func onCsioRTCPeerVideoAvailable()
    func onCsioRTCPeerMessage(peerId: String, message: String)
}
