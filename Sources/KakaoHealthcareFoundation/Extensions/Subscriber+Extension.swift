//
//  Subscriber+Extension.swift
//  SampleKit
//
//  Created by nobleidea on 2023/04/04.
//

import Foundation
import Combine

public extension Subscribers.Completion {
    func error() throws -> Failure {
        if case let .failure(error) = self {
            return error
        }
        throw ErrorFunctionThrowsError.error
    }

    enum ErrorFunctionThrowsError: Error { case error }
}
