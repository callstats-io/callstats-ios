//
//  FabricSetupEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/3/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 This should be sent during initial fabric setup phase. After this connection is setup and you can send data
 */
class FabricSetupEvent: FabricEvent, Event, Encodable {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    
    let remoteID: String
    let connectionID: String
    
    /**
     Total time to setup a conference for the participant.
     The time when the user joins until the chosen candidate pair is connected (setup/failure)
     */
    var delay: Int64?
    
    /**
     The time taken for the ICE gathering to finish (ICE gathering state from new to complete)
     */
    var iceGatheringDelay: Int64?
    
    /**
     The time taken for the ICE to establish the connectivity (ICE connection state new to connected/completed)
     */
    var iceConnectivityDelay: Int64?
    
    /**
     Stream flow direction inside the fabric.
     "sendonly", "receiveonly" or "sendrecv"
     Default is ""sendrecv""
     */
    var fabricTransmissionDirection = "sendrecv"
    
    /**
     Type of remote endpoint a fabric was established to.
     "peer" or "server"
     Default is "peer".
     */
    var remoteEndpointType = "peer"
    
    /**
     ID of the selected candidate pair
     */
    var selectedCandidatePairID: String?
    
    var localIceCandidates: [IceCandidate] = []
    var remoteIceCandidates: [IceCandidate] = []
    var iceCandidatePairs: [IceCandidatePair] = []
    
    init(remoteID: String, connectionID: String) {
        self.remoteID = remoteID
        self.connectionID = connectionID
    }
    
    override func path() -> String {
        return super.path() + "/setup"
    }
}
