import Foundation
import XCTest
@testable import FoundationExtension

class DateSwitchOperatorTest: XCTestCase {
	func testAddingDays() {
		let calendar = Calendar.current
		let startDate = calendar.date(from: DateComponents(year: 2023, month: 1, day: 1))
		let expectedDate = calendar.date(from: DateComponents(year: 2023, month: 1, day: 6))
		
		if let startDate, let expectedDate {
			let addedDate = startDate >> 5
			XCTAssertEqual(addedDate, expectedDate, "Adding 5 days should work correctly.")
		} else {
			XCTFail("Unwrapping failed")
		}
	}
	
	func testSubtractingDays() {
		let calendar = Calendar.current
		let startDate = calendar.date(from: DateComponents(year: 2023, month: 1, day: 10))
		let expectedDate = calendar.date(from: DateComponents(year: 2023, month: 1, day: 5))
		if let startDate, let expectedDate {
			let subtractedDate = startDate << 5
			XCTAssertEqual(subtractedDate, expectedDate, "Subtracting 5 days should work correctly.")
		} else {
			XCTFail("Unwrapping failed")			
		}
	}
}
