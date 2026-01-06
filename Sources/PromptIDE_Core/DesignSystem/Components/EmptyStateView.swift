/*
 EmptyStateView: Feedback for empty lists or states.
 Layer: App (Design System)
 Pattern: Component
*/

import SwiftUI

public struct EmptyStateView: View {
    
    let icon: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    public init(
        icon: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: Layout.Spacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(Color.theme.textTertiary)
            
            Text(message)
                .font(Font.theme.body)
                .foregroundStyle(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
            
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(Font.theme.sectionHeader)
                        .padding(.horizontal, Layout.Spacing.medium)
                        .padding(.vertical, Layout.Spacing.standard)
                        .background(Color.theme.brandPrimary.opacity(0.1))
                        .clipShape(Capsule())
                }
                .padding(.top, Layout.Spacing.small)
            }
        }
        .padding(Layout.Spacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.background)
    }
}

#Preview {
    EmptyStateView(
        icon: "doc.text.magnifyingglass",
        message: "No prompts found in this project.",
        actionTitle: "Create Prompt",
        action: {}
    )
}
