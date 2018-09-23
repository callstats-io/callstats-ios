//
//  EventTests.swift
//  CallstatsTests
//
//  Created by Amornchai Kanokpullwad on 9/23/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import XCTest
@testable import Callstats

class EventTests: XCTestCase {

    func testConvertTokenRequestToRequest() {
        let tokenRequest = TokenRequest(code: "sample_code", clientID: "client123")
        let request = tokenRequest.toRequest()!
        XCTAssertEqual(bodyToString(request), "grant_type=authorization_code&client_id=client123&code=sample_code")
    }
    
    func testConvertInvalidAuthenticatedEventToRequest() {
        let event = AuthenticatedEvent()
        XCTAssertNil(event.toRequest())
        event.appID = "app1"
        XCTAssertNil(event.toRequest())
    }
    
    func testConvertValidAuthenticatedEventToRequest() {
        let event = AuthenticatedEvent()
        event.appID = "app1"
        event.token = "1234"
        let request = event.toRequest()
        XCTAssertNotNil(request)
        XCTAssertEqual(request!.value(forHTTPHeaderField: "Authorization"), "Bearer 1234")
        XCTAssertFalse(bodyToString(request!).contains("token"))
    }
    
    func testConvertInvalidSessionEventToRequest() {
        let event = SessionEvent()
        XCTAssertNil(event.toRequest())
        event.appID = "app1"
        XCTAssertNil(event.toRequest())
        event.confID = "conf1"
        XCTAssertNil(event.toRequest())
    }
    
    func testConvertValidSessionEventToRequest() {
        let event = SessionEvent()
        event.appID = "app1"
        event.token = "1234"
        event.confID = "conf1"
        event.ucID = "uc1"
        let request = event.toRequest()
        XCTAssertNotNil(request)
        XCTAssertEqual(request!.value(forHTTPHeaderField: "Authorization"), "Bearer 1234")
        XCTAssertFalse(bodyToString(request!).contains("token"))
    }
    
    private func bodyToString(_ request: URLRequest) -> String {
        return String(data: request.httpBody!, encoding: .utf8)!
    }
}
