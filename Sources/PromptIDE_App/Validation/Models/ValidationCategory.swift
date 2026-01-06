/*
 ValidationCategory.swift
 Layer: App (Validation/Models)
 
 Defines the categories of validation findings for grouping in the UI.
 Presentation only.
*/

import SwiftUI

public enum ValidationCategory: String, CaseIterable, Identifiable, Sendable {
    case uncertainty
    case absoluteClaims
    case formatting
    case policy
    
    public var id: String { rawValue }
    
    /// Human-readable section header.
    public var title: String {
        switch self {
        case .uncertainty: return "Uncertainty"
        case .absoluteClaims: return "Absolute Claims"
        case .formatting: return "Formatting"
        case .policy: return "Policy Restricted"
        }
    }
    
    /// Category icon.
    public var icon: String {
        switch self {
        case .uncertainty: return "questionmark.circle"
        case .absoluteClaims: return "exclamationmark.triangle"
        case .formatting: return "textformat"
        case .policy: return "shield.fill"
        }
    }
    
    /// Category theme color.
    public var color: Color {
        switch self {
        case .uncertainty: return .orange
        case .absoluteClaims: return .yellow
        case .formatting: return .blue
        case .policy: return .red // Only allowed red
        }
    }
}
