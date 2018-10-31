//
//  DominantSpeakerEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/26/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 Using this event, you can specify the dominant speaker of the conference.
 For reference you can check this link: http://www.sciencedirect.com/science/article/pii/S0885230812000186
 */
class DominantSpeakerEvent: SessionEvent, Event, Encodable {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    
    override func path() -> String {
        return super.path() + "events/dominantspeaker"
    }
}
