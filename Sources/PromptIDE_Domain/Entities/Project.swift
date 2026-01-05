/*
 This file defines the Project entity, which serves as a container or folder for Prompts.
 Layer: Domain
*/

import Foundation

/// Represents a high-level container for organizing Prompts.
public struct Project: Identifiable, Equatable, Sendable {
    
    /// Unique identifier for the project.
    public let id: UUID
    
    /// User-facing name of the project.
    public let name: String
    
    /// Provides a brief description of the project's purpose.
    public let summary: String
    
    /// Timestamp of creation.
    public let createdAt: Date
    
    /// Initialises a new Project instance.
    public init(
        id: UUID = UUID(),
        name: String,
        summary: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.createdAt = createdAt
    }
}
