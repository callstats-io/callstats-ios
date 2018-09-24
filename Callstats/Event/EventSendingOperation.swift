//
//  EventSendingOperation.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 9/23/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

typealias EventSendingCompletion = (Event, Bool, [String: Any]?) -> Void

/**
 Operation to send event
 */
class EventSendingOperation: Operation {
    
    let httpClient: HttpClient
    let event: Event
    let completion: EventSendingCompletion?
    
    init(httpClient: HttpClient, event: Event, completion: EventSendingCompletion?) {
        self.httpClient = httpClient
        self.event = event
        self.completion = completion
    }
    
    override func start() {
        guard let request = event.toRequest() else {
            completion?(event, false, nil)
            return
        }
        
        httpClient.sendRequest(request: request) { response in
            switch response {
            case .error(let reason):
                NSLog("Operation error : %@", reason)
                self.completion?(self.event, false, nil)
            case .failed(_, let dict):
                NSLog("Operation failed : %@", dict?.description ?? "[]")
                self.completion?(self.event, false, dict)
            case .success(_, let dict):
                NSLog("Operation success : %@", dict?.description ?? "[]")
                self.completion?(self.event, true, dict)
            }
        }
    }
}
