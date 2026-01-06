/*
 BlockType: A presentation-layer enum for Block content types.
 Layer: App (Editor/Models)
*/

import Foundation
import PromptIDE_Domain

/// Represents the visual type of a block, used for menus and UI labels.
/// Maps from Domain.BlockContent to a UI-friendly format.
public enum BlockType: String, CaseIterable, Identifiable, Sendable {
    case text
    case heading
    case separator
    // case variable (Future)
    
    public var id: String { rawValue }
    
    /// A human-readable label in British English.
    public var label: String {
        switch self {
        case .text: return "Text"
        case .heading: return "Heading"
        case .separator: return "Separator"
        }
    }
    
    /// The associated SF Symbol name.
    public var icon: String {
        switch self {
        case .text: return "text.alignleft"
        case .heading: return "textformat.size" // or "h.square"
        case .separator: return "minus"
        }
    }
    
    /// Maps a UI BlockType to a default Domain.BlockContent.
    public func defaultContent() -> BlockContent {
        switch self {
        case .text: return .text("")
        case .heading: return .heading("")
        case .separator: return .separator
        }
    }
}
