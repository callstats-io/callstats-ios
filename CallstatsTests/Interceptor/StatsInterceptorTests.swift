//
//  StatsInterceptorTests.swift
//  CallstatsTests
//
//  Created by Amornchai Kanokpullwad on 10/21/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import XCTest
@testable import Callstats

class StatsInterceptorTests: XCTestCase {
    
    var connection: Connection!
    var interceptor: StatsInterceptor!
    
    override func setUp() {
        connection = DummyConnection()
        interceptor = StatsInterceptor()
        _ = interceptor.process(
            connection: connection,
            event: CSIceConnectionChangeEvent(state: .connected),
            localID: "local1",
            remoteID: "remote1",
            connectionID: "connection1",
            stats: [])
    }
    
    func testSendConferenceStats() {
        let events = processStats([])
        XCTAssertTrue(events.contains { $0 is ConferenceStats })
    }
    
    func testSendCsioAvgBRKbps() {
        let outEvents = processStats([TestOutboundStats()])
        let outEvent = outEvents.first as? ConferenceStats
        XCTAssertNotNil(outEvent)
        XCTAssertTrue(outEvent!.stats.contains { stat -> Bool in stat.keys.contains("csioAvgBRKbps") })
        let inEvents = processStats([TestInboundStats()])
        let inEvent = inEvents.first as? ConferenceStats
        XCTAssertNotNil(inEvent)
        XCTAssertTrue(inEvent!.stats.contains { stat -> Bool in stat.keys.contains("csioAvgBRKbps") })
    }
    
    func testSendCsioIntBRKbps() {
        _ = processStats([])
        let outEvents = processStats([TestOutboundStats()])
        let outEvent = outEvents.first as? ConferenceStats
        XCTAssertNotNil(outEvent)
        XCTAssertTrue(outEvent!.stats.contains { stat -> Bool in stat.keys.contains("csioIntBRKbps") })
        let inEvents = processStats([TestInboundStats()])
        let inEvent = inEvents.first as? ConferenceStats
        XCTAssertNotNil(inEvent)
        XCTAssertTrue(inEvent!.stats.contains { stat -> Bool in stat.keys.contains("csioIntBRKbps") })
    }
    
    func testOutboundSendCsioAvgRtt() {
        let events = processStats([TestOutboundStats()])
        let event = events.first as? ConferenceStats
        XCTAssertNotNil(event)
        XCTAssertTrue(event!.stats.contains { stat -> Bool in stat.keys.contains("csioAvgRtt") })
    }
    
    func testOutboundSendCsioIntMs() {
        _ = processStats([])
        let events = processStats([TestOutboundStats()])
        let event = events.first as? ConferenceStats
        XCTAssertNotNil(event)
        XCTAssertTrue(event!.stats.contains { stat -> Bool in stat.keys.contains("csioIntMs") })
    }
    
    func testOutboundSendCsioTimeElapseMs() {
        let events = processStats([TestOutboundStats()])
        let event = events.first as? ConferenceStats
        XCTAssertNotNil(event)
        XCTAssertTrue(event!.stats.contains { stat -> Bool in stat.keys.contains("csioTimeElapseMs") })
    }
    
    func testInboundSendCsioAvgJitter() {
        let events = processStats([TestInboundStats()])
        let event = events.first as? ConferenceStats
        XCTAssertNotNil(event)
        XCTAssertTrue(event!.stats.contains { stat -> Bool in stat.keys.contains("csioAvgJitter") })
    }
    
    func testInboundSendCsioIntFL() {
        let events = processStats([TestInboundStats()])
        let event = events.first as? ConferenceStats
        XCTAssertNotNil(event)
        XCTAssertTrue(event!.stats.contains { stat -> Bool in stat.keys.contains("csioIntFL") })
    }
    
    func testInboundSendCsioIntPktLoss() {
        let events = processStats([TestInboundStats()])
        let event = events.first as? ConferenceStats
        XCTAssertNotNil(event)
        XCTAssertTrue(event!.stats.contains { stat -> Bool in stat.keys.contains("csioIntPktLoss") })
    }
    
    // MARK:- Utils
    
    private func processStats(_ stats: [WebRTCStats]) -> [Event] {
        Thread.sleep(forTimeInterval: 0.1)
        return interceptor.process(
            connection: connection,
            event: CSStatsEvent(),
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

private struct TestOutboundStats: WebRTCStats {
    let id = "ssrc_1234_send"
    let type = "ssrc"
    let values = [
        "googRtt": "1",
        "bytesSent": "1"
    ]
    let timestamp = 0.0
}

private struct TestInboundStats: WebRTCStats {
    let id = "ssrc_1234_recv"
    let type = "ssrc"
    let values = [
        "googJitterReceived": "1",
        "bytesReceived": "1",
        "packetsReceived": "1",
        "packetsLost": "1"
    ]
    let timestamp = 0.0
}
