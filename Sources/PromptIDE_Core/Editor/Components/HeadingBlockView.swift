/*
 HeadingBlockView: A bold heading input block.
 Layer: App (Editor/Components)
*/

import SwiftUI

public struct HeadingBlockView: View {
    
    @Binding var text: String
    var isFocused: FocusState<EditorFocusState?>.Binding
    let blockID: UUID
    
    public init(text: Binding<String>, isFocused: FocusState<EditorFocusState?>.Binding, blockID: UUID) {
        self._text = text
        self.isFocused = isFocused
        self.blockID = blockID
    }
    
    public var body: some View {
        TextField("Heading", text: $text)
            .font(Font.theme.sectionHeader)
            .foregroundStyle(Color.theme.textPrimary)
            .focused(isFocused, equals: .block(blockID))
    }
}
