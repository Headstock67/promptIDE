/*
 This file defines the ValidationFinding model.
 It represents a single issue or observation detected by the Validation Engine.
 Layer: Domain
*/

import Foundation

/// Categorises the type of validation finding.
public enum ValidationCategory: String, Equatable, Sendable {
    case uncertainty
    case absoluteClaim
    case prohibitedTerm
    case sourceFormatting
}

/// Represents a specific issue found within a piece of text.
public struct ValidationFinding: Identifiable, Equatable, Sendable {
    
    public let id: UUID
    
    /// The category of the finding.
    public let category: ValidationCategory
    
    /// The start and end index of the affected text (relative to the block).
    /// Note: We use simple Int indices here for Domain purity; UI maps them to Range<String.Index>.
    public let startIndex: Int
    public let endIndex: Int
    
    /// A calm, non-judgmental description of the finding.
    public let message: String
    
    /// Initialises a new finding.
    public init(
        id: UUID = UUID(),
        category: ValidationCategory,
        startIndex: Int,
        endIndex: Int,
        message: String
    ) {
        self.id = id
        self.category = category
        self.startIndex = startIndex
        self.endIndex = endIndex
        self.message = message
    }
}
