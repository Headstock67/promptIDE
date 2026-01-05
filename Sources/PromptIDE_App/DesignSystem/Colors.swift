/*
 Semantic Color Tokens (Cross-Platform).
 Layer: App (Design System)
*/

import SwiftUI

#if os(macOS)
import AppKit
typealias PlatformColor = NSColor
#else
import UIKit
typealias PlatformColor = UIColor
#endif

public extension Color {
    /// The centralized theme accessor.
    static let theme = ThemeColors()
}

public struct ThemeColors: Sendable {
    
    // MARK: - Surfaces
    
    /// The primary background.
    /// iOS: systemBackground
    /// macOS: windowBackgroundColor
    public var background: Color {
        #if os(macOS)
        return Color(nsColor: .windowBackgroundColor)
        #else
        return Color(uiColor: .systemBackground)
        #endif
    }
    
    /// Secondary background for sidebars/lists.
    public var surfaceSecondary: Color {
        #if os(macOS)
        return Color(nsColor: .controlBackgroundColor) // or underPageBackgroundColor
        #else
        return Color(uiColor: .secondarySystemBackground)
        #endif
    }
    
    /// Tertiary background for inputs/cards.
    public var surfaceTertiary: Color {
        #if os(macOS)
        return Color(nsColor: .controlBackgroundColor.withAlphaComponent(0.5)) // Approximate
        #else
        return Color(uiColor: .tertiarySystemBackground)
        #endif
    }
    
    // MARK: - Content
    
    /// High emphasis text.
    public let textPrimary = Color.primary
    
    /// Medium emphasis text (metadata).
    public let textSecondary = Color.secondary
    
    /// Low emphasis text (placeholders).
    public var textTertiary: Color {
        #if os(macOS)
        return Color(nsColor: .tertiaryLabelColor)
        #else
        return Color(uiColor: .tertiaryLabel)
        #endif
    }
    
    // MARK: - Accents
    
    /// The primary brand tint color.
    public let brandPrimary = Color.blue
    
    /// A subtle version of the brand color.
    public let brandSubtle = Color.blue.opacity(0.1)
    
    // MARK: - Status
    
    public let destructive = Color.red
    public let warning = Color.orange
    public let success = Color.green
    public let info = Color.gray
}
