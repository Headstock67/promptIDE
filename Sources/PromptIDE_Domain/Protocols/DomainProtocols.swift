/*
 This file defines the protocols (contracts) that the Data Layer must fulfil.
 The Domain Layer relies on these abstractions to remain implementation-agnostic.
 Layer: Domain
*/

import Foundation

/// Defines the contract for persistence operations related to Projects and Prompts.
public protocol PromptRepositoryProtocol: Sendable {
    /// Retrieves all projects.
    func fetchProjects() async throws -> [Project]
    
    /// Creates or updates a project.
    func saveProject(_ project: Project) async throws
    
    /// Retrieves a specific prompt by ID.
    func fetchPrompt(id: UUID) async throws -> Prompt?
    
    /// Creates or updates a prompt.
    func savePrompt(_ prompt: Prompt) async throws
    
    /// Soft-deletes a prompt.
    func deletePrompt(id: UUID) async throws
}

/// Defines the contract for cryptographic operations required by the Domain.
/// Note: The Domain does not know about CryptoKit or Keychain directly.
public protocol SecurityServiceProtocol: Sendable {
    /// Requests encryption of a plain string.
    func encrypt(plaintext: String) throws -> Data
    
    /// Requests decryption of data.
    func decrypt(ciphertext: Data) throws -> String
}
