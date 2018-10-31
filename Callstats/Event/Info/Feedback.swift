//
//  Feedback.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/3/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 Feedback info
 */
struct Feedback: Encodable {
    let overallRating: Int
    
    /**
     It is provided by the developer.
     Non-empty remoteID means that the feedback was given explicitly about the connection between these two parties.
     Otherwise it is regarded as general conference feedback.
     */
    let remoteID: String?
    
    /// Rating from 1 to 5
    let videoQualityRating: Int?
    
    /// Rating from 1 to 5
    let audioQualityRating: Int?
    
    /// Comments from the participant
    let comments: String?
}
