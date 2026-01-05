/*
 This file defines the AppLockService, which interfaces with LocalAuthentication (FaceID/TouchID).
 It exposes authentication capabilities but contains no UI logic or lifecycle hooks.
 Layer: Data (Infrastructure)
*/

import Foundation
import LocalAuthentication

/// A protocol defining biometric authentication capabilities.
public protocol AppLockServiceProtocol {
    /// Checks if the device supports biometric authentication.
    func canAuthenticate() -> Bool
    
    /// Requests user authentication via the system biometric prompt.
    /// - Parameter reason: The localized string explaining why auth is requested.
    /// - Returns: Boolean indicating success or failure.
    /// - Throws: Error if the system request fails.
    func authenticate(reason: String) async throws -> Bool
}

/// Errors specific to AppLock operations.
public enum AppLockError: Error, LocalizedError {
    case biometricsUnavailable
    case authenticationFailed(Error)
    
    public var errorDescription: String? {
        switch self {
        case .biometricsUnavailable:
            return "Biometric authentication is not available on this device."
        case .authenticationFailed(let error):
            return "Authentication failed: \(error.localizedDescription)"
        }
    }
}

/// A concrete implementation of AppLockServiceProtocol using LAContext.
public final class AppLockService: AppLockServiceProtocol {
    
    public init() {}
    
    /// Checks if the device holds the capability for biometric authentication.
    /// - Returns: True if available, False if not.
    public func canAuthenticate() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    /// triggers the system authentication flow.
    ///
    /// - Parameter reason: The string displayed to the user in the prompt.
    /// - Returns: True if successful.
    /// - Throws: AppLockError if evaluation throws or fails.
    public func authenticate(reason: String) async throws -> Bool {
        let context = LAContext()
        
        // First verify availability again to be safe
        guard canAuthenticate() else {
            throw AppLockError.biometricsUnavailable
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                if let error = error {
                    continuation.resume(throwing: AppLockError.authenticationFailed(error))
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }
}
