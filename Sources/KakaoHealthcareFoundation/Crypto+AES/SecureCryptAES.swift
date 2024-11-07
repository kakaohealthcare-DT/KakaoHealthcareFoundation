//
//  SecureCryptAES.swift
//  FoundationExtension
//
//  Created by Cha on 7/16/24.
//  Copyright © 2024 Kakao Healthcare Corp. All rights reserved.
//

import Foundation
import CommonCrypto

public protocol SecureEncryptable {
	static func encrypt(
		mode: AESMode,
		payload: Data
	) throws -> String
}

extension SecureEncryptable {
	static func encrypt(
		secretKeyStream: [UInt8],
		paddingStream: [UInt8],
		payload: [UInt8]
	) throws -> [UInt8] {
		var cipherPayload = [UInt8](repeating: 0, count: payload.count + kCCBlockSizeAES128)
		var ciphertextCount = 0
		
		let err = CCCrypt(
			CCOperation(kCCEncrypt),
			CCAlgorithm(kCCAlgorithmAES),
			CCOptions(kCCOptionPKCS7Padding),
			secretKeyStream,
			secretKeyStream.count,
			paddingStream,
			payload,
			payload.count,
			&cipherPayload,
			cipherPayload.count,
			&ciphertextCount
		)
		
		guard err == kCCSuccess else {
			throw SecureCryptoError.encryptionError
		}
		
		cipherPayload.removeLast(cipherPayload.count - ciphertextCount)
		
		guard ciphertextCount <= cipherPayload.count, cipherPayload.count.isMultiple(of: kCCBlockSizeAES128) else {
			throw SecureCryptoError.encryptionError
		}
		
		return cipherPayload
	}
}

public protocol SecureDecryptable {
	static func decrypt(
		mode: AESMode,
		cypher: Data
	) throws -> Data
}

extension SecureDecryptable {
	static func decrypt(
		secretKeyStream: [UInt8],
		paddingStream: [UInt8],
		cypher: [UInt8]
	) throws -> [UInt8] {
		guard cypher.count.isMultiple(of: kCCBlockSizeAES128) else {
			throw SecureCryptoError.invalidParameters
		}
		
		var plainPayload = [UInt8](repeating: 0, count: cypher.count)
		var plainPayloadCount = 0
		
		let err = CCCrypt(
			CCOperation(kCCDecrypt),
			CCAlgorithm(kCCAlgorithmAES),
			CCOptions(kCCOptionPKCS7Padding),
			secretKeyStream,
			secretKeyStream.count,
			paddingStream,
			cypher,
			cypher.count,
			&plainPayload,
			plainPayload.count,
			&plainPayloadCount
		)
		
		guard err == kCCSuccess else {
			throw SecureCryptoError.decryptionError
		}
		
		plainPayload.removeLast(plainPayload.count - plainPayloadCount)
		
		guard plainPayloadCount <= plainPayload.count else {
			throw SecureCryptoError.decryptionError
		}
		
		return plainPayload
	}
}

public enum SecureCryptoError: Error {
	case invalidParameters
	case invalidOperation
	case encryptionError
	case decryptionError
}

public enum AESMode {
	case cbc(secretKey: String, iv: String)
}

public final class SecureCryptAES {
	//	private let secretKey: String
	//	private let iv: String
	//
	//	private var secretKeyStream: [UInt8] {
	//		Array(secretKey.utf8)
	//	}
	//
	//	private var paddingStream: [UInt8] {
	//		Array(iv.utf8)
	//	}
	//
	//	public init(
	//		mode: AESMode
	//	) throws {
	//		guard
	//			[kCCKeySizeAES128, kCCKeySizeAES192, kCCKeySizeAES256].contains(secretKey.count),
	//			iv.count == kCCBlockSizeAES128
	//		else {
	//			throw SecureCryptoError.invalidParameters
	//		}
	//		self.iv = iv
	//		self.secretKey = secretKey
	//	}
}

extension SecureCryptAES: SecureEncryptable {
	public static func encrypt(
		mode: AESMode,
		payload: Data
	) throws -> String {
		guard
			case let .cbc(secretKey, iv) = mode,
			[kCCKeySizeAES128, kCCKeySizeAES192, kCCKeySizeAES256].contains(secretKey.count),
			iv.count == kCCBlockSizeAES128
		else {
			throw SecureCryptoError.invalidParameters
		}
		
		guard
			let payloadEncodedString: String = String(data: payload, encoding: .utf8) else {
			throw SecureCryptoError.invalidOperation
		}
		
		let cypherTextEncodedStream = try Self.encrypt(
			secretKeyStream: Array(secretKey.utf8),
			paddingStream: Array(iv.utf8),
			payload: Array(payloadEncodedString.utf8)
		)
		
		let cypherTextEncodedData = Data(cypherTextEncodedStream)
		let cypherText = cypherTextEncodedData.base64URLEncodedString
		
		return cypherText
	}
}

extension SecureCryptAES: SecureDecryptable {
	public static func decrypt(
		mode: AESMode,
		cypher: Data
	) throws -> Data {
		let plainTextEncodedStream: [UInt8]
		
		switch mode {
		case let .cbc(secretKey, iv):
			plainTextEncodedStream = try Self.decrypt(
				secretKeyStream: Array(secretKey.utf8),
				paddingStream: Array(iv.utf8),
				cypher: Array(cypher)
			)
		}
		
		let plainTextEncodedData = Data(plainTextEncodedStream)
		
//		guard let plainText = try? JSONDecoder().decode(T.self, from: plainTextEncodedData) else {
//			throw SecureCryptoError.invalidOperation
//		}
		
		return plainTextEncodedData
	}
}
