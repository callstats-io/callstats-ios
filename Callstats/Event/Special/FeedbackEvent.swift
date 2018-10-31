//
//  FeedbackEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/27/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 You can submit overall rating to conference and add comments as well.
 It is also possible to give separate ratings for audio and video.
 */
class FeedbackEvent: SessionEvent, Event, Encodable {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    
    let feedback: Feedback
    
    init(feedback: Feedback) {
        self.feedback = feedback
    }
    
    override func path() -> String {
        return super.path() + "events/feedback"
    }
}
