/*
 This file contains unit tests for the Pure Swift Domain Entities.
 It verifies value semantics, initialization, and equality rules.
 Layer: Test (Domain)
*/

import XCTest
@testable import PromptIDE_Domain

final class DomainEntityTests: XCTestCase {
    
    // MARK: - Block Tests
    
    func test_block_initialisation_sets_properties_correctly() {
        let content = BlockContent.text("Hello World")
        let index = 0
        let id = UUID()
        
        let block = Block(id: id, content: content, orderIndex: index)
        
        XCTAssertEqual(block.id, id)
        XCTAssertEqual(block.content, content)
        XCTAssertEqual(block.orderIndex, index)
    }
    
    func test_block_equality_checks_all_fields() {
        let id = UUID()
        let block1 = Block(id: id, content: .text("A"), orderIndex: 1)
        let block2 = Block(id: id, content: .text("A"), orderIndex: 1)
        let block3 = Block(id: id, content: .text("B"), orderIndex: 1)
        
        XCTAssertEqual(block1, block2, "Blocks with identical properties should be equal")
        XCTAssertNotEqual(block1, block3, "Blocks with different content should not be equal")
    }
    
    func test_block_content_raw_value_transformation() {
        XCTAssertEqual(BlockContent.text("Test").rawValue, "Test")
        XCTAssertEqual(BlockContent.heading("Title").rawValue, "Title")
        XCTAssertEqual(BlockContent.separator.rawValue, "---")
        XCTAssertEqual(BlockContent.variableReference(name: "user").rawValue, "{{user}}")
    }
    
    // MARK: - Prompt Tests
    
    func test_prompt_aggregates_blocks_and_sorts_them() {
        let block1 = Block(content: .text("First"), orderIndex: 0)
        let block2 = Block(content: .text("Second"), orderIndex: 1)
        // Insert out of order to test sorting
        let prompt = Prompt(title: "Test", blocks: [block2, block1])
        
        XCTAssertEqual(prompt.blocks.count, 2)
        XCTAssertEqual(prompt.orderedBlocks.first?.content.rawValue, "First", "orderedBlocks should sort by index")
    }
    
    // MARK: - Policy Tests
    
    func test_policy_rules_standard_defaults() {
        let policy = PolicyRules.standard
        
        XCTAssertFalse(policy.isManaged)
        XCTAssertFalse(policy.exportBlocked)
        XCTAssertTrue(policy.forbiddenTerms.isEmpty)
    }
    
    func test_validation_finding_properties() {
        let finding = ValidationFinding(
            category: .uncertainty,
            startIndex: 0,
            endIndex: 10,
            message: "Unsure"
        )
        
        XCTAssertEqual(finding.category, .uncertainty)
    }
}
