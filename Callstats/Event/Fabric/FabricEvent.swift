//
//  FabricEvent.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 9/28/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 Base type for Fabric events
 */
class FabricEvent: SessionEvent {
    override func path() -> String {
        return super.path() + "events/fabric"
    }
}
