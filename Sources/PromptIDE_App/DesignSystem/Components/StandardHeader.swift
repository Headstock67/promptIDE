/*
 StandardHeader: A reusable toolbar wrapper.
 Layer: App (Design System)
 Pattern: Component
*/

import SwiftUI

public struct StandardHeader<Actions: View>: View {
    
    let title: String
    let subtitle: String?
    let actions: Actions
    
    public init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder actions: () -> Actions
    ) {
        self.title = title
        self.subtitle = subtitle
        self.actions = actions()
    }
    
    // Note: In strict SwiftUI, Headers are often ToolbarItems.
    // This component might be used as a Section header or a standard View top block.
    // Given the Shell architecture, this likely renders content *inside* a standard layout.
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.small) {
            Text(title)
                .font(Font.theme.header)
                .foregroundStyle(Color.theme.textPrimary)
            
            if let subtitle {
                Text(subtitle)
                    .font(Font.theme.body)
                    .foregroundStyle(Color.theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, Layout.Spacing.medium)
        // Actions can be placed via overlay or toolbar, depending on usage.
        // For this component, we might render them trailing if needed.
    }
}

// Convenience init for no actions
public extension StandardHeader where Actions == EmptyView {
    init(title: String, subtitle: String? = nil) {
        self.init(title: title, subtitle: subtitle) {
            EmptyView()
        }
    }
}

#Preview {
    VStack {
        StandardHeader(title: "Projects", subtitle: "Manage your prompt library")
        StandardHeader(title: "Editor") {
            Button("Save") {}
        }
    }
    .padding()
}
