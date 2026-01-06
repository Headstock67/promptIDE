/*
 EditorViewModelTests.swift
 Tests for the presentation logic of the Prompt Editor.
 
 Responsibilities:
 - Verify transient state management (Blocks list).
 - Verify Intent handling (Add, Move, Delete).
 - Ensure no validation/policy logic is present (by omission).
 
 Layer: Test (App)
*/

import XCTest
import PromptIDE_Domain
@testable import PromptIDE_App

final class EditorViewModelTests: XCTestCase {
    
    // MARK: - Add Block
    
    @MainActor
    func test_add_block_appends_block_to_state() {
        // Given
        let viewModel = EditorViewModel()
        XCTAssertTrue(viewModel.blocks.isEmpty)
        
        // When adding a text block
        viewModel.addBlock(type: .text)
        
        // Then block is appended
        XCTAssertEqual(viewModel.blocks.count, 1)
        XCTAssertEqual(viewModel.blocks.first?.content, .text(""))
        
        // And selected
        XCTAssertEqual(viewModel.selectedBlockID, viewModel.blocks.first?.id)
    }
    
    @MainActor
    func test_add_block_ordering_is_correct() {
        // Given
        let viewModel = EditorViewModel()
        viewModel.addBlock(type: .text)
        let firstID = viewModel.blocks.first?.id
        
        // When adding another
        viewModel.addBlock(type: .heading)
        
        // Then it's appended to the end
        XCTAssertEqual(viewModel.blocks.count, 2)
        XCTAssertEqual(viewModel.blocks[0].id, firstID)
        XCTAssertEqual(viewModel.blocks[1].content, .heading(""))
    }
    
    // MARK: - Delete Block
    
    @MainActor
    func test_delete_block_removes_correct_block() {
        // Given
        let viewModel = EditorViewModel()
        viewModel.addBlock(type: .text)
        viewModel.addBlock(type: .heading)
        let idToDelete = viewModel.blocks[0].id
        let remainingID = viewModel.blocks[1].id
        
        // When deleting the first
        viewModel.deleteBlock(id: idToDelete)
        
        // Then only the second remains
        XCTAssertEqual(viewModel.blocks.count, 1)
        XCTAssertEqual(viewModel.blocks.first?.id, remainingID)
    }
    
    @MainActor
    func test_delete_selected_block_clears_selection() {
        // Given
        let viewModel = EditorViewModel()
        viewModel.addBlock(type: .text)
        let id = viewModel.blocks[0].id
        XCTAssertEqual(viewModel.selectedBlockID, id)
        
        // When
        viewModel.deleteBlock(id: id)
        
        // Then
        XCTAssertNil(viewModel.selectedBlockID)
    }
    
    // MARK: - Move Block
    
    @MainActor
    func test_move_block_updates_order_correctly() {
        // Given
        let viewModel = EditorViewModel()
        viewModel.addBlock(type: .text) // A
        viewModel.addBlock(type: .heading) // B
        viewModel.addBlock(type: .separator) // C
        
        let blockA = viewModel.blocks[0]
        let blockB = viewModel.blocks[1]
        let blockC = viewModel.blocks[2]
        
        // When moving A to position after C (so: B, C, A)
        viewModel.moveBlock(from: IndexSet(integer: 0), to: 3)
        
        // Then
        XCTAssertEqual(viewModel.blocks.count, 3)
        XCTAssertEqual(viewModel.blocks[0].id, blockB.id)
        XCTAssertEqual(viewModel.blocks[1].id, blockC.id)
        XCTAssertEqual(viewModel.blocks[2].id, blockA.id)
    }
    
    // MARK: - Update Content
    
    @MainActor
    func test_update_block_content_persists_changes() {
        // Given
        let viewModel = EditorViewModel()
        viewModel.addBlock(type: .text)
        let id = viewModel.blocks[0].id
        
        // When
        viewModel.updateBlockContent(id: id, text: "New Content")
        
        // Then
        guard case .text(let text) = viewModel.blocks[0].content else {
            XCTFail("Content type mismatch")
            return
        }
        XCTAssertEqual(text, "New Content")
    }
}
