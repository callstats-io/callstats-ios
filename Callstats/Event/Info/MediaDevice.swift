//
//  MediaDevice.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 9/28/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 Media Device info
 */
struct MediaDevice: Encodable {
    
    /// "audioinput" "audiooutput" "videoinput"
    let kind: String
    
    ///  Group identifier of the device (note: two devices belong to the same group identifier only if they belong to the same physical device)
    let groupID: String
}
