/*
 This file defines the Prompt entity, which is the primary document type in the application.
 It aggregates a collection of Blocks and maintains metadata.
 Layer: Domain
*/

import Foundation

/// Represents a user-created prompt.
/// A Prompt is an immutable aggregate root containing an ordered list of Blocks.
public struct Prompt: Identifiable, Equatable, Sendable {
    
    /// Unique identifier for the prompt.
    public let id: UUID
    
    /// User-defined title.
    public let title: String
    
    /// Ordered collection of content blocks.
    public let blocks: [Block]
    
    /// Timestamp of prompt creation.
    public let createdAt: Date
    
    /// Timestamp of last modification.
    public let updatedAt: Date
    
    /// Computed convenience: Sorts blocks by index.
    public var orderedBlocks: [Block] {
        blocks.sorted { $0.orderIndex < $1.orderIndex }
    }
    
    /// Initialises a new Prompt instance.
    ///
    /// - Parameters:
    ///   - id: Unique identifier.
    ///   - title: Visible title.
    ///   - blocks: Collection of constituent blocks.
    ///   - createdAt: Creation date.
    ///   - updatedAt: Last modified date.
    public init(
        id: UUID = UUID(),
        title: String,
        blocks: [Block],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.blocks = blocks
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
