//
//  CsioUtils.swift
//  demo
//
//  Created by Amornchai Kanokpullwad on 5/13/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import Foundation
import CommonCrypto

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

// MARK:- Key utils for testing

private func getKey(key: String, password: String) -> SecKey? {
    let privkeyData = Data(base64Encoded: key, options: .ignoreUnknownCharacters)!
    let options = [kSecImportExportPassphrase as String: password]
    var rawItems: CFArray?
    let status = SecPKCS12Import(privkeyData as CFData, options as CFDictionary, &rawItems)
    guard status == errSecSuccess else { return nil }
    let items = rawItems! as! Array<Dictionary<String, Any>>
    let secDict = items[0]
    let identity = secDict[kSecImportItemIdentity as String] as! SecIdentity
    var privateKey: SecKey?
    let privateKeyStatus = SecIdentityCopyPrivateKey(identity, &privateKey)
    guard privateKeyStatus == errSecSuccess else { return nil }
    return privateKey
}

func createJwt(dict: [String: Any], key: String, password: String) -> String? {
    let header = toJson(["alg": "ES256"])
    let content = toJson(dict)
    guard header != "" else { return "" }
    guard content != "" else { return "" }
    let header64 = Data(header.utf8).base64EncodedString()
    let content64 = Data(content.utf8).base64EncodedString()
    let jwtData = "\(header64).\(content64)"
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
    
    // hash
    let data = jwtData.data(using: .utf8)!
    var digest = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
    digest.withUnsafeMutableBytes { digestBytes in
        data.withUnsafeBytes { pointer in
            _ = CC_SHA256(pointer, CC_LONG(data.count), digestBytes)
        }
    }
    
    var signature = Data(count: 256)
    var signatureLength = signature.count
    guard let privateKey = getKey(key: key, password: password) else { return nil }
    let result = signature.withUnsafeMutableBytes { signatureBytes in
        digest.withUnsafeBytes { digestBytes in
            SecKeyRawSign(
                privateKey,
                .sigRaw,
                digestBytes,
                digest.count,
                signatureBytes,
                &signatureLength)
        }
    }
    
    let count = signature.count - signatureLength
    signature.removeLast(count)
    guard result == noErr else { return "" }
    
    let signatureData = signature.base64EncodedString()
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
    
    return "\(jwtData).\(signatureData)"
}
