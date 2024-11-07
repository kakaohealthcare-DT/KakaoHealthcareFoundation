//
//  Publisher+Extension.swift
//  DTFoundation
//
//  Created by kyle.cha on 2023/02/10.
//  Copyright © 2023 Kakao Healthcare Corp. All rights reserved.
//

import Foundation
import Combine

public extension Publisher {
    func suppressAndFeedError<S: Subject>(
        into listener: S
    ) -> AnyPublisher<Output, Never> where Failure == S.Output {
        self.catch { error -> Empty<Output, Never> in
            listener.send(error)
            return Empty(
                completeImmediately: true,
                outputType: Output.self,
                failureType: Never.self
            )
        }
        .eraseToAnyPublisher()
    }
}
