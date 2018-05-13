//
//  CsioUtils.swift
//  demo
//
//  Created by Amornchai Kanokpullwad on 5/13/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation

func toJson(_ object: Dictionary<String, Any>) -> String {
    do {
        let data = try JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions(rawValue: 0))
        let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        return string! as String
    } catch {
        print("Error")
    }
    return ""
}

func fromJson(_ jsonString: String) -> Dictionary<String, Any> {
    if let data: Data = jsonString.data(using: String.Encoding.utf8) {
        do {
            if let jsonObj = try JSONSerialization.jsonObject(
                with: data,
                options: JSONSerialization.ReadingOptions(rawValue: 0)) as? Dictionary<String, Any>
            {
                return jsonObj
            }
        } catch {
            print("Error")
        }
    }
    return [String: Any]()
}
