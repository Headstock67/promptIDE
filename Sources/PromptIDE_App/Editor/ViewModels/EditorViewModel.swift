/*
 EditorViewModel: Manages the transient state of the prompt editor.
 Layer: App (Editor/ViewModels)
 Responsibilities:
 - Holds the list of Blocks in memory.
 - Handles user intents (Add, Move, Delete).
 - Manages interaction state (Drag, Focus).
 Exclusions:
 - No Validation Logic.
 - No Persistence (Delegates to Repository eventually, but mock for Phase 1.2b).
 - No Policy checks.
*/

import Foundation
import SwiftUI
import PromptIDE_Domain

@MainActor
public class EditorViewModel: ObservableObject {
    
    // MARK: - State
    
    /// The ordered list of blocks being edited.
    @Published public var blocks: [Block] = []
    
    /// The currently selected block ID (for visual highlighting/options).
    @Published public var selectedBlockID: UUID?
    
    // MARK: - Initialization
    
    public init(initialBlocks: [Block] = []) {
        self.blocks = initialBlocks
    }
    
    // MARK: - Intents
    
    /// Adds a new block of the specified type.
    /// - Parameter type: The UI BlockType to create.
    public func addBlock(type: BlockType) {
        let newContent = type.defaultContent()
        let newBlock = Block(
            content: newContent,
            orderIndex: blocks.count // Append to end
        )
        
        withAnimation(.snappy) {
            blocks.append(newBlock)
            // Auto-select new block
            selectedBlockID = newBlock.id
        }
    }
    
    /// Deletes the block with the given ID.
    public func deleteBlock(id: UUID) {
        withAnimation(.snappy) {
            blocks.removeAll { $0.id == id }
            if selectedBlockID == id {
                selectedBlockID = nil
            }
        }
    }
    
    /// Updates the text content of a block.
    public func updateBlockContent(id: UUID, text: String) {
        guard let index = blocks.firstIndex(where: { $0.id == id }) else { return }
        
        // Create mutated copy (value semantics)
        var block = blocks[index]
        switch block.content {
        case .text:
            block = Block(id: block.id, content: .text(text), orderIndex: block.orderIndex)
        case .heading:
            block = Block(id: block.id, content: .heading(text), orderIndex: block.orderIndex)
        default:
            return // Other types might not have simple text updates
        }
        
        blocks[index] = block
    }
    
    /// Handles drag-and-drop reordering.
    public func moveBlock(from source: IndexSet, to destination: Int) {
        // No animation here, List handles it during drag
        blocks.move(fromOffsets: source, toOffset: destination)
        
        // Re-index logic would normally happen here or on save
        // for now, transient order is sufficient.
    }
}
