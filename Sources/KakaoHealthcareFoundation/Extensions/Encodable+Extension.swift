//
//  Encodable+Extension.swift
//  SampleKit
//
//  Created by nobleidea on 2023/04/04.
//

import Foundation

public extension Encodable {
    var asDictionary: [String: Any]? { asJsonObject() }

    var asQueryItems: [String: AnyHashable]? { asJsonObject() }

    func asJsonObject<T>(
        options: JSONSerialization.ReadingOptions = []
    ) -> T? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }

        return (try? JSONSerialization.jsonObject(with: data, options: options))
            .flatMap { $0 as? T }
    }
}
