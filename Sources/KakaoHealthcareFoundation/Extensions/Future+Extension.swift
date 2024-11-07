//
//  Future+Extension.swift
//  SampleKit
//
//  Created by nobleidea on 2023/04/04.
//

import Foundation
import Combine

extension Future where Failure == Error {
    public convenience init(_ completion: @escaping () async throws -> Output) {
        self.init { promise in
            Task {
                do {
                    let result = try await completion()
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}

extension Future where Failure == Never {
    public convenience init(_ completion: @escaping () async -> Output) {
        self.init { promise in
            Task {
                let result = await completion()
                promise(.success(result))
            }
        }
    }
}
