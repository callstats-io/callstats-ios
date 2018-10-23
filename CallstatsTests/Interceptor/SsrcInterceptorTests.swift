//
//  SsrcInterceptorTests.swift
//  CallstatsTests
//
//  Created by Amornchai Kanokpullwad on 10/23/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import XCTest
@testable import Callstats

class SsrcInterceptorTests: XCTestCase {
    
    var connection: Connection!
    var interceptor: SsrcInterceptor!
    
    override func setUp() {
        connection = FakeConnection()
        interceptor = SsrcInterceptor()
    }
    
    func testSendSsrcEventWhenAddStream() {
        let events = interceptor.process(
            connection: connection,
            event: CSAddStreamEvent(),
            localID: "local1",
            remoteID: "remote1",
            connectionID: "conn1",
            stats: [
                TestStats(
                    id: "ssrc_1234_send",
                    type: "ssrc",
                    values: [
                        "ssrc": "1234",
                        "mediaType": "audio"
                    ],
                    timestamp: 0)
            ])
        XCTAssertTrue(events.contains { $0 is SsrcEvent })
    }
    
    func testSendSsrcEventWhenIceConnected() {
        let events = interceptor.process(
            connection: connection,
            event: CSIceConnectionChangeEvent(state: .connected),
            localID: "local1",
            remoteID: "remote1",
            connectionID: "conn1",
            stats: [
                TestStats(
                    id: "ssrc_1234_send",
                    type: "ssrc",
                    values: [
                        "ssrc": "1234",
                        "mediaType": "audio"
                    ],
                    timestamp: 0)
            ])
        XCTAssertTrue(events.contains { $0 is SsrcEvent })
    }
    
    func testNotSendSsrcEventWhenIceConnectedAgain() {
        _ = interceptor.process(
            connection: connection,
            event: CSIceConnectionChangeEvent(state: .connected),
            localID: "local1",
            remoteID: "remote1",
            connectionID: "conn1",
            stats: [])
        let events = interceptor.process(
            connection: connection,
            event: CSIceConnectionChangeEvent(state: .connected),
            localID: "local1",
            remoteID: "remote1",
            connectionID: "conn1",
            stats: [
                TestStats(
                    id: "ssrc_1234_send",
                    type: "ssrc",
                    values: [
                        "ssrc": "1234",
                        "mediaType": "audio"
                    ],
                    timestamp: 0)
            ])
        XCTAssertFalse(events.contains { $0 is SsrcEvent })
    }
}

private class FakeConnection: Connection {
    
    func localSessionDescription() -> String? {
        return """
        a=ssrc:1234 cname:4TOk42mSjXCkVIa6
        a=ssrc:1234 msid:lgsCFqt9kN2fVKw5wg3NKqGdATQoltEwOdMS 35429d94-5637-4686-9ecd-7d0622261ce8
        a=ssrc:1234 mslabel:lgsCFqt9kN2fVKw5wg3NKqGdATQoltEwOdMS
        a=ssrc:1234 label:35429d94-5637-4686-9ecd-7d0622261ce8
        """
    }
    
    func remoteSessionDescription() -> String? { return "v=0 remote" }
    func getStats(_ completion: @escaping ([WebRTCStats]) -> Void) {}
}

private struct TestStats: WebRTCStats {
    let id: String
    let type: String
    let values: [String: String]
    let timestamp: Double
}
