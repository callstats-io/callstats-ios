//
//  CallstatsInjector.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 9/22/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

class CallstatsInjector {
    
    func httpClient() -> HttpClient {
        return HttpClientImpl()
    }
    
    func operationQueue() -> OperationQueue {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }
    
    func eventSender(appID: String, localID: String, deviceID: String) -> EventSender {
        return EventSenderImpl(
            httpClient: httpClient(),
            operationQueue: operationQueue(),
            appID: appID,
            localID: localID,
            deviceID: deviceID)
    }
    
    func eventManager(
        sender: EventSender,
        localID: String,
        remoteID: String,
        connection: Connection,
        config: CallstatsConfig) -> EventManager
    {
        let interceptors = [FabricInterceptor()]
        return EventManagerImpl(
            sender: sender,
            localID: localID,
            remoteID: remoteID,
            connection: connection,
            config: config,
            interceptors: interceptors)
    }
    
    func systemStatusProvider() -> SystemStatusProvider {
        return SystemStatusProviderImpl()
    }
}
