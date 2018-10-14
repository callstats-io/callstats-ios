//
//  CallstatsTests.swift
//  CallstatsTests
//
//  Created by Amornchai Kanokpullwad on 9/21/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import XCTest
@testable import Callstats

class CallstatsTests: XCTestCase {
    
    private var sender: MockEventSender!
    private var config: CallstatsConfig!
    var callstats: Callstats!

    override func setUp() {
        config = CallstatsConfig()
        config.keepAlivePeriod = 1
        sender = MockEventSender()
        Callstats.dependency = TestInjector(sender: sender)
        callstats = Callstats(
            appID: "app",
            localID: "local",
            deviceID: "device",
            jwt: "code",
            username: nil,
            clientVersion: nil,
            configuration: config)
    }

    func testCreateObjectWillDoAuthentication() {
        XCTAssertTrue(sender.lastSendEvent is TokenRequest)
    }
    
    func testStartSessionSendSessionCreateEvent() {
        callstats.startSession(confID: "conf1")
        XCTAssertTrue(sender.lastSendEvent is CreateSessionEvent)
    }
    
    func testStartSessionSendKeepAliveEvent() {
        callstats.startSession(confID: "conf1")
        let exp = expectation(description: "send ping")
        let result = XCTWaiter.wait(for: [exp], timeout: config.keepAlivePeriod + 3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(self.sender.lastSendEvent is KeepAliveEvent)
        } else {
            XCTFail()
        }
    }
    
    func testStopSessionSendUserLeftEvent() {
        callstats.stopSession()
        XCTAssertTrue(sender.lastSendEvent is UserLeftEvent)
    }
}

class TestInjector: CallstatsInjector {
    let sender: EventSender
    init(sender: EventSender) {
        self.sender = sender
    }
    override func eventSender(appID: String, localID: String, deviceID: String) -> EventSender {
        return sender
    }
}

private class MockEventSender: EventSender {
    var lastSendEvent: Event?
    func send(event: Event) {
        lastSendEvent = event
    }
}
