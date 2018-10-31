//
//  IceInterceptorTests.swift
//  CallstatsTests
//
//  Created by Amornchai Kanokpullwad on 10/18/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import XCTest
@testable import Callstats

class IceInterceptorTests: XCTestCase {
    
    var connection: Connection!
    var interceptor: IceInterceptor!
    var stats: [WebRTCStats]!
    
    override func setUp() {
        connection = DummyConnection()
        interceptor = IceInterceptor()
        stats = [
            TestStats(id: "local", type: "localcandidate", values: [:], timestamp: 0),
            TestStats(id: "remote", type: "remotecandidate", values: [:], timestamp: 0),
            TestStats(id: "pair", type: "googCandidatePair", values: ["googActiveConnection": "true"], timestamp: 0)
        ]
    }
    
    func testIceDisruptionStart() {
        _ = processEvent(CSIceConnectionChangeEvent(state: .connected))
        let events1 = processEvent(CSIceConnectionChangeEvent(state: .disconnected))
        XCTAssertTrue(events1.contains { $0 is IceDisruptStartEvent })
        _ = processEvent(CSIceConnectionChangeEvent(state: .completed))
        let events2 = processEvent(CSIceConnectionChangeEvent(state: .disconnected))
        XCTAssertTrue(events2.contains { $0 is IceDisruptStartEvent })
    }
    
    func testIceDisruptionEnd() {
        _ = processEvent(CSIceConnectionChangeEvent(state: .disconnected))
        let events1 = processEvent(CSIceConnectionChangeEvent(state: .connected))
        XCTAssertTrue(events1.contains { $0 is IceDisruptEndEvent })
        _ = processEvent(CSIceConnectionChangeEvent(state: .disconnected))
        let events2 = processEvent(CSIceConnectionChangeEvent(state: .completed))
        XCTAssertTrue(events2.contains { $0 is IceDisruptEndEvent })
        _ = processEvent(CSIceConnectionChangeEvent(state: .disconnected))
        let events3 = processEvent(CSIceConnectionChangeEvent(state: .checking))
        XCTAssertTrue(events3.contains { $0 is IceDisruptEndEvent })
    }
    
    func testIceRestart() {
        _ = processEvent(CSIceConnectionChangeEvent(state: .completed))
        let events = processEvent(CSIceConnectionChangeEvent(state: .new))
        XCTAssertTrue(events.contains { $0 is IceRestartEvent })
    }
    
    func testIceFailed() {
        _ = processEvent(CSIceConnectionChangeEvent(state: .checking))
        let events1 = processEvent(CSIceConnectionChangeEvent(state: .failed))
        XCTAssertTrue(events1.contains { $0 is IceFailedEvent })
        _ = processEvent(CSIceConnectionChangeEvent(state: .disconnected))
        let events2 = processEvent(CSIceConnectionChangeEvent(state: .failed))
        XCTAssertTrue(events2.contains { $0 is IceFailedEvent })
    }
    
    func testIceAborted() {
        _ = processEvent(CSIceConnectionChangeEvent(state: .checking))
        let events1 = processEvent(CSIceConnectionChangeEvent(state: .closed))
        XCTAssertTrue(events1.contains { $0 is IceAbortedEvent })
        _ = processEvent(CSIceConnectionChangeEvent(state: .new))
        let events2 = processEvent(CSIceConnectionChangeEvent(state: .closed))
        XCTAssertTrue(events2.contains { $0 is IceAbortedEvent })
    }
    
    func testIceTerminated() {
        _ = processEvent(CSIceConnectionChangeEvent(state: .connected))
        let events1 = processEvent(CSIceConnectionChangeEvent(state: .closed))
        XCTAssertTrue(events1.contains { $0 is IceTerminatedEvent })
        _ = processEvent(CSIceConnectionChangeEvent(state: .completed))
        let events2 = processEvent(CSIceConnectionChangeEvent(state: .closed))
        XCTAssertTrue(events2.contains { $0 is IceTerminatedEvent })
        _ = processEvent(CSIceConnectionChangeEvent(state: .failed))
        let events3 = processEvent(CSIceConnectionChangeEvent(state: .closed))
        XCTAssertTrue(events3.contains { $0 is IceTerminatedEvent })
        _ = processEvent(CSIceConnectionChangeEvent(state: .disconnected))
        let events4 = processEvent(CSIceConnectionChangeEvent(state: .closed))
        XCTAssertTrue(events4.contains { $0 is IceTerminatedEvent })
    }
    
    func testIceConnectionDisruptStart() {
        _ = processEvent(CSIceConnectionChangeEvent(state: .checking))
        let events = processEvent(CSIceConnectionChangeEvent(state: .disconnected))
        XCTAssertTrue(events.contains { $0 is IceConnectionDisruptStartEvent })
    }
    
    func testIceConnectionDisruptEnd() {
        _ = processEvent(CSIceConnectionChangeEvent(state: .disconnected))
        let events = processEvent(CSIceConnectionChangeEvent(state: .checking))
        XCTAssertTrue(events.contains { $0 is IceConnectionDisruptEndEvent })
    }
    
    // MARK:- Utils
    
    private func processEvent(_ event: PeerEvent) -> [Event] {
        return interceptor.process(
            connection: connection,
            event: event,
            localID: "local1",
            remoteID: "remote1",
            connectionID: "con1",
            stats: stats)
    }
}

private struct DummyConnection: Connection {
    func localSessionDescription() -> String? { return "" }
    func remoteSessionDescription() -> String? { return "" }
    func getStats(_ completion: @escaping ([WebRTCStats]) -> Void) {}
}

private struct TestStats: WebRTCStats {
    let id: String
    let type: String
    let values: [String: String]
    let timestamp: Double
}
