//
//  Dictionary+Extension.swift
//  SampleKit
//
//  Created by nobleidea on 2023/04/04.
//

import Foundation

public extension Dictionary {
    static func + (lhs: Dictionary, rhs: Dictionary) -> Dictionary {
        var result = Dictionary()
        lhs.forEach { result.updateValue($0.value, forKey: $0.key) }
        rhs.forEach { result.updateValue($0.value, forKey: $0.key) }

        return result
    }

    static func += (lhs: inout Dictionary, rhs: Dictionary) {
        let result = lhs + rhs

        lhs = result
    }

    func contains(_ key: Key) -> Bool {
        self[key] != nil
    }

    var jsonSerialization: Data? {
			try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
    }

    var prettyString: String {
        guard let data = self.jsonSerialization, let jsonString = String(data: data, encoding: .utf8) else {
            return self.description
        }

        return jsonString
    }

    var compactString: String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .fragmentsAllowed)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                return description
            }

            return jsonString
        } catch {
            return description
        }
    }
}

public extension Dictionary where Key: ExpressibleByStringLiteral {
    subscript<EnumKey: RawRepresentable>(key: EnumKey) -> Value? where EnumKey.RawValue == String {
        get {
            guard let stringKey = key.rawValue as? Key else { return nil }
            return self[stringKey]
        }

        set {
            guard let stringKey = key.rawValue as? Key else { return }
            self[stringKey] = newValue
        }
    }
}

public extension Dictionary where Key == String, Value: CustomStringConvertible {
    func toURLQuery(_ ignoreEmptyValue: Bool = true) -> String {
        let queryItemsString: [String] = {
            if ignoreEmptyValue {
                return compactMapValues { $0 }.map { "\($0)=\($1)" }
            } else {
                return keys.map {
                    guard let value = self[$0] else { return $0 }
                    return "\($0)=\(value)"
                }
            }
        }()

        return queryItemsString.joined(separator: "&")
    }
}
