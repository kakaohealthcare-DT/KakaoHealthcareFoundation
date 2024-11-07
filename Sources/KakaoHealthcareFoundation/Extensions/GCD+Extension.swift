//
//  GCD+Extension.swift
//  SampleKit
//
//  Created by gyun on 2023/04/13.
//

import Foundation

public extension DispatchQueue {
    func safeAsync(_ block: @escaping () -> Void) {
        if self === DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            async(execute: block)
        }
    }
}
