/*
 AppCard: A standard container for list items.
 Layer: App (Design System)
 Pattern: Component
*/

import SwiftUI

public struct AppCard<Content: View>: View {
    
    let content: Content
    let onTap: (() -> Void)?
    
    public init(
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.onTap = onTap
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(Layout.Spacing.medium)
            .background(Color.theme.surfaceTertiary)
            .cornerRadius(Layout.Radius.card)
            .onTapGesture {
                onTap?()
            }
    }
}

#Preview {
    ZStack {
        Color.theme.surfaceSecondary.ignoresSafeArea()
        
        AppCard {
            Text("This is a card")
                .foregroundStyle(Color.theme.textPrimary)
        }
        .padding()
    }
}
