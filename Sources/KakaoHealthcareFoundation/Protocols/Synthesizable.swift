//
//  Synthesizable.swift
//  DTFoundation
//
//  Created by evan.g on 2022/11/21.
//

import Foundation

public protocol Synthesizable: Hashable {}

extension Synthesizable {

    public static func == (left: Self, right: Self) -> Bool {
        zip(left.hashables, right.hashables).allSatisfy(==)
    }

    public func hash(into hasher: inout Hasher) {
        hashables.forEach { hasher.combine($0) }
    }
}

extension Synthesizable {
    fileprivate var hashables: [AnyHashable] {
        Mirror(reflecting: self).children
            .compactMap { $0.value as? AnyHashable }
    }
}

public protocol BaseIdentifiable: Hashable, Identifiable, Equatable {
	var id: UUID { get }
}

extension BaseIdentifiable {
	public static func == (left: Self, right: Self) -> Bool {
		left.id == right.id
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
