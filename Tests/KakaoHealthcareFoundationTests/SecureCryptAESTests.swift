//
//  SecureCryptAESTests.swift
//  FoundationExtensionTests
//
//  Created by Cha on 7/16/24.
//  Copyright © 2024 Kakao Healthcare Corp. All rights reserved.
//

import XCTest
@testable import FoundationExtension

class SecureCryptAESTests: XCTestCase {
	
	func testEncryptAndDecryptString() {
		do {
			let plaintext = "화랑, 담배!"
			let encryptedData = try SecureCryptAES
				.encrypt(
					mode: .cbc(
						secretKey: "12345678901234567890123456789012",
						iv: String("1234567890123456".prefix(16))),
					payload: plaintext.data(using: .utf8) ?? Data()
				)

			// Decrypt
			let decryptedData = try SecureCryptAES.decrypt(
				mode: .cbc(
					secretKey: "12345678901234567890123456789012",
					iv: String("1234567890123456".prefix(16))),
				cypher: encryptedData.base64URLDecodedData ?? Data()
			)
			
			let decodedString = String(data: decryptedData, encoding: .utf8)
			XCTAssertEqual(decodedString, plaintext)
			
		} catch {
			XCTFail("Error: \(error)")
		}
	}
	
	func testEncryptAndDecryptCodable() {
		struct TestPayload: Codable, Equatable {
			let code: String
			let message: String
			let data: TestData
		}
		
		struct TestData: Codable, Equatable {
			let id: Int
			let name: String
		}
		
		struct TestData2: Codable, Equatable {
			let memberEmailId: String
			let	verificationCode: String
		}
		
		do {
			let testObj = TestData2(memberEmailId: "1", verificationCode: "111")
			let encodedData = try JSONEncoder().encode(testObj)
			let encryptedData = try SecureCryptAES
				.encrypt(
					mode: .cbc(
						secretKey: "12345678901234567890123456789012",
						iv: String("1234567890123456".prefix(16))),
					payload: encodedData
				)
			
			let data = try SecureCryptAES
				.decrypt(
					mode: .cbc(secretKey: "AES_PRIVATE_KEY_THIS_TEST_32BYTE", iv: String("1234567890123456".prefix(16))),
					cypher: encryptedData.base64URLDecodedData ?? Data()
				)
			
			let decryptedObject = try JSONDecoder().decode(TestData2.self, from: data)
			XCTAssertEqual(decryptedObject, testObj)
		} catch {
			XCTFail("Error: \(error)")
		}
	}
	
	static var allTests = [
		("testEncryptAndDecryptString", testEncryptAndDecryptString),
		("testEncryptAndDecryptCodable", testEncryptAndDecryptCodable),
	]
}
