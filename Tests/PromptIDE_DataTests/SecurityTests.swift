/*
 This file contains unit tests for the Security infrastructure (Keychain and CryptoService).
 It uses a MockKeychainService to ensure tests are deterministic and offline.
 Layer: Test (Data)
*/

import XCTest
@testable import PromptIDE_Data

// MARK: - Mocks

/// An in-memory mock of the KeychainServiceProtocol for deterministic testing.
final class MockKeychainService: KeychainServiceProtocol, @unchecked Sendable {
    
    private var storage: [String: Data] = [:]
    
    // Configurable failure injection
    var shouldFailNextSave = false
    var shouldFailNextLoad = false
    
    func save(key: String, data: Data) throws {
        if shouldFailNextSave {
            throw KeychainError.unknown(errSecIO)
        }
        if storage[key] != nil {
            throw KeychainError.duplicateEntry
        }
        storage[key] = data
    }
    
    func load(key: String) throws -> Data {
        if shouldFailNextLoad {
            throw KeychainError.unknown(errSecIO)
        }
        guard let data = storage[key] else {
            throw KeychainError.itemNotFound
        }
        return data
    }
    
    func delete(key: String) throws {
        storage.removeValue(forKey: key)
    }
    
    // Helper for verification
    func contains(key: String) -> Bool {
        return storage[key] != nil
    }
}

// MARK: - Tests

final class SecurityTests: XCTestCase {
    
    var mockKeychain: MockKeychainService!
    var cryptoService: CryptoService!
    
    override func setUp() {
        super.setUp()
        mockKeychain = MockKeychainService()
        cryptoService = CryptoService(keychain: mockKeychain)
    }
    
    override func tearDown() {
        mockKeychain = nil
        cryptoService = nil
        super.tearDown()
    }
    
    // MARK: - Keychain Helper Tests (Via Mock)
    
    func test_mock_keychain_saves_and_loads_data() throws {
        let key = "test_key"
        let data = "secret".data(using: .utf8)!
        
        try mockKeychain.save(key: key, data: data)
        let loadedData = try mockKeychain.load(key: key)
        
        XCTAssertEqual(data, loadedData, "Loaded data should match saved data.")
    }
    
    func test_mock_keychain_throws_duplicate_error() {
        let key = "test_key"
        let data = "secret".data(using: .utf8)!
        
        try? mockKeychain.save(key: key, data: data)
        
        XCTAssertThrowsError(try mockKeychain.save(key: key, data: data)) { error in
            guard let keychainError = error as? KeychainError else {
                XCTFail("Error should be KeychainError")
                return
            }
            if case .duplicateEntry = keychainError {
                // Success
            } else {
                XCTFail("Error should be .duplicateEntry")
            }
        }
    }
    
    func test_mock_keychain_throws_not_found_error() {
        XCTAssertThrowsError(try mockKeychain.load(key: "non_existent")) { error in
            guard let keychainError = error as? KeychainError else {
                XCTFail("Error should be KeychainError")
                return
            }
            if case .itemNotFound = keychainError {
                // Success
            } else {
                XCTFail("Error should be .itemNotFound")
            }
        }
    }

    // MARK: - Crypto Service Tests
    
    func test_crypto_service_encrypts_string_successfully() throws {
        let plaintext = "Hello World"
        
        let encryptedData = try cryptoService.encrypt(plaintext: plaintext)
        
        XCTAssertFalse(encryptedData.isEmpty, "Encrypted data should not be empty")
        XCTAssertNotEqual(plaintext.data(using: .utf8), encryptedData, "Ciphertext should differ from plaintext")
    }
    
    func test_crypto_service_decryption_restores_original_plaintext() throws {
        let plaintext = "Sensitive Information"
        
        let encryptedData = try cryptoService.encrypt(plaintext: plaintext)
        let decryptedString = try cryptoService.decrypt(ciphertext: encryptedData)
        
        XCTAssertEqual(plaintext, decryptedString, "Decrypted string must match original plaintext")
    }
    
    func test_crypto_service_generates_and_stores_key_on_first_use() {
        let plaintext = "Validation Prompt"
        
        _ = try? cryptoService.encrypt(plaintext: plaintext)
        
        // Verify key was stored in the keychain
        XCTAssertTrue(mockKeychain.contains(key: "com.antigravity.promptide.masterkey"), "Master key should be lazy-created and stored in keychain")
    }
    
    func test_crypto_service_uses_different_nonce_for_same_plaintext() throws {
        let plaintext = "Same Text"
        let data1 = try cryptoService.encrypt(plaintext: plaintext)
        let data2 = try cryptoService.encrypt(plaintext: plaintext)
        
        // AES-GCM should produce different outputs for the same input due to random nonce
        XCTAssertNotEqual(data1, data2, "Subsequent encryptions of same text should produce different ciphertexts (Nonce randomization)")
    }
    
    func test_crypto_service_fails_decryption_with_corrupted_data() {
        let plaintext = "Test"
        guard let validEncryptedSequence = try? cryptoService.encrypt(plaintext: plaintext) else {
            XCTFail("Setup failed")
            return
        }
        
        // Corrupt the data (flip last byte)
        var corruptedData = validEncryptedSequence
        corruptedData[corruptedData.count - 1] ^= 0xFF
        
        XCTAssertThrowsError(try cryptoService.decrypt(ciphertext: corruptedData)) { error in
            guard let cryptoError = error as? CryptoError else {
                XCTFail("Should throw CryptoError")
                return
            }
            if case .decryptionFailed = cryptoError {
                // Success
            } else {
                XCTFail("Should be decryptionFailed error")
            }
        }
    }
}
