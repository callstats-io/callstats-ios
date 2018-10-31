//
//  HttpClient.swift
//  Callstats
//
//  Created by Amornchai Kanokpullwad on 9/23/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

enum Response {
    case success(code: Int, dict: Dictionary<String, Any>?)
    case failed(code: Int, dict: Dictionary<String, Any>?)
    case error(reason: String)
}

protocol HttpClient {
    func sendRequest(request: URLRequest, completion: @escaping (Response) -> Void)
}

class HttpClientImpl: HttpClient {
    
    private let configuration: URLSessionConfiguration
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.httpMaximumConnectionsPerHost = 1
        config.httpShouldUsePipelining = false
        configuration = config
        session = URLSession(
            configuration: configuration,
            delegate: nil,
            delegateQueue: OperationQueue.main)
    }
    
    func sendRequest(request: URLRequest, completion: @escaping (Response) -> Void) {
        NSLog(">>> %@ : %@", request.httpMethod ?? "", request.url?.absoluteString ?? "")
        print(request.httpBody != nil ? String(data: request.httpBody!, encoding: .utf8) ?? "" : "")
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                NSLog(
                    "Error request -> %@ : %@",
                    request.httpMethod ?? "",
                    request.url?.absoluteString ?? "")
                completion(.error(reason: error!.localizedDescription))
                return
            }
            
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            let jsonStr = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
            
            NSLog("<<< Response %d : %@ : %@", status, request.httpMethod ?? "", request.url?.absoluteString ?? "")
            print(jsonStr)
            
            let jsonObj = (try? JSONSerialization.jsonObject(
                with: data,
                options: JSONSerialization.ReadingOptions(rawValue: 0))
                ) as? [String: Any]
            
            status >= 200 && status <= 299
                ? completion(.success(code: status, dict: jsonObj))
                : completion(.failed(code: status, dict: jsonObj))
        }

        task.resume()
    }
}
