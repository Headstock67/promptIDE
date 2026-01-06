/*
 EditorFocusState: Granular focus management for the editor.
 Layer: App (Editor/Models)
*/

import Foundation

/// Defines what part of the editor is currently focused.
public enum EditorFocusState: Hashable, Sendable {
    
    /// The entire canvas is focused (no specific block).
    case canvas
    
    /// A specific block ID is focused.
    /// Used for keyboard navigation and text entry.
    case block(UUID)
    
    // We might need field-specific focus within a block later (e.g., Variable Name vs Default Value).
}
