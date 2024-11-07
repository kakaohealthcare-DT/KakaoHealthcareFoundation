//
//  Error+Extension.swift
//  DTFoundation
//
//  Created by evan.g on 2022/11/21.
//

import Combine

extension Publisher {
    public func handleError(_ handle: @escaping (Failure) -> Void) -> AnyPublisher<Output, Never> {
        self.catch { error -> Empty<Output, Never> in
            handle(error)
            return Empty(completeImmediately: true, outputType: Output.self, failureType: Never.self)
        }
        .eraseToAnyPublisher()
    }
}
