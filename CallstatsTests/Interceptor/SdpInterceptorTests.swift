//
//  SdpInterceptorTests.swift
//  CallstatsTests
//
//  Created by Amornchai Kanokpullwad on 10/16/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import XCTest
@testable import Callstats

class SdpInterceptorTests: XCTestCase {

    var connection: Connection!
    var interceptor: SdpInterceptor!
    
    override func setUp() {
        connection = FakeConnection()
        interceptor = SdpInterceptor()
    }
    
    func testSendSdpEvent() {
        let events = interceptor.process(
            connection: connection,
            event: CSIceConnectionChangeEvent(state: .connected),
            localID: "local1",
            remoteID: "remote1",
            connectionID: "conn1",
            stats: [])
        XCTAssertTrue(events.contains { $0 is SdpEvent })
    }
}

private class FakeConnection: Connection {
    func localSessionDescription() -> String? { return "v=0 local" }
    func remoteSessionDescription() -> String? { return "v=0 remote" }
    func getStats(_ completion: @escaping ([WebRTCStats]) -> Void) {}
}
