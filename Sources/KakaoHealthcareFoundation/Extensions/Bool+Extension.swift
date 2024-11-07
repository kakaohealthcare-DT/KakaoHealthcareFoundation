//
//  Bool+Extension.swift
//  SampleKit
//
//  Created by nobleidea on 2023/04/04.
//

import Foundation

public extension Bool {
    var toYNString: String {
        self ? "Y" : "N"
    }

    var toTrueFalseString: String {
        self ? "true" : "false"
    }

    var not: Bool {
        !self
    }
}
