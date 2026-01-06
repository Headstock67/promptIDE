/*
 TextBlockView: A robust, multi-line text editor block.
 Layer: App (Editor/Components)
*/

import SwiftUI

public struct TextBlockView: View {
    
    // Binding to the raw string content
    @Binding var text: String
    
    // Focus binding passed from parent
    var isFocused: FocusState<EditorFocusState?>.Binding
    // The specific identity of this block for focus matching
    let blockID: UUID
    
    public init(text: Binding<String>, isFocused: FocusState<EditorFocusState?>.Binding, blockID: UUID) {
        self._text = text
        self.isFocused = isFocused
        self.blockID = blockID
    }
    
    public var body: some View {
        // ZStack hack to handle "auto-growing" TextEditor cleanly if needed,
        // but TextField(axis: .vertical) is standard in newer SwiftUI.
        // Let's use TextField with axis: .vertical for "Calm" auto-expansion.
        
        TextField("Type something...", text: $text, axis: .vertical)
            .font(Font.theme.body) // Dynamic Type
            .lineSpacing(4)
            .foregroundStyle(Color.theme.textPrimary)
            .focused(isFocused, equals: .block(blockID))
            // Submit Label? Return key to split block?
            // ViewModel will handle return key interception if we need it (using .onSubmit or introspect).
            // For now, standard behavior.
    }
}
