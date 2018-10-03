//
//  Ssrc.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/3/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation
import WebRTC

/**
 SSRC info
 */
struct Ssrc: Encodable {
    let ssrc: String
    let cname: String
    let streamType: String
    let reportType: String
    let mediaType: String
    let userID: String
    let msid: String
    let mslabel: String
    let label: String
    let localStartTime: Double
    
    init?(stats: RTCLegacyStatsReport, connection: RTCPeerConnection, localId: String, remoteId: String) {
        let isRemote = stats.reportId.contains("recv")
        let sdp = isRemote ? connection.remoteDescription : connection.localDescription
        guard let id = stats.values["ssrc"] else { return nil }
        guard let value = sdp?.ssrcValues(id: id) else { return nil }
        guard let cname = value["cname"] else { return nil }
        guard let msid = value["msid"] else { return nil }
        guard let mslabel = value["mslabel"] else { return nil }
        guard let label = value["label"] else { return nil }
        guard let mediaType = stats.values["mediaType"] else { return nil }
        self.ssrc = id
        self.cname = cname
        self.streamType = isRemote ? "inbound" : "outbound"
        self.reportType = isRemote ? "remote" : "local"
        self.mediaType = mediaType
        self.userID = isRemote ? remoteId : localId
        self.msid = msid
        self.mslabel = mslabel
        self.label = label
        self.localStartTime = stats.timestamp
    }
}
