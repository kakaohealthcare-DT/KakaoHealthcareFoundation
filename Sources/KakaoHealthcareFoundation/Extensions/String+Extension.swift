//
//  String+Extension.swift
//  SampleKit
//
//  Created by nobleidea on 2023/04/04.
//

import Foundation

public extension String {
    func convertDate(
        beforeFormatter: DateFormatter,
        afterFormatter: DateFormatter
    ) -> Self {
        guard let convertDate = beforeFormatter.date(from: self) else { fatalError("Unsupported format") }
        return afterFormatter.string(from: convertDate)
    }

    var isBlank: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func urlEncode() -> String? {
        self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }

    // Encode `self` with URL escaping considered.
    var base64URLEncoded: String {
        self.replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    var base64URLDecoded: String? {
        guard let data = self.base64URLDecodedData else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    // Returns the data of `self` (which is a base64 string), with URL related characters decoded.
    var base64URLDecodedData: Data? {
        let paddingLength = 4 - count % 4
        // Filling = for %4 padding.
        let padding = (paddingLength < 4) ? String(repeating: "=", count: paddingLength) : ""
        let base64EncodedString = self
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
            + padding
        return Data(base64Encoded: base64EncodedString)
    }

    // Returns the data of `self` (which is a base64 string), with URL related characters decoded.
    var restoreBase64URLDecoded: String {
        let paddingLength = 4 - count % 4
        // Filling = for %4 padding.
        let padding = (paddingLength < 4) ? String(repeating: "=", count: paddingLength) : ""
        let base64EncodedString = self
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
            + padding
        return base64EncodedString
    }
}

public extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        guard let text = self else {
            return true
        }

        return text.isBlank
    }

    var isNotNilOrEmpty: Bool { !isNilOrEmpty }
}

extension String: Error, LocalizedError {
    public var errorDescription: String? { self }
}

// FIXME: - dateformat
public extension String {
	func toDate(format: Date.Format = .yyyyMMdd) -> Date? {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format.value
		dateFormatter.timeZone = .autoupdatingCurrent
		dateFormatter.locale = .autoupdatingCurrent
		return dateFormatter.date(from: self)
	}
}

public extension Substring {
	func asString() -> String {
		String(self)
	}
}
