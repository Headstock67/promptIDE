/*
 ContextCapsule: A pill-shaped indicator for context variables or metadata.
 Layer: App (Design System)
 Pattern: Component
*/

import SwiftUI

public struct ContextCapsule: View {
    
    let text: String
    let icon: String?
    let color: Color
    
    public init(text: String, icon: String? = nil, color: Color = Color.theme.brandPrimary) {
        self.text = text
        self.icon = icon
        self.color = color
    }
    
    public var body: some View {
        HStack(spacing: Layout.Spacing.small) {
            if let icon {
                Image(systemName: icon)
            }
            Text(text)
        }
        .font(Font.theme.caption)
        .padding(.horizontal, Layout.Spacing.standard)
        .padding(.vertical, Layout.Spacing.small)
        .background(color.opacity(0.1))
        .foregroundStyle(color)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(color.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    ContextCapsule(text: "Draft", icon: "pencil")
}
