//
//  MediaEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/24/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 Base class for media events
 */
class MediaEvent: SessionEvent {
    override func path() -> String {
        return super.path() + "events/media"
    }
}
