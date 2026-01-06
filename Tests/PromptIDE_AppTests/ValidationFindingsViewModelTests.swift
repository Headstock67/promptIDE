/*
 ValidationFindingsViewModelTests.swift
 Tests for the presentation-only validation behaviour.
*/

import XCTest
@testable import PromptIDE_App
import PromptIDE_Domain

final class ValidationFindingsViewModelTests: XCTestCase {
    
    // MARK: - Scan Logic (Simulated)
    
    @MainActor
    func test_scan_produces_mock_findings_for_trigger_words() async {
        // Given
        let viewModel = ValidationFindingsViewModel()
        let blocks: [Block] = [
            Block(id: UUID(), content: .text("This text contains always which is absolute"), orderIndex: 0),
            Block(id: UUID(), content: .text("Safe text"), orderIndex: 1)
        ]
        
        // When
        await viewModel.scan(blocks: blocks)
        
        // Then
        XCTAssertFalse(viewModel.findings.isEmpty)
        XCTAssertTrue(viewModel.findings.contains { $0.category == .absoluteClaims })
    }
    
    @MainActor
    func test_scan_produces_mock_findings_for_long_text() async {
        // Given
        let longText = String(repeating: "word ", count: 25) // > 100 chars
        let viewModel = ValidationFindingsViewModel()
        let blocks: [Block] = [
            Block(id: UUID(), content: .text(longText), orderIndex: 0)
        ]
        
        // When
        await viewModel.scan(blocks: blocks)
        
        // Then
        XCTAssertTrue(viewModel.findings.contains { $0.category == .uncertainty })
    }
    
    // MARK: - Dismissal Logic
    
    @MainActor
    func test_dismiss_removes_finding() async {
        // Given
        let viewModel = ValidationFindingsViewModel()
        let blockID = UUID()
        let finding = ValidationFindingViewModel(
            category: .uncertainty,
            title: "Test",
            message: "Test",
            blockID: blockID,
            snippet: "Test"
        )
        viewModel.findings = [finding]
        
        // When
        viewModel.dismiss(id: finding.id)
        
        // Then
        XCTAssertTrue(viewModel.findings.isEmpty)
    }
    
    // MARK: - Highlight Logic
    
    @MainActor
    func test_selection_sets_active_highlight() {
        // Given
        let viewModel = ValidationFindingsViewModel()
        let blockID = UUID()
        let finding = ValidationFindingViewModel(
            category: .uncertainty,
            title: "Test",
            message: "Test",
            blockID: blockID,
            snippet: "Test"
        )
        
        // When
        viewModel.selectFinding(finding)
        
        // Then
        XCTAssertEqual(viewModel.activeHighlightBlockID, blockID)
    }
    
    @MainActor
    func test_clear_highlight_removes_active_state() {
        // Given
        let viewModel = ValidationFindingsViewModel()
        viewModel.activeHighlightBlockID = UUID()
        
        // When
        viewModel.clearHighlight()
        
        // Then
        XCTAssertNil(viewModel.activeHighlightBlockID)
    }
}
