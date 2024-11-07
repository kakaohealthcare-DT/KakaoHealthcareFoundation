//
//  Set+Extension.swift
//  SampleKit
//
//  Created by nobleidea on 2023/04/04.
//

import Foundation

extension Set {
    public func compactMap<T>(_ transform: (Element) throws -> T?) rethrows -> Set<T> {
        var result = Set<T>()

        forEach { value in
            if let transformed = try? transform(value) {
                result.insert(transformed)
            }
        }

        return result
    }
}
