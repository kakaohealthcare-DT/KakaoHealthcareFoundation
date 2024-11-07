//
//  Single.swift
//  DTFoundation
//
//  Created by evan.g on 2022/09/29.
//

import Combine
import Foundation

public struct Single<Output, Failure: Error>: Publisher {

    public let upstream: AnyPublisher<Output, Failure>

    public init<P: Publisher>(_ publisher: P) where P.Output == Output, P.Failure == Failure {
        self.upstream = publisher.eraseToAnyPublisher()
    }

    public init(_ attemptToFulfill: @escaping (@escaping Future<Output, Failure>.Promise) -> Void) {
        self.init(
            Deferred {
                Future(
                    attemptToFulfill
                )
            }
        )
    }

    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        self.upstream.subscribe(subscriber)
    }
}
