//
//  IceEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 10/16/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 Base type for ICE events
 */
class IceEvent: SessionEvent {
    override func path() -> String {
        return super.path() + "events/ice/status"
    }
}
