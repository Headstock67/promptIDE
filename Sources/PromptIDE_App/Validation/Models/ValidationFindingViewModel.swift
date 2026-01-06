/*
 ValidationFindingViewModel.swift
 Layer: App (Validation/Models)
 
 A view-ready representation of a validation finding.
 Contains all text and metadata needed to render the finding card.
 Does NOT contain analysis logic.
*/

import Foundation
import PromptIDE_Domain

public struct ValidationFindingViewModel: Identifiable, Hashable, Sendable {
    
    public let id: UUID
    public let category: ValidationCategory
    public let title: String
    public let message: String
    
    /// The ID of the block where this finding was found.
    public let blockID: UUID
    
    /// The snippet of text to display in the card (context).
    public let snippet: String
    
    // Future: Range<String.Index> for text highlighting (optional in 1.2c)
    
    public init(
        id: UUID = UUID(),
        category: ValidationCategory,
        title: String,
        message: String,
        blockID: UUID,
        snippet: String
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.message = message
        self.blockID = blockID
        self.snippet = snippet
    }
}
