//
//  EventSenderTest.swift
//  CallstatsTests
//
//  Created by Amornchai Kanokpullwad on 9/28/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import XCTest
@testable import Callstats

class EventSenderTests: XCTestCase {
    
    private var operationQueue: FakeOperationQueue!
    private var sender: EventSenderImpl!
    
    override func setUp() {
        operationQueue = FakeOperationQueue()
        sender = EventSenderImpl(
            httpClient: DummyHttpClient(),
            operationQueue: operationQueue,
            appID: "app1",
            localID: "local1",
            deviceID: "device1")
    }
    
    func testEventHasCorrectInfo() {
        let event = TestEvent()
        sender.send(event: event)
        XCTAssertEqual(event.localID, "local1")
        XCTAssertEqual(event.deviceID, "device1")
    }
    
    func testEventWillNotOverrideTimeStamp() {
        let event = TestEvent()
        event.timestamp = 123
        sender.send(event: event)
        XCTAssertEqual(event.timestamp, 123)
        event.timestamp = 0
        sender.send(event: event)
        XCTAssertNotEqual(event.timestamp, 0)
    }
    
    func testSendEventBeforeNeededState() {
        sender.send(event: UserJoinEvent(confID: "conf1"))
        sender.send(event: FabricTerminatedEvent(remoteID: "remote1", connectionID: "con1"))
        XCTAssertEqual(sender.authenticatedQueue.count, 1)
        XCTAssertEqual(sender.sessionQueue.count, 1)
    }
    
    func testSendEventInCorrectOrder() {
        sender.send(event: TestSessionEvent())
        sender.send(event: TestCreateSessionEvent())
        sender.send(event: TokenRequest(code: "code", clientID: "client"))
        XCTAssertTrue(operationQueue.sentOperations[0].event is TokenRequest)
        XCTAssertTrue(operationQueue.sentOperations[1].event is AuthenticatedEvent)
        XCTAssertTrue(operationQueue.sentOperations[2].event is SessionEvent)
    }
    
    func testNotSaveKeepAliveEvent() {
        sender.send(event: UserAliveEvent())
        XCTAssertEqual(sender.sessionQueue.count, 0)
    }
}

private class DummyHttpClient: HttpClient {
    func sendRequest(request: URLRequest, completion: @escaping (Response) -> Void) {}
}

private class FakeOperationQueue: OperationQueue {
    var sentOperations: [EventSendingOperation] = []
    override func addOperation(_ op: Operation) {
        if let operation = op as? EventSendingOperation {
            sentOperations.append(operation)
            let data: [String: Any]
            switch operation.event {
            case is AuthenticationEvent: data = ["access_token": "1234"]
            case is CreateSessionEvent: data = ["ucID": "5678"]
            default: data = [:]
            }
            operation.completion?(operation.event, true, data)
        }
    }
}

private class TestEvent: Event {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    func url() -> String { return "" }
    func path() -> String { return "" }
}

private class TestCreateSessionEvent: AuthenticatedEvent, CreateSessionEvent, Event {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
    var confID: String = "conf1"
}

private class TestSessionEvent: SessionEvent, Event {
    var localID: String = ""
    var deviceID: String = ""
    var timestamp: Int64 = 0
}
