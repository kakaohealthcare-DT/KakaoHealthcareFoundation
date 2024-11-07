//
//  ISO8601Parser.swift
//  FoundationExtensionTests
//
//  Created by kyle.cha on 1/16/24.
//  Copyright © 2024 Kakao Healthcare Corp. All rights reserved.
//

import XCTest
@testable import FoundationExtension

final class ISO8601ParserTests: XCTestCase {
	func testIndividualYearsParsedCorrectly() throws {
		let dateComponents = try DateComponents.from8601String("P1Y")
		XCTAssertEqual(dateComponents.year, 1)
	}
	
	func testIndividualMonthsParsedCorrectly() throws {
		let dateComponents = try DateComponents.from8601String("P2M")
		XCTAssertEqual(dateComponents.month, 2)
	}
	
	func testIndividualDaysParsedCorrectly() throws {
		let dateComponents = try DateComponents.from8601String("P3D")
		XCTAssertEqual(dateComponents.day, 3)
	}
	
	func testIndividualHoursParsedCorrectly() throws {
		let dateComponents = try DateComponents.from8601String("PT11H")
		XCTAssertEqual(dateComponents.hour, 11)
	}
	
	func testIndividualMinutesParsedCorrectly() throws {
		let dateComponents = try DateComponents.from8601String("PT42M")
		XCTAssertEqual(dateComponents.minute, 42)
	}
	
	func testIndividualSecondsParsedCorrectly() throws {
		let dateComponents = try DateComponents.from8601String("PT32S")
		XCTAssertEqual(dateComponents.second, 32)
	}
	
	func testWeeksParsedCorrectly() throws {
		let dateComponents = try DateComponents.from8601String("P8W")
		XCTAssertEqual(dateComponents.day, 56)
	}
	
	func testFullStringParsedCorrectly() throws {
		let dateComponents = try DateComponents.from8601String("P3Y6M4DT12H30M5S")
		XCTAssertEqual(dateComponents.year, 3)
		XCTAssertEqual(dateComponents.month, 6)
		XCTAssertEqual(dateComponents.day, 4)
		XCTAssertEqual(dateComponents.hour, 12)
		XCTAssertEqual(dateComponents.minute, 30)
		XCTAssertEqual(dateComponents.second, 5)
	}
	
	func testDurationStringNotStartingWithPReturnsNil() {
		XCTAssertThrowsError(try DateComponents.from8601String("3Y6M4DT12H30M5S"))
		XCTAssertThrowsError(try DateComponents.from8601String("8W"))
	}
	
	func testParsingFractionalHours() throws {
		let dateComponents = try DateComponents.from8601String("PT0.5H45S")
		XCTAssertEqual(dateComponents.hour, 0)
		XCTAssertEqual(dateComponents.minute, 30)
		XCTAssertEqual(dateComponents.second, 45)
	}
	
	func testParsingFractionalMinutesWithCarryOver() throws {
		let dateComponents = try DateComponents.from8601String("PT1.25M10S")
		XCTAssertEqual(dateComponents.minute, 1)
		XCTAssertEqual(dateComponents.second, 25) // 10 seconds + 15 seconds (0.25 minutes * 60 seconds)
	}
	
	func testParsingFractionalSecondsTruncating() throws {
		let dateComponents = try DateComponents.from8601String("PT42.25S")
		XCTAssertEqual(dateComponents.second, 42)
	}
	
	func testParsingFractionalSecondsRoundingUp() throws {
		let dateComponents = try DateComponents.from8601String("PT18.6125S")
		XCTAssertEqual(dateComponents.second, 19)
	}
	
	func testDateComponentsToISO8601Duration() {
		let dateComponents = DateComponents(calendar: nil, timeZone: nil, era: nil, year: 6, month: 2, day: 2, hour: 4, minute: 44, second: 22, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: 2, yearForWeekOfYear: nil)
		let ISO8601DurationStr = dateComponents.toISO8601Duration()
		
		XCTAssertEqual(ISO8601DurationStr, "P6Y2M2W2DT4H44M22S")
	}
	
	func testDateToISO8601Date() throws {
		let jsonString = """
	{
	 "test": "2016-04-08T10:25:30+0900"
	}
	"""
		
		let json = try XCTUnwrap(jsonString.data(using: .utf8))
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		
		let ISO8601DateStr = try decoder.decode(Model.self, from: json)
		let comparableDate = try XCTUnwrap(
			ISO8601DateFormatter().date(from: "2016-04-08T10:25:30+0900")
		)
		print(ISO8601DateStr.test.representedDateString(dateFormat: .mmmddyyyy))
		print(ISO8601DateStr.test.representedDateString(dateFormat: .ddHH))
		print(ISO8601DateStr.test.representedDateString(dateFormat: .HHmma))
		XCTAssertEqual(ISO8601DateStr.test.wrappedValue, comparableDate)
	}
	
	func testDateToISO8601DateWithDecoder() throws {
		let jsonString = """
	{
	 "test": "2016-04-08T10:25:30+0900"
	}
	"""
		
		let json = try XCTUnwrap(jsonString.data(using: .utf8))
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		
		let ISO8601DateStr = try decoder.decode(Model2.self, from: json)
		
		let comparableDate = try XCTUnwrap(
			ISO8601DateFormatter().date(from: "2016-04-08T10:25:30+0900")
		)
		
		XCTAssertEqual(ISO8601DateStr.test, comparableDate)
	}
	
	func testDateToISO8601DateInterval() throws {
		let jsonString = """
	{
	 "test": "2016-04-08T10:25:30+0900/2016-04-08T11:25:30+0900"
	}
	"""
		
		let json = try XCTUnwrap(jsonString.data(using: .utf8))
		
		let ISO8601DateInterval = try JSONDecoder().decode(Model3.self, from: json)
		
		let start = try XCTUnwrap(
			ISO8601DateFormatter().date(from: "2016-04-08T10:25:30+0900")
		)
		let end = try XCTUnwrap(
			ISO8601DateFormatter().date(from: "2016-04-08T11:25:30+0900")
		)
		
		XCTAssertEqual(ISO8601DateInterval.test.wrappedValue, DateInterval(start: start, end: end))
	}
	
	func testDateToISO8601DateIntervalWithDuration() throws {
		let jsonString = """
	{
	 "test": "2016-04-08T10:25:30+0900/PT32S"
	}
	"""
		
		let json = try XCTUnwrap(jsonString.data(using: .utf8))
		let ISO8601DateInterval = try JSONDecoder().decode(Model3.self, from: json)
		
//		let start = try XCTUnwrap(
//			ISO8601DateFormatter().date(from: "2016-04-08T10:25:30+0900")
//		)
//		let end = try XCTUnwrap(
//			ISO8601DateFormatter().date(from: "2016-04-08T11:25:30+0900")
//		)
		let interval = ISO8601DateInterval.test.wrappedValue.end.timeIntervalSince1970 - ISO8601DateInterval.test.wrappedValue.start.timeIntervalSince1970
		
		XCTAssertEqual(interval, 32)
	}
	
	func testMilliseconds() throws {
		let date: ISO8601Date = .init(milliseconds: 1705455411232)
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [ .withInternetDateTime, .withFractionalSeconds ]
		let comparable = try XCTUnwrap(formatter.date(from: "2024-01-17T10:36:51.232+09:00"))
		XCTAssertEqual(date.wrappedValue, comparable)
		
	}
	
	func testISO8601ParsingTest_no_Z() throws {
		let jsonString = """
	{
	 "test": "2024-05-09T08:14:27"
	}
	"""
		
		let json = try XCTUnwrap(jsonString.data(using: .utf8))
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		
		XCTAssertThrowsError(try decoder.decode(Model.self, from: json))
	}
	
	func testISO8601ParsingTest_milliseconds() throws {
		let jsonString = """
	{
	 "test": "2024-05-09T08:51:32.348421919Z"
	}
	"""
		
		let json = try XCTUnwrap(jsonString.data(using: .utf8))
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		XCTAssertThrowsError(try decoder.decode(Model.self, from: json))
	}

	struct Model: Codable {
		var test: ISO8601Date
	}
	
	struct Model2: Codable {
		var test: Date
	}
	
	struct Model3: Codable {
		var test: ISO8601DateInterval
	}
	
	func testISO8601DurationParse() throws {
		let sixhour = "PT6H"
		let sixhourAndHalf = "PT6H30M"
		
		let sixhourDate = try ISO8601Duration(stringValue: sixhour)
		let sixhourHalfDate = try ISO8601Duration(stringValue: sixhourAndHalf)
		
		let sixhourDate_true = ISO8601Duration(wrappedValue: .init(hour: 6, minute: 0, second: 0))
		let sixhourHalfDate_true = ISO8601Duration(wrappedValue: .init(hour: 6, minute: 30, second: 0))
		
		XCTAssertEqual(sixhourDate, sixhourDate_true)
		XCTAssertEqual(sixhourHalfDate, sixhourHalfDate_true)
	}
	
	func testISO8601EmptyDurationParse() throws {
		let text = ""
		XCTAssertThrowsError(try ISO8601Duration(stringValue: text))
	}
}
