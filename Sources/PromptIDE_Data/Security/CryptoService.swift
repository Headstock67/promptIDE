/*
 This file defines the CryptoService, which handles authenticated encryption and decryption of data.
 It uses Apple's CryptoKit (AES-GCM) for strong security and performance.
 It relies on an injected KeychainServiceProtocol to retrieve the necessary keys.
 Layer: Data (Infrastructure)
*/

import Foundation
import CryptoKit

import PromptIDE_Domain

/// A protocol defining encryption and decryption capabilities.
// Refactoring: Use Domain Protocol instead or alias it?
// For now, let's just make CryptoService conform to SecurityServiceProtocol directly.

/// Errors specific to Cryptographic operations.
public enum CryptoError: Error, LocalizedError {
    case keyGenerationFailed
    case encryptionFailed
    case decryptionFailed
    case stringEncodingError
    
    public var errorDescription: String? {
        switch self {
        case .keyGenerationFailed: return "Failed to generate or retrieve the encryption key."
        case .encryptionFailed: return "AES-GCM encryption operation failed."
        case .decryptionFailed: return "AES-GCM decryption operation failed (Check key or data integrity)."
        case .stringEncodingError: return "Unable to encode/decode string to UTF-8 data."
        }
    }
}

/// A concrete implementation of SecurityServiceProtocol using AES-GCM.
public final class CryptoService: SecurityServiceProtocol, Sendable {
    
    private let keychain: KeychainServiceProtocol
    private let keyIdentifier = "com.antigravity.promptide.masterkey"
    
    /// Initialises the CryptoService with a keychain provider.
    /// - Parameter keychain: The keychain service used to store the master key.
    public init(keychain: KeychainServiceProtocol) {
        self.keychain = keychain
    }
    
    /// Retrieves the existing symmetric key or generates a new one if missing.
    /// - Returns: A 256-bit SymmetricKey.
    /// - Throws: CryptoError if keychain operations fail.
    private func getOrGenerateKey() throws -> SymmetricKey {
        // Attempt to load existing key
        if let keyData = try? keychain.load(key: keyIdentifier) {
            return SymmetricKey(data: keyData)
        }
        
        // Generate new key
        let newKey = SymmetricKey(size: .bits256)
        
        // Save to keychain
        // Note: In production, we should handle save failures more gracefully,
        // but for now we propagate the error.
        do {
            try keychain.save(key: keyIdentifier, data: newKey.withUnsafeBytes { Data($0) })
            return newKey
        } catch {
            throw CryptoError.keyGenerationFailed
        }
    }
    
    /// Encrypts a string using AES-GCM with a retrieved key.
    ///
    /// - Parameter plaintext: The plaintext content.
    /// - Returns: The combined box (Nonce + Ciphertext + Tag) as Data.
    /// - Throws: CryptoError.
    public func encrypt(plaintext: String) throws -> Data {
        guard let data = plaintext.data(using: .utf8) else {
            throw CryptoError.stringEncodingError
        }
        
        let key = try getOrGenerateKey()
        
        do {
            // AES.GCM.seal() generates a random nonce automatically.
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined ?? Data()
        } catch {
            throw CryptoError.encryptionFailed
        }
    }
    
    /// Decrypts data using AES-GCM with a retrieved key.
    ///
    /// - Parameter ciphertext: The combined box data (Nonce + Ciphertext + Tag).
    /// - Returns: The decrypted plaintext string.
    /// - Throws: CryptoError.
    public func decrypt(ciphertext: Data) throws -> String {
        let key = try getOrGenerateKey()
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: ciphertext)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            
            guard let string = String(data: decryptedData, encoding: .utf8) else {
                throw CryptoError.stringEncodingError
            }
            return string
        } catch {
            throw CryptoError.decryptionFailed
        }
    }
}
