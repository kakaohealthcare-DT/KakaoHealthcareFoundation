//
//  Date+Extension.swift
//  SampleKit
//
//  Created by nobleidea on 2023/04/04.
//

import Foundation

public extension DateFormatter {
	@discardableResult
	func withDateFormat(_ format: String) -> Self {
		self.dateFormat = format
		return self
	}
	
	@discardableResult
	func withTimeZone(_ identifier: String) -> Self {
		self.timeZone = .init(identifier: identifier)
		return self
	}
	
	@discardableResult
	func withLocale(_ identifier: String) -> Self {
		self.locale = .init(identifier: identifier)
		return self
	}
}

public extension Date {
	init(milliseconds: Int64) {
		let timestampString = String(format: "%lld", milliseconds)
		let timeInterval = timestampString.count == 10
		? TimeInterval(milliseconds) : TimeInterval(Double(milliseconds) / 1000.0)
		self = Date(timeIntervalSince1970: timeInterval)
	}
	
	enum Format: String {
		case yyyyMMdd
		case mmmddyyyy = "MMM dd, yyyy"
		case ddHH = "dd:HH"
		case HHmma = "HH:mm a"
		case hmma = "h:mm a"
		case hhmma = "hh:mm a"
		case EMMMddyyyy = "E, MMM dd, yyyy"
		case mmmYYYY = "MMM yyyy"
		case mmmmCommaYYYY = "MMMM, yyyy"
		case yyyyMM = "yyyyMM"
		case dd = "dd"
		// swiftlint: disable identifier_name
		case d = "d"
		// swiftlint: enable identifier_name
		case yyyy = "yyyy"
		case MM = "MM"
		case ha = "h a"
		case MMMd = "MMM d"
		
		/// ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]`.
		case weekdayBasic = "EEEE"
		/// ["S", "M", "T", "W", "T", "F", "S"]`.
		case weekdayVeryShort = "EEEEE"
		/// ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]`.
		case weekdayShort = "E"
		
		case yyyyMMddHHmmss = "yyyy-MM-dd HH:mm:ss"
		case MMMddyyyyhhmma = "MMM dd, yyyy hh:mm a"
		case iso8601
		
		var value: String { rawValue }
	}
	
	var calendar: Calendar { Calendar.current }
	
	var weekday: Int {
		(calendar.dateComponents([.weekday], from: self).weekday ?? 1) - 1
		
	}
	
	func toString(dateFormat format: Format) -> String {
		if format == .iso8601 {
			return self.formatted(
				.iso8601
					.year()
					.month()
					.day()
					.timeZone(separator: .omitted)
					.time(includingFractionalSeconds: true)
					.timeSeparator(.colon)
			)
		}
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format.value
		dateFormatter.timeZone = .autoupdatingCurrent
		dateFormatter.locale = Locale.current
		
		return dateFormatter.string(from: self)
	}
	
	func isSameDay(as otherDate: Date) -> Bool {
		let baseDate = self
		let otherDate = otherDate
		
		let baseDateComponents = Calendar.current.dateComponents(
			[.day, .month, .year],
			from: baseDate
		)
		let otherDateComponents = Calendar.current.dateComponents(
			[.day, .month, .year],
			from: otherDate
		)
		
		if baseDateComponents.year == otherDateComponents.year,
			 baseDateComponents.month == otherDateComponents.month,
			 baseDateComponents.day == otherDateComponents.day {
			return true
		} else {
			return false
		}
	}
	
	var startOfMonth: Date? {
			Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: Calendar.current.startOfDay(for: self)))
	}
	
	var endOfMonth: Date? {
		guard let startOfMonth else {
			return nil
		}
		return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)
	}
	
	func addDay(dayCount: Int) -> Date {
		Calendar.current.date(byAdding: .day, value: dayCount, to: self) ?? .now
	}
	
	func addSecond(_ value: Int) -> Date {
		Calendar.current.date(byAdding: .second, value: value, to: self) ?? .now
	}
}
