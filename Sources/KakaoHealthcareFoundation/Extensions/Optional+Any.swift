//
//  Optional+Any.swift
//  DTFoundation
//
//  Created by evan.g on 2022/09/23.
//

import Foundation

public protocol AnyOptional {
	var isNil: Bool { get }
	var isNotNil: Bool { get }
}

extension Optional: AnyOptional {
	public var isNil: Bool { self == nil }
	public var isNotNil: Bool { self != nil }
}
