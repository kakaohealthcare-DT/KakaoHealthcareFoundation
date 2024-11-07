//
//  ISO8601DurationParser.swift
//  FoundationExtension
//
//  Created by kyle.cha on 1/16/24.
//  Copyright © 2024 Kakao Healthcare Corp. All rights reserved.
//
import Foundation

/*
 Duration
 - P3Y - 3 years
 - P24W6D - 24 weeks, 6 days
 - P5MT7M - 5 months, 7 minutes
 - PT3H5S - 3 hours, 5 seconds
 
 Interval
 - "2007-03-01T13:00:00Z/2008-05-11T15:30:00Z"
 - "2007-03-01T13:00:00Z/P1Y2M10DT2H30M"
 - "P1Y2M10DT2H30M/2008-05-11T15:30:00Z"
 - "P1Y2M10DT2H30M", with additional context information
 - 2003-02-15T00:00:00Z/P2M  ends two calendar months later at 2003-04-15T00:00:00Z which is 59 days later
 - 2003-07-15T00:00:00Z/P2M ends two calendar months later at 2003-09-15T00:00:00Z which is 62 days later
 
 FYI: http://en.wikipedia.org/wiki/ISO_8601#Durations
 */

public enum ISO8601Delimiters: CaseIterable {
	// PWTYMDHMS
	// "P3Y6M4DT12H30M5S" represents a duration of
	// "three years, six months, four days, twelve hours, thirty minutes, and five seconds".
	// Please do not change ordering!
	case period
	case week
	case time
	case dateDesignator(DateDurationDesignator)
	case timeDesignator(TimeDurationDesignator)
	
	public enum TimeDurationDesignator: String, CaseIterable {
		case hour = "H"
		case minute = "M"
		case second = "S"
	}
	
	public enum DateDurationDesignator: String, CaseIterable {
		case year = "Y"
		case month = "M"
		case day = "D"
	}
	
	var rawValue: String {
		switch self {
		case .period:
			return "P"
		case .week:
			return "W"
		case .time:
			return "T"
		case let .dateDesignator(delimiters):
			return delimiters.rawValue
		case let .timeDesignator(delimiters):
			return delimiters.rawValue
		}
	}
	
	public static let allCases: [ISO8601Delimiters] = {
		var allcases: [ISO8601Delimiters] = []
		allcases.append(contentsOf: [.period, .week, .time])
		allcases.append(contentsOf: DateDurationDesignator.allCases.map { .dateDesignator($0) })
		allcases.append(contentsOf: TimeDurationDesignator.allCases.map { .timeDesignator($0) })
		return allcases
	}()
	
	public static let seperator: CharacterSet = {
		CharacterSet(charactersIn: ISO8601Delimiters.allCases.map { $0.rawValue }.joined())
	}()
	
	public static let zeroOrNilValue: String = "PT0S"
}

public extension DateComponents {
	static func durationFrom8601String(_ durationString: String) -> DateComponents? {
		try? Self.from8601String(durationString)
	}
	
	// Note: Does not handle fractional values for months
	// Format: PnYnMnDTnHnMnS or PnW
	static func from8601String(_ durationString: String) throws -> DateComponents {
		guard durationString.starts(with: ISO8601Delimiters.period.rawValue) else {
			throw DecodingError.valueNotFound(
				ISO8601Duration.self,
				DecodingError.Context(
					codingPath: [],
					debugDescription: "Encoded payload not of an expected type with \(durationString)")
			)
		}
		
		let durationString = String(durationString.dropFirst())
		var dateComponents = DateComponents()
		
		if let week = componentFor(.week, in: durationString) {
			dateComponents.day = Int(week * 7.0)
			return dateComponents
		}
		
		let tRange = (durationString as NSString).range(of: ISO8601Delimiters.time.rawValue, options: .literal)
		let periodString: String
		let timeString: String
		if tRange.location == NSNotFound {
			periodString = durationString
			timeString = ""
		} else {
			periodString = (durationString as NSString).substring(to: tRange.location)
			timeString = (durationString as NSString).substring(from: tRange.location + 1)
		}
		
		// DnMnYn
		let year = componentFor(.dateDesignator(.year), in: periodString)
		let month = componentFor(.dateDesignator(.month), in: periodString).addingFractionsFrom(year, multiplier: 12)
		let day = componentFor(.dateDesignator(.day), in: periodString)
		
		if let monthFraction = month?.truncatingRemainder(dividingBy: 1),
			 monthFraction != 0 {
			throw DecodingError.valueNotFound(
				ISO8601Duration.self,
				DecodingError.Context(
					codingPath: [],
					debugDescription: "Encoded payload not of an unsupportedFractionsForMonth type with \(durationString)")
			)
		}
		
		dateComponents.year = year?.nonFractionParts
		dateComponents.month = month?.nonFractionParts
		dateComponents.day = day?.nonFractionParts
		
		// SnMnHn
		let hour = componentFor(.timeDesignator(.hour), in: timeString).addingFractionsFrom(day, multiplier: 24)
		let minute = componentFor(.timeDesignator(.minute), in: timeString).addingFractionsFrom(hour, multiplier: 60)
		let second = componentFor(.timeDesignator(.second), in: timeString).addingFractionsFrom(minute, multiplier: 60)
		dateComponents.hour = hour?.nonFractionParts
		dateComponents.minute = minute?.nonFractionParts
		dateComponents.second = second.map { Int($0.rounded()) }
		
		return dateComponents
	}
	
	private static func componentFor(
		_ designator: ISO8601Delimiters,
		in string: String
	) -> Double? {
		componentFor(designator.rawValue, in: string)
	}
	
	private static func componentFor(
		_ designator: String,
		in string: String
	) -> Double? {
		let beforeDesignator = string.components(separatedBy: designator).first?.components(
			separatedBy: ISO8601Delimiters.seperator
		).last
		return beforeDesignator.flatMap { Double($0) }
	}
	
	enum DurationParsingError: Error {
		case invalidFormat(String)
		case unsupportedFractionsForMonth(String)
	}
}

private extension String {
	mutating func append(_ value: Int, suffix: ISO8601Delimiters, emitZeroValues: Bool) {
		guard value != 0 || emitZeroValues.not else {
			return
		}
		self.append("\(value)\(suffix.rawValue)")
	}
}

public extension DateComponents {
	func toISO8601Duration(
		emitZeroOrNilValues: Bool = false
	) -> String {
		if allComponentsZeroOrNil.not && emitZeroOrNilValues {
			return ISO8601Delimiters.zeroOrNilValue
		}
		
		var result = ISO8601Delimiters.period.rawValue
		result.append(year ?? 0, suffix: .dateDesignator(.year), emitZeroValues: emitZeroOrNilValues)
		result.append(month ?? 0, suffix: .dateDesignator(.month), emitZeroValues: emitZeroOrNilValues)
		result.append(weekOfYear ?? 0, suffix: .week, emitZeroValues: emitZeroOrNilValues)
		result.append(day ?? 0, suffix: .dateDesignator(.day), emitZeroValues: emitZeroOrNilValues)
		
		if allTimeComponentsZeroOrNil.not || emitZeroOrNilValues.not {
			result.append(ISO8601Delimiters.time.rawValue)
			result.append(
				hour ?? 0,
				suffix: ISO8601Delimiters.timeDesignator(.hour),
				emitZeroValues: emitZeroOrNilValues
			)
			
			result.append(
				minute ?? 0,
				suffix: ISO8601Delimiters.timeDesignator(.minute),
				emitZeroValues: emitZeroOrNilValues
			)
			
			result.append(
				second ?? 0,
				suffix: ISO8601Delimiters.timeDesignator(.second),
				emitZeroValues: emitZeroOrNilValues
			)
		}
		
		return result
	}
	
	private var allComponentsZeroOrNil: Bool {
		let components = [year, month, weekOfYear, day, hour, minute, second]
		return components.allSatisfy { ($0 ?? 0) == 0 }
	}
	
	private var allTimeComponentsZeroOrNil: Bool {
		let components = [hour, minute, second]
		return components.allSatisfy { ($0 ?? 0) == 0 }
	}
}

private extension Optional where Wrapped == Double {
	func addingFractionsFrom(_ other: Double?, multiplier: Double) -> Self {
		guard let other = other else { return self }
		let toAdd = other.truncatingRemainder(dividingBy: 1) * multiplier
		guard let self = self else { return toAdd }
		return self + toAdd
	}
}

private extension Double {
	var nonFractionParts: Int {
		Int(floor(self))
	}
}

extension DateComponents.DurationParsingError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case let .invalidFormat(value):
			return "\(value) has an invalid format, The durationString must have a format of PnYnMnDTnHnMnS or PnW"
		case let .unsupportedFractionsForMonth(value):
			return "\(value) has an invalid format, fractions aren't supported for the month-position"
		}
	}
}

