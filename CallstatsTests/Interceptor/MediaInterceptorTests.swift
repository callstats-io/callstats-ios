//
//  MediaInterceptorTests.swift
//  CallstatsTests
//
//  Created by Amornchai Kanokpullwad on 10/24/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

import XCTest
@testable import Callstats

class MediaInterceptorTests: XCTestCase {

    var connection: Connection!
    var interceptor: MediaInterceptor!
    
    override func setUp() {
        connection = FakeConnection()
        interceptor = MediaInterceptor()
    }
    
    func testSendMediaActionsAudioMute() {
        let events = interceptor.process(
            connection: connection,
            event: CSMediaEvent(type: .audio, enable: false, deviceID: "device1"),
            localID: "local1",
            remoteID: "remote1",
            connectionID: "conn1",
            stats: [])
        XCTAssertTrue(events.contains {
            $0 is MediaActionEvent && ($0 as! MediaActionEvent).eventType == MediaActionEvent.EventType.mute.rawValue
        })
    }
    
    func testSendMediaActionsVideoResume() {
        let events = interceptor.process(
            connection: connection,
            event: CSMediaEvent(type: .video, enable: true, deviceID: "device1"),
            localID: "local1",
            remoteID: "remote1",
            connectionID: "conn1",
            stats: [])
        XCTAssertTrue(events.contains {
            $0 is MediaActionEvent && ($0 as! MediaActionEvent).eventType == MediaActionEvent.EventType.videoResume.rawValue
        })
    }
    
    func testSendMediaActionsScreenStart() {
        let events = interceptor.process(
            connection: connection,
            event: CSMediaEvent(type: .screen, enable: true, deviceID: "device1"),
            localID: "local1",
            remoteID: "remote1",
            connectionID: "conn1",
            stats: [])
        XCTAssertTrue(events.contains {
            $0 is MediaActionEvent && ($0 as! MediaActionEvent).eventType == MediaActionEvent.EventType.screenStart.rawValue
        })
    }
    
    func testSendMediaPlayback() {
        let events = interceptor.process(
            connection: connection,
            event: CSPlaybackEvent(mediaType: .audio, eventType: .start),
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
        XCTAssertTrue(events.contains { $0 is MediaPlaybackEvent })
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
