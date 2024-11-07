//
//  AnyCodable.swift
//  RESTInfrastructure
//
//  Created by kyle.cha on 2023/01/10.
//

import Foundation

public struct AnyCodable {

    public let value: Any

    public init<T>(_ value: T?) {
        self.value = value ?? ()
    }

}

public struct EmptyData: Codable {
    public init() { }
}

extension AnyCodable: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self.init(())
        } else if let bool = try? container.decode(Bool.self) {
            self.init(bool)
        } else if let int = try? container.decode(Int.self) {
            self.init(int)
        } else if let uint = try? container.decode(UInt.self) {
            self.init(uint)
        } else if let double = try? container.decode(Double.self) {
            self.init(double)
        } else if let string = try? container.decode(String.self) {
            self.init(string)
        } else if let array = try? container.decode([AnyCodable].self) {
            self.init(array.map { $0.value })
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.init(dictionary.mapValues { $0.value })
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }

    // swiftlint:disable all
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self.value {
        case is Void:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let int8 as Int8:
            try container.encode(int8)
        case let int16 as Int16:
            try container.encode(int16)
        case let int32 as Int32:
            try container.encode(int32)
        case let int64 as Int64:
            try container.encode(int64)
        case let uint as UInt:
            try container.encode(uint)
        case let uint8 as UInt8:
            try container.encode(uint8)
        case let uint16 as UInt16:
            try container.encode(uint16)
        case let uint32 as UInt32:
            try container.encode(uint32)
        case let uint64 as UInt64:
            try container.encode(uint64)
        case let float as Float:
            try container.encode(float)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let date as Date:
            try container.encode(date)
        case let url as URL:
            try container.encode(url)
        case let array as [Any?]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any?]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        case let object as Encodable:
            try object.encode(to: encoder)
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable value cannot be encoded")
            throw EncodingError.invalidValue(self.value, context)
        }
    }
	// swiftlint:enable all
}

extension AnyCodable: Equatable {

    static public func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        switch (lhs.value, rhs.value) {
        case is (Void, Void):
            return true
        case let (lhs as Bool, rhs as Bool):
            return lhs == rhs
        case let (lhs as Int, rhs as Int):
            return lhs == rhs
        case let (lhs as Int8, rhs as Int8):
            return lhs == rhs
        case let (lhs as Int16, rhs as Int16):
            return lhs == rhs
        case let (lhs as Int32, rhs as Int32):
            return lhs == rhs
        case let (lhs as Int64, rhs as Int64):
            return lhs == rhs
        case let (lhs as UInt, rhs as UInt):
            return lhs == rhs
        case let (lhs as UInt8, rhs as UInt8):
            return lhs == rhs
        case let (lhs as UInt16, rhs as UInt16):
            return lhs == rhs
        case let (lhs as UInt32, rhs as UInt32):
            return lhs == rhs
        case let (lhs as UInt64, rhs as UInt64):
            return lhs == rhs
        case let (lhs as Float, rhs as Float):
            return lhs == rhs
        case let (lhs as Double, rhs as Double):
            return lhs == rhs
        case let (lhs as String, rhs as String):
            return lhs == rhs
        case let (lhs as [String: AnyCodable], rhs as [String: AnyCodable]):
            return lhs == rhs
        case let (lhs as [AnyCodable], rhs as [AnyCodable]):
            return lhs == rhs
        default:
            return false
        }
    }

}

extension AnyCodable: CustomStringConvertible {

    public var description: String {
        switch value {
        case is Void:
            return String(describing: nil as Any?)
        case let value as CustomStringConvertible:
            return value.description
        default:
            return String(describing: value)
        }
    }

}

extension AnyCodable: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch value {
        case let value as CustomDebugStringConvertible:
            return "AnyCodable(\(value.debugDescription))"
        default:
            return "AnyCodable(\(self.description))"
        }
    }

}

extension AnyCodable:
    ExpressibleByNilLiteral,
    ExpressibleByBooleanLiteral,
    ExpressibleByIntegerLiteral,
    ExpressibleByFloatLiteral,
    ExpressibleByStringLiteral,
    ExpressibleByArrayLiteral,
    ExpressibleByDictionaryLiteral {

    public init(nilLiteral: ()) {
        self.init(nil as Any?)
    }

    public init(booleanLiteral value: Bool) {
        self.init(value)
    }

    public init(integerLiteral value: Int) {
        self.init(value)
    }

    public init(floatLiteral value: Double) {
        self.init(value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }

    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }

    public init(dictionaryLiteral elements: (AnyHashable, Any)...) {
        self.init([AnyHashable: Any](elements, uniquingKeysWith: { first, _ in first }))
    }

}

public protocol ResponseDTO: Codable, Equatable {}

public protocol ResponseDecoder {
    func decode<T: Decodable>(_ type: T.Type, from: Data) throws -> T
}

extension JSONDecoder: ResponseDecoder {}

public protocol RequestEncoder {

    func encode<T: Encodable>(_ value: T) throws -> Data

}

extension JSONEncoder: RequestEncoder {}

extension ResponseDTO {

    public func encode() -> [String: Any] {
        guard
            let jsonData = try? JSONEncoder().encode(self),
            let jsonValue = try? JSONSerialization.jsonObject(with: jsonData),
            let jsonDictionary = jsonValue as? [String: Any]
        else {
            return [:]
        }
        return jsonDictionary
    }

}

public struct StringCodingKey: CodingKey, ExpressibleByStringLiteral {

    private let string: String
    private let int: Int?

    public var stringValue: String { string }

    public init(string: String) {
        self.string = string
        int = nil
    }
    public init?(stringValue: String) {
        string = stringValue
        int = nil
    }

    public var intValue: Int? { int }
    public init?(intValue: Int) {
        string = String(describing: intValue)
        int = intValue
    }

    public init(stringLiteral value: String) {
        string = value
        int = nil
    }

}

// MARK: - Any json decoding

extension ResponseDecoder {

    func decodeAny<T>(_ type: T.Type, from data: Data) throws -> T {
        guard let decoded = try decode(AnyCodable.self, from: data) as? T else {
            throw DecodingError.typeMismatch(T.self, DecodingError.Context(codingPath: [StringCodingKey(string: "")], debugDescription: "Decoding of \(T.self) failed"))
        }
        return decoded
    }

}

// MARK: - Any decoding

extension KeyedDecodingContainer {

    func decodeAny<T>(_ type: T.Type, forKey key: K) throws -> T {
        guard let value = try decode(AnyCodable.self, forKey: key).value as? T else {
            throw DecodingError.typeMismatch(T.self, DecodingError.Context(codingPath: codingPath, debugDescription: "Decoding of \(T.self) failed"))
        }
        return value
    }

    func decodeAnyIfPresent<T>(_ type: T.Type, forKey key: K) throws -> T? {
        try decodeOptional {
            guard let value = try decodeIfPresent(AnyCodable.self, forKey: key)?.value else { return nil }
            guard let typedValue = value as? T else {
                throw DecodingError.typeMismatch(T.self, DecodingError.Context(codingPath: codingPath, debugDescription: "Decoding of \(T.self) failed"))
            }
            return typedValue
        }
    }

    func toDictionary() throws -> [String: Any] {
        var dictionary: [String: Any] = [:]
        for key in allKeys {
            dictionary[key.stringValue] = try decodeAny(key)
        }
        return dictionary
    }

    public func decode<T>(_ key: KeyedDecodingContainer.Key) throws -> T where T: Decodable {
        try decode(T.self, forKey: key)
    }

    public func decodeIfPresent<T>(_ key: KeyedDecodingContainer.Key) throws -> T? where T: Decodable {
        try decodeOptional {
            try decodeIfPresent(T.self, forKey: key)
        }
    }

    func decodeAny<T>(_ key: K) throws -> T {
        try decodeAny(T.self, forKey: key)
    }

    func decodeAnyIfPresent<T>(_ key: K) throws -> T? {
        try decodeAnyIfPresent(T.self, forKey: key)
    }

    public func decodeArray<T: Decodable>(_ key: K) throws -> [T] {
        var container: UnkeyedDecodingContainer
        var array: [T] = []

        do {
            container = try nestedUnkeyedContainer(forKey: key)
        } catch {
            guard Settings.safeArrayDecoding else {
                throw error
            }
            return array
        }

        while !container.isAtEnd {
            do {
                let element = try container.decode(T.self)
                array.append(element)
            } catch {
                guard Settings.safeArrayDecoding else {
                    throw error
                }
                // hack to advance the current index
                _ = try? container.decode(AnyCodable.self)
            }
        }
        return array
    }

    public func decodeArrayIfPresent<T: Decodable>(_ key: K) throws -> [T]? {
        try decodeOptional {
            guard contains(key) else {
                return nil
            }
            return try decodeArray(key)
        }
    }

    fileprivate func decodeOptional<T>(_ closure: () throws -> T?) throws -> T? {
        guard Settings.safeOptionalDecoding else {
            return try closure()
        }
        do {
            return try closure()
        } catch {
            return nil
        }
    }

}

// MARK: - Any encoding

extension KeyedEncodingContainer {

    mutating func encodeAnyIfPresent<T>(_ value: T?, forKey key: K) throws {
        guard let value = value else { return }
        try encodeIfPresent(AnyCodable(value), forKey: key)
    }

    mutating func encodeAny<T>(_ value: T, forKey key: K) throws {
        try encode(AnyCodable(value), forKey: key)
    }

}

// MARK: - Date structs for date and date-time formats

extension DateFormatter {

    convenience init(formatString: String, locale: Locale? = nil, timeZone: TimeZone? = nil, calendar: Calendar? = nil) {
        self.init()
        dateFormat = formatString
        if let locale = locale {
            self.locale = locale
        }
        if let timeZone = timeZone {
            self.timeZone = timeZone
        }
        if let calendar = calendar {
            self.calendar = calendar
        }
    }

    convenience init(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) {
        self.init()
        self.dateStyle = dateStyle
        self.timeStyle = timeStyle
    }

}

private let dateDecoder: (Decoder) throws -> Date = { decoder in
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)

    let formatterWithMilliseconds = DateFormatter()
    formatterWithMilliseconds.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    formatterWithMilliseconds.locale = Locale(identifier: "en_US_POSIX")
    formatterWithMilliseconds.timeZone = TimeZone(identifier: "UTC")
    formatterWithMilliseconds.calendar = Calendar(identifier: .gregorian)

    let formatterWithoutMilliseconds = DateFormatter()
    formatterWithoutMilliseconds.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    formatterWithoutMilliseconds.locale = Locale(identifier: "en_US_POSIX")
    formatterWithoutMilliseconds.timeZone = TimeZone(identifier: "UTC")
    formatterWithoutMilliseconds.calendar = Calendar(identifier: .gregorian)

    guard let date = formatterWithMilliseconds.date(from: string) ?? formatterWithoutMilliseconds.date(from: string) else {
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Could not decode date")
    }
    return date
}

public struct DateDay: Codable, Comparable {

    /// The date formatter used for encoding and decoding
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = .current
        return formatter
    }()

    public let date: Date
    public let year: Int
    public let month: Int
    public let day: Int

    public init(date: Date = Date()) {
        self.date = date
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
        guard let year = dateComponents.year,
            let month = dateComponents.month,
            let day = dateComponents.day
        else {
            fatalError("Date does not contain correct components")
        }
        self.year = year
        self.month = month
        self.day = day
    }

    public init(year: Int, month: Int, day: Int) {
        let dateComponents = DateComponents(calendar: .current, year: year, month: month, day: day)
        guard let date = dateComponents.date else {
            fatalError("Could not create date in current calendar")
        }
        self.date = date
        self.year = year
        self.month = month
        self.day = day
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let date = DateDay.dateFormatter.date(from: string) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Date not in correct format of \(DateDay.dateFormatter.dateFormat ?? "")")
        }
        self.init(date: date)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let string = DateDay.dateFormatter.string(from: date)
        try container.encode(string)
    }

    public static func == (lhs: DateDay, rhs: DateDay) -> Bool {
        lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day
    }

    public static func < (lhs: DateDay, rhs: DateDay) -> Bool {
        lhs.date < rhs.date
    }

}

extension DateFormatter {

    public func string(from dateDay: DateDay) -> String {
        string(from: dateDay.date)
    }

}

// MARK: - Parameter encoding

extension DateDay {
    public func encode() -> Any {
        DateDay.dateFormatter.string(from: date)
    }
}

extension Date {
    public func encode() -> Any {
        Settings.dateEncodingFormatter.string(from: self)
    }
}

extension URL {
    public func encode() -> Any {
        absoluteString
    }
}

extension RawRepresentable {
    public func encode() -> Any {
        rawValue
    }
}

extension Array where Element: RawRepresentable {
    public func encode() -> [Any] {
        map { $0.rawValue }
    }
}

extension Dictionary where Key == String, Value: RawRepresentable {
    public func encode() -> [String: Any] {
        mapValues { $0.rawValue }
    }
}

extension UUID {
    public func encode() -> Any {
        uuidString
    }
}

extension String {
    public func encode() -> Any {
        self
    }
}

extension Data {
    public func encode() -> Any {
        self
    }
}

enum Settings {

    static var safeOptionalDecoding = true

    static var safeArrayDecoding = true

    static var dateEncodingFormatter = DateFormatter(
        formatString: "yyyy-MM-dd'T'HH:mm:ssZZZZZ",
        locale: Locale(identifier: "ko_KR"),
        calendar: Calendar(identifier: .gregorian)
    )

}
