/*
 ValidationFindingsViewModel.swift
 Layer: App (Validation/ViewModels)
 
 Manages the state of the Validation Findings Pane.
 Simulates analysis for Phase 1.2c (Presentation Only).
 
 Responsibilities:
 - Holds [ValidationFindingViewModel] list.
 - Simulates async scanning.
 - Manages active highlight state.
 - Handles finding dismissal.
 
 Logic Constraints:
 - Mock data only.
 - No real analysis/heuristics.
*/

import Foundation
import PromptIDE_Domain

@MainActor
public class ValidationFindingsViewModel: ObservableObject {
    
    // MARK: - State
    
    @Published public var findings: [ValidationFindingViewModel] = []
    @Published public var isAnalyzing: Bool = false
    @Published public var activeHighlightBlockID: UUID?
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - Intents
    
    /// Simulates a validation scan on the current blocks.
    public func scan(blocks: [Block]) async {
        isAnalyzing = true
        activeHighlightBlockID = nil
        
        // Simulate network/processing delay (Calm UX)
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5s
        
        // Generate mock findings based on block content (Presentation Only)
        var newFindings: [ValidationFindingViewModel] = []
        
        for block in blocks {
            if case .text(let text) = block.content {
                if text.localizedCaseInsensitiveContains("always") {
                    newFindings.append(ValidationFindingViewModel(
                        category: .absoluteClaims,
                        title: "Absolute Claim",
                        message: "Usage of 'always' implies a guarantee that may not hold.",
                        blockID: block.id,
                        snippet: text
                    ))
                }
                
                if text.count > 100 { // Arbitrary length for valid-looking mock
                    newFindings.append(ValidationFindingViewModel(
                        category: .uncertainty,
                        title: "Complex sentence",
                        message: "Consider breaking this down for clarity.",
                        blockID: block.id,
                        snippet: String(text.prefix(50)) + "..."
                    ))
                }
            }
        }
        
        // Animation handled by View
        self.findings = newFindings
        self.isAnalyzing = false
    }
    
    /// User dismisses a specific finding.
    public func dismiss(id: UUID) {
        findings.removeAll { $0.id == id }
        
        // If the dismissed finding was the reason for the highlight, clear it?
        // Logic: activeHighlight is block-based. If no other findings for this block, clear.
        // For simplicity 1.2c: Just clear highlight if it matches
        // (Improving this would require linkage tracking, unnecessary for Mock).
        if activeHighlightBlockID != nil {
             // In a real implementation we'd check if other findings point to this block.
        }
    }
    
    /// User selects a finding to focus on.
    public func selectFinding(_ finding: ValidationFindingViewModel) {
        // Set block highlight
        activeHighlightBlockID = finding.blockID
    }
    
    /// Cleaning up highlight when user interacts elsewhere.
    public func clearHighlight() {
        activeHighlightBlockID = nil
    }
}
