//
//  ISO8601Date.swift
//  FoundationExtension
//
//  Created by kyle.cha on 1/16/24.
//  Copyright © 2024 Kakao Healthcare Corp. All rights reserved.
//

import Foundation

@propertyWrapper
/// Wrapper used to easily encode a `Date` to and decode a `Date` from an ISO 8601 formatted date string.
public struct ISO8601Date: Codable, Hashable, Sendable {
	public let wrappedValue: Date
	
	public init(wrappedValue: Date = .init()) {
		self.wrappedValue = wrappedValue
	}
	
	public init(milliseconds: Int64) {
		self.wrappedValue = .init(milliseconds: milliseconds)
	}
	
	public init(from decoder: Decoder) throws {
		let value = try decoder.singleValueContainer()
		let stringValue = try value.decode(String.self)
		
		if let date = ISO8601DateConstants.dateFormatter.date(from: stringValue) {
			wrappedValue = date

		} else {
			Logger.fault("⚠️ [\(#file)] Decode Failed: \(stringValue) ")
			throw ISO8601DateConstants.decodingError(stringValue)
		}
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(ISO8601DateFormatter().string(from: wrappedValue))
	}
	
	public static var now: ISO8601Date {
		ISO8601Date(wrappedValue: .now)
	}
	
	public func representedDateString(dateFormat: Date.Format) -> String {
		wrappedValue.toString(dateFormat: dateFormat)
	}
}

extension ISO8601Date: Equatable, Comparable {
	public static func == (lhs: ISO8601Date, rhs: ISO8601Date) -> Bool {
		lhs.wrappedValue == rhs.wrappedValue
	}
	
	public static func < (lhs: ISO8601Date, rhs: ISO8601Date) -> Bool {
		lhs.wrappedValue < rhs.wrappedValue
	}
}

extension ISO8601Duration: Equatable {
	public static func == (lhs: ISO8601Duration, rhs: ISO8601Duration) -> Bool {
		lhs.wrappedValue == rhs.wrappedValue
	}
}

@propertyWrapper
/// Wrapper used to easily encode a `Date` to and decode a `Date` from an ISO 8601 formatted date string.
public struct ISO8601Duration: Codable {
	public var wrappedValue: DateComponents
	
	public init(wrappedValue: DateComponents) {
		self.wrappedValue = wrappedValue
	}
	
	public init(from decoder: Decoder) throws {
		let value = try decoder.singleValueContainer()
		let stringValue = try value.decode(String.self)
		wrappedValue = try DateComponents.from8601String(stringValue)
	}
	
	public init(stringValue: String) throws {
		wrappedValue = try DateComponents.from8601String(stringValue)
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(wrappedValue.toISO8601Duration())
	}
}

@propertyWrapper
// MARK: implemented not yet, it needs to sync with server side spec
public struct ISO8601DateInterval: Codable, Equatable {
	public var wrappedValue: DateInterval
	
	public init(wrappedValue: DateInterval = .init()) {
		self.wrappedValue = wrappedValue
	}
	
	public init(from decoder: Decoder) throws {
		let value = try decoder.singleValueContainer()
		let stringValue = try value.decode(String.self)
		let components = stringValue.components(
			separatedBy: ISO8601DateConstants.intervalSeperator
		)
		
		guard components.count == 2,
					let first = components[safe: 0],
					let second = components[safe: 1]
		else {
			throw ISO8601DateConstants.decodingError(stringValue)
		}
		
		if let start = ISO8601DateConstants.dateFormatter.date(from: first),
			 let end = ISO8601DateConstants.dateFormatter.date(from: second) {
			wrappedValue = .init(start: start, end: end)
			
		} else if  let start = ISO8601DateConstants.dateFormatter.date(from: first),
							 let duration = try? DateComponents.from8601String(second),
							 let end = Calendar.current.date(byAdding: duration, to: start) {
			wrappedValue = .init(start: start, end: end)
			
		} else if  let duration = try? DateComponents.from8601String(first),
								let end = ISO8601DateConstants.dateFormatter.date(from: second),
							 let start = Calendar.current.date(byAdding: duration, to: end) {
			wrappedValue = .init(start: start, end: end)
			
		} else {
			throw ISO8601DateConstants.decodingError(stringValue)
		}
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		
		let start = ISO8601DateConstants.dateFormatter.string(from: wrappedValue.start)
		let end = ISO8601DateConstants.dateFormatter.string(from: wrappedValue.end)
		try container.encode("\(start)\(ISO8601DateConstants.intervalSeperator)\(end)")
	}
	
	public var startDate: ISO8601Date {
		.init(wrappedValue: wrappedValue.start)
	}
	
	public var endDate: ISO8601Date {
		.init(wrappedValue: wrappedValue.end)
	}
}

private enum ISO8601DateConstants {
	static let dateFormatter: ISO8601DateFormatter = {
//		$0.formatOptions = [
//			.withInternetDateTime, /*RFC 3339*/
//			.withFractionalSeconds /*HH:mm:ss.SSS*/
//		]
//		return $0
		$0
	}(ISO8601DateFormatter())

	static let intervalSeperator = "/"
	
	static func decodingError(_ description: String = "") -> DecodingError {
		DecodingError.typeMismatch(
			Date.self,
			DecodingError.Context(
				codingPath: [],
				debugDescription: "Failed to decode ISO Date. Invalid string format.\n\"\(description)\""
			)
		)
	}
}

