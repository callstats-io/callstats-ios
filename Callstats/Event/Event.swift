//
//  Event.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 9/22/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

private let kHeaderAuthorization = "Authorization"
private let kHeaderContentType = "Content-Type"
private let kContentTypeJson = "application/json; charset=utf-8"
private let kContentTypeFormUrl = "application/x-www-form-urlencoded"

protocol Requestable {
    func url() -> String
    func path() -> String
}

/**
 Base event
 */
protocol Event: class, Requestable {
    var localID: String { get set }
    var deviceID: String { get set }
    var timestamp: Int64 { get set }
}

/**
 Event that do authentication
 */
protocol AuthenticationEvent {
    var code: String { get }
    var clientID: String { get }
    var grantType: String { get }
}

/**
 Event to create session
 */
protocol CreateSessionEvent {
    var confID: String { get }
    var appID: String? { get }
}

/**
 Event that can be sent only after authenticated
 */
class AuthenticatedEvent: Requestable {
    var appID: String?
    var token: String?
    func url() -> String { return "https://events.callstats.io" }
    func path() -> String { return "v1/apps/\(appID!)/" }
}

/**
 Event that can be sent after session created
 */
class SessionEvent: AuthenticatedEvent {
    var ucID: String?
    var confID: String?
    override func path() -> String { return "v1/apps/\(appID!)/conferences/\(confID!)/\(ucID!)/" }
}

/**
 Event to keep the session alive
 */
class KeepAliveEvent: SessionEvent {}


// MARK:- Utils

extension Event where Self: Encodable {
    func toRequest() -> URLRequest? {
        if let e = self as? AuthenticatedEvent {
            guard e.appID != nil else { return nil }
            guard e.token != nil else { return nil }
        }
        if let e = self as? SessionEvent {
            guard e.ucID != nil else { return nil }
            guard e.confID != nil else { return nil }
        }
        
        // url
        let path: String
        switch self {
        case let e as CreateSessionEvent: path = "v1/apps/\(e.appID!)/conferences/\(e.confID)"
        default: path = self.path()
        }
        let url = "\(self.url())/\(path)"
        
        let content: Data
        if let req = self as? TokenRequest {
            let tokenReqString = "grant_type=\(req.grantType)&client_id=\(req.clientID)&code=\(req.code)"
            guard let tokenReqData = tokenReqString.data(using: .utf8) else { return nil }
            content = tokenReqData
        } else {
            guard let jsonData = try? JSONEncoder().encode(self) else { return nil }
            content = jsonData
        }
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = content
        
        let contentType = self is TokenRequest ? kContentTypeFormUrl : kContentTypeJson
        request.setValue(contentType, forHTTPHeaderField: kHeaderContentType)
        
        // add auth token to header if needed by event
        if let authEvent = self as? AuthenticatedEvent {
            request.setValue("Bearer \(authEvent.token!)", forHTTPHeaderField: kHeaderAuthorization)
        }
        return request
    }
}
