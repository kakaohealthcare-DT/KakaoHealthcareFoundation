//
//  Data+Extension.swift
//  SampleKit
//
//  Created by nobleidea on 2023/04/04.
//

import Foundation

public extension Data {
    var base64URLEncodedString: String {
        let base64Encoded = base64EncodedString()
        return base64Encoded
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    var asDictionary: [String: AnyHashable]? {
        (try? JSONSerialization.jsonObject(
            with: self,
            options: []
        )) as? [String: AnyHashable]
    }
    
    var prettyPrintedJSONString: String? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(
                withJSONObject: jsonObject,
                options: []
              ),
              let prettyJSON = String(data: data, encoding: .utf8) else {
                  return nil
               }

        return prettyJSON
    }
	
	var hexString: String {
		let hexString = map { String(format: "%02.2hhx", $0) }.joined()
		return hexString
	}
}

public extension Data {
    mutating func append(
        _ string: String,
        encoding: String.Encoding = .utf8
    ) {
        guard let data = string.data(using: encoding) else {
            return
        }
        append(data)
    }
}
