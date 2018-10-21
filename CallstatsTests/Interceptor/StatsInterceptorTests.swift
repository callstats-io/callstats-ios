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
    
    // MARK:- Utils
    
    private func processStats(_ stats: [WebRTCStats]) -> [Event] {
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
