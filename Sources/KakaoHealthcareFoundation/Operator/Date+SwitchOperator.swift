import Foundation

@frozen
public enum DateValueComponent {
	case day(Int)
}

public func >> (lhs: Date, rhs: DateValueComponent) -> Date {
	switch rhs {
	case let .day(value):
		if let date = Calendar.current.date(byAdding: .day, value: value, to: lhs) {
			return date
		} else {
			let dateInterval = lhs.timeIntervalSince1970 + Double(3600 * 24 * value)
			return Date(timeIntervalSince1970: dateInterval)
		}
	}
}

public func << (lhs: Date, rhs: DateValueComponent) -> Date {
	switch rhs {
	case let .day(value):
		if let date = Calendar.current.date(byAdding: .day, value: -value, to: lhs) {
			return date
		} else {
			let dateInterval = lhs.timeIntervalSince1970 - Double(3600 * 24 * value)
			return Date(timeIntervalSince1970: dateInterval)
		}
	}
}

public func >> (lhs: Date, rhs: Int) -> Date {
	lhs >> .day(rhs)
}

public func << (lhs: Date, rhs: Int) -> Date {
	lhs << .day(rhs)
}
