/*
 This file defines the Block entity, which represents a single unit of content within a Prompt.
 It is the atomic building block of the Prompt IDE data model.
 Layer: Domain
*/

import Foundation

/// Represents a distinct unit of content within a prompt.
/// Blocks are immutable value types.
public struct Block: Identifiable, Equatable, Sendable {
    
    /// The unique identifier for this block.
    public let id: UUID
    
    /// The specific type and associated data of the block.
    public let content: BlockContent
    
    /// The ordering index of this block within its parent prompt.
    public let orderIndex: Int
    
    /// Initialises a new Block instance.
    ///
    /// - Parameters:
    ///   - id: Unique identifier (defaults to new UUID).
    ///   - content: The content payload (Text, Heading, etc.).
    ///   - orderIndex: The visual sort order.
    public init(id: UUID = UUID(), content: BlockContent, orderIndex: Int) {
        self.id = id
        self.content = content
        self.orderIndex = orderIndex
    }
}

/// Defines the variations of content a Block can hold.
public enum BlockContent: Equatable, Sendable {
    
    /// A standard paragraph of text.
    case text(String)
    
    /// A structural heading for organization.
    case heading(String)
    
    /// A visual separator line.
    case separator
    
    /// A reference to a variable placeholder.
    case variableReference(name: String)
    
    /// Returns the plain text representation of the content.
    public var rawValue: String {
        switch self {
        case .text(let value): return value
        case .heading(let value): return value
        case .separator: return "---"
        case .variableReference(let name): return "{{\(name)}}"
        }
    }
}
