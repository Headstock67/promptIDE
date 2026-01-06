/*
 SeparatorBlockView: A visual divider.
 Layer: App (Editor/Components)
*/

import SwiftUI

public struct SeparatorBlockView: View {
    
    public init() {}
    
    public var body: some View {
        Divider()
            .background(Color.theme.textTertiary)
            .frame(height: 1)
            .padding(.vertical, Layout.Spacing.standard)
    }
}
