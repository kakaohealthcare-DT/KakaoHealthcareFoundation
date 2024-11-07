//
//  AnyPublisher+Extension.swift
//  DTFoundation
//
//  Created by evan.g on 2022/11/21.
//

import Combine

public extension AnyPublisher {
    static func empty() -> AnyPublisher<Output, Failure> {
        Empty(completeImmediately: false)
            .eraseToAnyPublisher()
    }

    static func emptyAndCompleted() -> AnyPublisher<Output, Failure> {
        Empty(completeImmediately: true)
            .eraseToAnyPublisher()
    }

    static func just(_ output: Output) -> AnyPublisher<Output, Failure> {
        Just(output)
            .setFailureType(to: Failure.self)
            .eraseToAnyPublisher()
    }

    static func fail(_ error: Failure) -> AnyPublisher<Output, Failure> {
        Fail(error: error)
            .eraseToAnyPublisher()
    }
    
//    static func delay<S: Scheduler>(
//        _ interval: S.SchedulerTimeType.Stride,
//        scheduler: S = RunLoop.main,
//        output: Output
//    ) -> AnyPublisher<Output, Failure> {
//        just(output)
//            .delay(for: interval, scheduler: scheduler)
//            .eraseToAnyPublisher()
//    }
}
