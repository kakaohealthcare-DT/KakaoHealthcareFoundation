//
//  Task+Extension.swift
//  FoundationExtension
//
//  Created by kyle.cha on 11/24/23.
//  Copyright © 2023 Kakao Healthcare Corp. All rights reserved.
//

import Foundation

public extension Task where Failure == Error {
	static func delayed(
		byTimeInterval delayInterval: TimeInterval,
		priority: TaskPriority? = nil,
		@_implicitSelfCapture operation: @escaping @Sendable () async throws -> Success
	) -> Task {
		Task(priority: priority) {
			// 1_000_000_000 (a second)
			let delay = UInt64(delayInterval * 1_000_000_000/* a sencond*/)
			try await Task<Never, Never>.sleep(nanoseconds: delay)
			return try await operation()
		}
	}
}

public extension Task where Success == Never, Failure == Never {
	static func sleep(seconds: Double) async throws {
		let duration = UInt64(seconds * 1_000_000_000)
		try await Task.sleep(nanoseconds: duration)
	}
}

public extension Task where Failure == Never, Success == Void {
	@discardableResult
	init(priority: TaskPriority? = nil, operation: @escaping () async throws -> Void, `catch`: @escaping (Error) -> Void) {
		self.init(priority: priority) {
			do {
				_ = try await operation()
			} catch {
				`catch`(error)
			}
		}
	}
}

// swiftlint:disable all
public enum Async<T> {
	@available(*, deprecated, renamed: "unwrapAsyncSemaphore", message: "Use unwrapAsyncSemaphore, unwrapAsync can occure bad access because it is not sendable")
	public static func unwrapAsync(for value: @Sendable @escaping () async throws -> T) throws -> T {
		var result: Result<T, Error>?
		_ = withUnsafeMutablePointer(to: &result) { ptr in
			Task {
				do {
					ptr.pointee = try await .success(value())
				} catch {
					ptr.pointee = .failure(error)
				}
			}
		}
		while result == nil {
			RunLoop.current.run(mode: .common, before: Date())
		}
		// pointee is guaranteeed to be non-nil at this point
		switch result! {
		case let .success(value): return value
		case let .failure(error): throw error
		}
	}
	class Enclosure {
		var result: T?
	}
	
	public static func unwrapAsyncSemaphore(for value: @Sendable @escaping () async throws -> T? ) -> T? {

		let semaphore = DispatchSemaphore(value: 0)
		let enclosure = Enclosure()
		Task {
			do {
				enclosure.result = try await value()
				semaphore.signal()
			} catch let error {
				semaphore.signal()
			}
		}
		semaphore.wait()
		return enclosure.result
	}
}

// swiftlint:enable all
