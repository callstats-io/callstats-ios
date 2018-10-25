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
    private var manager: MockEventManager!
    private var config: CallstatsConfig!
    var callstats: Callstats!

    override func setUp() {
        config = CallstatsConfig()
        sender = MockEventSender()
        manager = MockEventManager()
        Callstats.dependency = TestInjector(sender: sender, manager: manager)
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
        config.keepAlivePeriod = 1
        config.systemStatsSubmissionPeriod = 1000
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
    
    func testStartSessionSendSystemStats() {
        config.keepAlivePeriod = 1000
        config.systemStatsSubmissionPeriod = 1
        callstats.startSession(confID: "conf1")
        let exp = expectation(description: "send system stats")
        let result = XCTWaiter.wait(for: [exp], timeout: config.systemStatsSubmissionPeriod + 3)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(self.sender.lastSendEvent is SystemStatusStats)
        } else {
            XCTFail()
        }
    }
    
    func testAddNewFabricCreateManager() {
        callstats.addNewFabric(connection: DummyConnection(), remoteID: "remote1")
        callstats.addNewFabric(connection: DummyConnection(), remoteID: "remote1")
        XCTAssertEqual(callstats.eventManagers.count, 1)
    }
    
    func testReportPeerEvent() {
        callstats.addNewFabric(connection: DummyConnection(), remoteID: "remote1")
        callstats.reportEvent(remoteUserID: "remote1", event: CSIceConnectionChangeEvent(state: .completed))
        XCTAssertTrue(manager.lastProcessEvent is CSIceConnectionChangeEvent)
    }
    
    func testReportAppEvent() {
        callstats.addNewFabric(connection: DummyConnection(), remoteID: "remote1")
        callstats.reportEvent(event: CSDominantSpeakerEvent())
        XCTAssertTrue(sender.lastSendEvent is DominantSpeakerEvent)
    }
    
    func testLog() {
        callstats.log(message: "msg")
        let event = sender.lastSendEvent as? LogEvent
        XCTAssertNotNil(event)
        XCTAssertTrue(event?.level == "info")
        XCTAssertTrue(event?.messageType == "text")
    }
}

class TestInjector: CallstatsInjector {
    let sender: EventSender
    let manager: EventManager
    
    init(sender: EventSender, manager: EventManager) {
        self.sender = sender
        self.manager = manager
    }
    
    override func eventSender(appID: String, localID: String, deviceID: String) -> EventSender {
        return sender
    }
    
    override func eventManager(sender: EventSender, localID: String, remoteID: String, connection: Connection, config: CallstatsConfig) -> EventManager {
        return manager
    }
}

private class MockEventSender: EventSender {
    var lastSendEvent: Event?
    func send(event: Event) {
        lastSendEvent = event
    }
}

private class MockEventManager: EventManager {
    var lastProcessEvent: PeerEvent?
    func process(event: PeerEvent) {
        lastProcessEvent = event
    }
}

private struct DummyConnection: Connection {
    func localSessionDescription() -> String? { return "" }
    func remoteSessionDescription() -> String? { return "" }
    func getStats(_ completion: @escaping ([WebRTCStats]) -> Void) {}
}
