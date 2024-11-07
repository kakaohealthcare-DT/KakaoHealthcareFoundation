//
//  Array+Extension.swift
//  SampleKit
//
//  Created by nobleidea on 2023/04/03.
//

import Foundation

public extension Array {
	func has(index: Int) -> Bool {
		indices ~= index
	}
	
	subscript (safe index: Int) -> Element? { indices ~= index ? self[index] : nil }
	
	/**
	 Usage:
	 let array = [1, 2, 3, 4, 5, 6, 7, 8]
	 
	 array[safe: [1, 4, 7]] -> [2, 5, 8]
	 array[safe: [4, 10, 6]] -> [5, nil, 7]
	 */
	subscript (safe indexes: [Int]) -> [Element?] { indexes.map { self[safe: $0] } }
	
	/**
	 Usage:
	 let array = [[1, 2, [3, 4]], [4, 5, 6, 7], [8, 9]]
	 
	 array[deepSafe: [0, 2, 0]] -> 3
	 array[deepSafe: [2, 1]] -> 9
	 array[deepSafe: [2, 1, 2]] -> nil
	 */
	subscript(deepSafe indexes: [Int]) -> Any? {
		var paths = indexes
		let index = paths.removeFirst()
		guard let value = self[safe: index] else {
			return nil
		}
		
		if let value = value as? [Any], paths.count > 0 {
			return value[deepSafe: paths]
		}
		
		return value
	}
	
	func appended(_ element: Element) -> Array {
		var result = self
		result.append(element)
		return result
	}
	
	func appended(contentsOf elements: [Element]) -> Array {
		var result = self
		result.append(contentsOf: elements)
		return result
	}
	
	var jsonSerialization: Data? {
		do {
			let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
			return jsonData
		} catch {
			return nil
		}
	}
}

public extension Collection {
	var isNotEmpty: Bool { isEmpty == false }
}

public extension Sequence {
	func group<U: Hashable>(
		by key: (Iterator.Element) -> U
	) -> [U: [Iterator.Element]] {
		Dictionary(grouping: self, by: key)
	}
}

public extension SetAlgebra {
	var isNotEmpty: Bool { isEmpty.not }
}

public extension Array where Element: Equatable {
	func next(of element: Element) -> Element? {
		guard let index = self.firstIndex(of: element) else {
			return nil
		}
		
		return self[safe: self.index(after: index)]
	}

	func previous(of element: Element) -> Element? {
		guard let index = self.firstIndex(of: element) else {
			return nil
		}
		
		return self[safe: self.index(before: index)]
	}
}
