/*
 BlockContainer: A wrapper for all editor blocks.
 Layer: App (Editor/Components)
 Responsibilities:
 - Provides consistent layout (padding, alignment).
 - Handles visual selection state (border/background).
 - Renders drag handle for reordering (only when active).
*/

import SwiftUI
import PromptIDE_Domain

public struct BlockContainer<Content: View>: View {
    
    let blockID: UUID
    let isFocused: Bool
    let isHighlighted: Bool
    let content: Content
    
    // In future: passing drag gesture hooks
    
    public init(
        blockID: UUID,
        isFocused: Bool,
        isHighlighted: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.blockID = blockID
        self.isFocused = isFocused
        self.isHighlighted = isHighlighted
        self.content = content()
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: Layout.Spacing.small) {
            
            // Leading Gutter (Drag Handle)
            ZStack {
                if isFocused {
                    Image(systemName: "line.3.horizontal") // "Grabber" icon
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.theme.textTertiary)
                        .padding(.top, 4) // Visually align with text cap height
                        .transition(.opacity.animation(.easeInOut(duration: 0.2)))
                }
            }
            .frame(width: 24, alignment: .center)
            
            // Content Area
            content
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Trailing Gutter (Optional Actions, hidden for now)
        }
        .padding(.vertical, Layout.Spacing.small)
        .padding(.horizontal, Layout.Spacing.small)
        .background(
            RoundedRectangle(cornerRadius: Layout.Radius.standard)
                .fill(isFocused ? Color.theme.surfaceSecondary : Color.clear)
        )
        // Selection Border (Subtle)
        .overlay(
            RoundedRectangle(cornerRadius: Layout.Radius.standard)
                .stroke(Color.theme.brandPrimary.opacity(isFocused ? 0.3 : 0), lineWidth: 1)
        )
        // Animation for focus change
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .animation(.easeInOut(duration: 0.2), value: isHighlighted)
    }
}
