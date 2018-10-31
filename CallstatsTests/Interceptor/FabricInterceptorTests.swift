//
//  FabricInterceptorTests.swift
//  CallstatsTests
//
//  Created by Amornchai Kanokpullwad on 10/6/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import XCTest
import WebRTC
@testable import Callstats

class FabricInterceptorTests: XCTestCase {
    
    var connection: Connection!
    var interceptor: FabricInterceptor!
    
    override func setUp() {
        connection = DummyConnection()
        interceptor = FabricInterceptor()
    }
    
    func testSendFabricSetup() {
        let events = interceptor.process(
            connection: connection,
            event: CSIceConnectionChangeEvent(state: .connected),
            localID: "local1",
            remoteID: "remote1",
            connectionID: "con1",
            stats: [])
        XCTAssertEqual(events.count, 2)
        XCTAssertTrue(events.contains { $0 is FabricSetupEvent })
    }
    
    func testSendFabricSetupOnlyFirstTime() {
        connected()
        let events = interceptor.process(
            connection: connection,
            event: CSIceConnectionChangeEvent(state: .connected),
            localID: "local1",
            remoteID: "remote1",
            connectionID: "con1",
            stats: [])
        XCTAssertEqual(events.count, 0)
    }
    
    func testSendFabricTransportChange() {
        connected()
        let stats = [
            TestStats(id: "local", type: "localcandidate", values: [:], timestamp: 0),
            TestStats(id: "remote", type: "remotecandidate", values: [:], timestamp: 0),
            TestStats(id: "pair", type: "googCandidatePair", values: ["googActiveConnection": "true"], timestamp: 0)
        ]
        let events = interceptor.process(
            connection: connection,
            event: CSIceConnectionChangeEvent(state: .connected),
            localID: "local1",
            remoteID: "remote1",
            connectionID: "con1",
            stats: stats)
        XCTAssertEqual(events.count, 1)
        XCTAssertTrue(events.contains { $0 is FabricTransportChangeEvent })
    }
    
    func testSendFabricStateChange() {
        let events = interceptor.process(
            connection: connection,
            event: CSIceConnectionChangeEvent(state: .checking),
            localID: "local1",
            remoteID: "remote1",
            connectionID: "con1",
            stats: [])
        XCTAssertEqual(events.count, 1)
        XCTAssertTrue(events.contains { $0 is FabricStateChangeEvent })
    }
    
    func testSendFabricAction() {
        connected()
        let events = interceptor.process(
            connection: connection,
            event: CSHoldEvent(),
            localID: "local1",
            remoteID: "remote1",
            connectionID: "con1",
            stats: [])
        XCTAssertEqual(events.count, 1)
        XCTAssertTrue(events.contains { $0 is FabricActionEvent })
        let events2 = interceptor.process(
            connection: connection,
            event: CSResumeEvent(),
            localID: "local1",
            remoteID: "remote1",
            connectionID: "con1",
            stats: [])
        XCTAssertEqual(events2.count, 1)
        XCTAssertTrue(events2.contains { $0 is FabricActionEvent })
    }
    
    // MARK:- Utils
    
    private func connected() {
        let stats = [
            TestStats(id: "local", type: "localcandidate", values: [:], timestamp: 0),
            TestStats(id: "remote", type: "remotecandidate", values: [:], timestamp: 0),
            TestStats(id: "pair", type: "googCandidatePair", values: ["googActiveConnection": "true"], timestamp: 0)
        ]
        _ = interceptor.process(
            connection: connection,
            event: CSIceConnectionChangeEvent(state: .connected),
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
