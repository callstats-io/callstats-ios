//
//  EventManagerTests.swift
//  CallstatsTests
//
//  Created by Amornchai Kanokpullwad on 10/9/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import XCTest
@testable import Callstats

class EventManagerTests: XCTestCase {
    
    private var interceptor1: MockInterceptor!
    private var interceptor2: MockInterceptor!
    var sender: EventSender!
    var manager: EventManager!
    
    override func setUp() {
        interceptor1 = MockInterceptor()
        interceptor2 = MockInterceptor()
        sender = MockEventSender()
        manager = EventManagerImpl(
            sender: sender,
            localID: "local1",
            remoteID: "remote1",
            connection: DummyConnection(),
            config: CallstatsConfig(),
            interceptors: [interceptor1, interceptor2])
    }
    
    func testForwardEventToAllInterceptor() {
        manager.process(event: CSIceConnectionChangeEvent(state: .disconnected))
        XCTAssertTrue(interceptor1.lastProcess?.event is CSIceConnectionChangeEvent)
        XCTAssertTrue(interceptor2.lastProcess?.event is CSIceConnectionChangeEvent)
    }
}

private class MockEventSender: EventSender {
    var lastSendEvent: Event?
    func send(event: Event) {
        lastSendEvent = event
    }
}

private class MockInterceptor: Interceptor {
    var lastProcess: (connection: Connection, event: PeerEvent, localID: String, remoteID: String, connectionID: String, stats: [WebRTCStats])?
    func process(connection: Connection, event: PeerEvent, localID: String, remoteID: String, connectionID: String, stats: [WebRTCStats]) -> [Event] {
        lastProcess = (connection, event, localID, remoteID, connectionID, stats)
        return []
    }
}

private struct DummyConnection: Connection {
    func localSessionDescription() -> String? { return "" }
    func remoteSessionDescription() -> String? { return "" }
    func getStats(_ completion: @escaping ([WebRTCStats]) -> Void) { completion([]) }
}
