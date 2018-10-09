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
    var callstats: Callstats!

    override func setUp() {
        sender = MockEventSender()
        Callstats.dependency = TestInjector(sender: sender)
        callstats = Callstats(appID: "app", localID: "local", deviceID: "device", jwt: "code")
    }

    func testCreateObjectWillDoAuthentication() {
        XCTAssertTrue(sender.lastSendEvent is TokenRequest)
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
