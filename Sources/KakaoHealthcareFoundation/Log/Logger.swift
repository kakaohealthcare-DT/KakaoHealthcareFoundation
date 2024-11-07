//
//  Logger.swift
//  DTFoundation
//
//  Created by kyle.cha on 2023/01/27.
//

import Foundation
import os.log

extension OSLog {
	static fileprivate(set) var subsystem: String = ""
}

public extension Logger {
	static func register(_ bundleIdentifier: String) {
		OSLog.subsystem = bundleIdentifier
	}
}

public enum Logger {
	// spec: https://developer.apple.com/documentation/oslog/oslogentrylog/level-swift.enum
	enum Level {
		case debug
		case trace(String)
		case info
		case network
		case error
		case fault
		
		fileprivate var category: String {
			switch self {
			case .debug:
				return "🟢 DEBUG"
			case .info:
				return "🔵 INFO"
			case .network:
				return "🟡 NETWORK"
			case .error:
				return "🔴 ERROR"
			case let .trace(trace):
				let prefix = trace.isNotEmpty ? trace : "✨"
				return "\(prefix)"
			case .fault:
				return "‼️ FAULT"
			}
		}
		
		fileprivate var osLogType: OSLogType {
			switch self {
			case .debug:
				return .debug
			case .info:
				return .info
			case .network:
				return .default
			case .error:
				return .error
			case .trace:
				return .debug
			case .fault:
				return .fault
			}
		}
	}
	
	static private func log(_ message: Any, _ arguments: [Any], level: Level) {
		let extraMessage: String = arguments.map { String(describing: $0) }.joined(separator: " ")
		
		let logger = os.Logger(subsystem: OSLog.subsystem, category: level.category)
		let logMessage = "\(message) \(extraMessage)"
		switch level {
		case .debug, .trace:
			if #available(iOS 17, *) {
				logger.debug("\("\(level.category) \(logMessage)", privacy: .public)")
			} else {
				logger.debug("\(logMessage, privacy: .public)")
			}
		case .info:
			logger.info("\(logMessage, privacy: .public)")
		case .network:
			logger.log("\(logMessage, privacy: .public)")
		case .error:
			logger.error("\(logMessage, privacy: .public)")
		case .fault:
			logger.fault("\(logMessage, privacy: .private)")
		}
	}
}

public extension Logger {
	static func debug(_ message: Any, _ arguments: Any...) {
		log(message, arguments, level: .debug)
	}
	
	static func debug(_ message: Any) {
		log(message, [], level: .debug)
	}
	
	static func info(_ message: Any, _ arguments: Any...) {
		log(message, arguments, level: .info)
	}
	
	static func network(_ message: Any, _ arguments: Any...) {
		log(message, arguments, level: .network)
	}
	
	static func error(_ message: Any, _ arguments: Any...) {
		log(message, arguments, level: .error)
	}
	
	static func trace(_ trace: String, _ message: Any, _ arguments: Any...) {
		log(message, arguments, level: .trace(trace))
	}
	
	static func fault(_ message: Any, _ arguments: Any...) {
		log(message, arguments, level: .fault)
	}
}
