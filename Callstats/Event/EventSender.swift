//
//  EventSender.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 9/22/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

/**
 Event queue for sending events to server
 */
protocol EventSender {
    func send(event: Event)
}

class EventSenderImpl: EventSender {
    
    private let httpClient: HttpClient
    private var operationQueue: OperationQueue
    private let appID: String
    private let localID: String
    private let deviceID: String
    
    private var token: String?
    private var confID: String?
    private var ucID: String?

    var authenticatedQueue: [Event] = []
    var sessionQueue: [Event] = []
    
    init(httpClient: HttpClient, operationQueue: OperationQueue, appID: String, localID: String, deviceID: String) {
        self.httpClient = httpClient
        self.operationQueue = operationQueue
        self.appID = appID
        self.localID = localID
        self.deviceID = deviceID
    }
    
    func send(event: Event) {
        event.localID = localID
        event.deviceID = deviceID
        
        // set timestamp only if it is zero
        if event.timestamp == 0 { event.timestamp = Date().currentTimeInMillis }
        
        // if event needs session but not available yet, put in the queue
        if event is SessionEvent && ucID == nil {
            // no need to save the keep alive event
            if event is KeepAliveEvent { return }
            sessionQueue.append(event)
            return
        }
        
        // if event needs auth but not available yet, put in the queue
        if event is AuthenticatedEvent && token == nil {
            authenticatedQueue.append(event)
            return
        }
        
        // apply session information
        if let e = event as? AuthenticatedEvent {
            e.appID = appID
            e.token = token
        }
        if let e = event as? SessionEvent {
            e.ucID = ucID
            e.confID = confID
        }
        
        // send event
        let operation = EventSendingOperation(httpClient: httpClient, event: event) { [weak self] sentEvent, success, response in
            if success, let res = response, let slf = self {
                if sentEvent is AuthenticationEvent {
                    slf.token = res["access_token"] as? String
                    slf.sendAllInQueue(&slf.authenticatedQueue)
                } else if let e = sentEvent as? CreateSessionEvent {
                    slf.ucID = res["ucID"] as? String
                    slf.confID = e.confID
                    slf.sendAllInQueue(&slf.sessionQueue)
                }
            }
        }
        operationQueue.addOperation(operation)
    }
    
    private func sendAllInQueue(_ queue: inout [Event]) {
        while (queue.count != 0) {
            let event = queue.removeFirst()
            send(event: event)
        }
    }
}
