/*
 This file defines the KeychainHelper, which is responsible for the secure storage and retrieval of encryption keys.
 It acts as a wrapper around the Apple Security (SecItem) APIs.
 It does not handle general data persistence or UI interaction.
 Layer: Data (Infrastructure)
*/

import Foundation
import Security

/// A protocol defining the contract for keychain operations, enabling testability.
public protocol KeychainServiceProtocol: Sendable {
    /// Stores a data item in the keychain securely.
    func save(key: String, data: Data) throws
    /// Retrieves a data item from the keychain.
    func load(key: String) throws -> Data
    /// Deletes a data item from the keychain.
    func delete(key: String) throws
}

/// Errors specific to Keychain operations.
public enum KeychainError: Error, LocalizedError {
    case duplicateEntry
    case unknown(OSStatus)
    case itemNotFound
    case dataConversionError
    
    public var errorDescription: String? {
        switch self {
        case .duplicateEntry:
            return "Item already exists in the keychain."
        case .unknown(let status):
            return "System error with status code: \(status)."
        case .itemNotFound:
            return "Item not found in the keychain."
        case .dataConversionError:
            return "Unable to convert data to expected format."
        }
    }
}

/// A concrete implementation of KeychainServiceProtocol using system SecItem APIs.
public final class KeychainHelper: KeychainServiceProtocol {
    
    public init() {}
    
    /// Saves data to the keychain with a specific key.
    ///
    /// - Parameters:
    ///   - key: The unique identifier for the keychain item.
    ///   - data: The raw data to be stored.
    /// - Throws: `KeychainError.duplicateEntry` if item exists, or `KeychainError.unknown` for other failures.
    public func save(key: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            throw KeychainError.duplicateEntry
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }
    
    /// Loads data from the keychain for a specific key.
    ///
    /// - Parameter key: The unique identifier for the keychain item.
    /// - Returns: The stored Data.
    /// - Throws: `KeychainError.itemNotFound` if not present, or `KeychainError.unknown` for other failures.
    public func load(key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.itemNotFound
            }
            throw KeychainError.unknown(status)
        }
        
        guard let data = dataTypeRef as? Data else {
            throw KeychainError.dataConversionError
        }
        
        return data
    }
    
    /// Deletes a specific item from the keychain.
    ///
    /// - Parameter key: The unique identifier for the keychain item.
    /// - Throws: `KeychainError.unknown` if deletion fails. (Ignores itemNotFound).
    public func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        // We consider 'item not found' as a success (idempotent delete)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.unknown(status)
        }
    }
}
