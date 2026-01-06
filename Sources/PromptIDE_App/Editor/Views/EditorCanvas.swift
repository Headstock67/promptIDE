/*
 EditorCanvas: The scrollable area rendering the list of blocks.
 Layer: App (Editor/Views)
 Responsibilities:
 - Renders the list of blocks using LazyVStack (or VStack) inside a ScrollView.
 - Handles Drag and Drop reordering logic.
 - Manages scrolling to bottom or specific blocks.
 - Displays Empty State.
*/

import SwiftUI
import PromptIDE_Domain

public struct EditorCanvas: View {
    
    @ObservedObject var viewModel: EditorViewModel
    @ObservedObject var validationViewModel: ValidationFindingsViewModel
    @FocusState var focusedField: EditorFocusState?
    
    public init(viewModel: EditorViewModel, validationViewModel: ValidationFindingsViewModel) {
        self.viewModel = viewModel
        self.validationViewModel = validationViewModel
    }
    
    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: Layout.Spacing.standard) {
                    
                    if viewModel.blocks.isEmpty {
                        EmptyStateView(
                            icon: "doc.text",
                            message: "Start typing to begin...",
                            actionTitle: "Add Text Block",
                            action: {
                                viewModel.addBlock(type: .text)
                            }
                        )
                        .frame(minHeight: 400) // Ensure centered appearance
                    } else {
                        ForEach(viewModel.blocks) { block in
                            BlockContainer(
                                blockID: block.id,
                                isFocused: focusedField == .block(block.id),
                                isHighlighted: validationViewModel.activeHighlightBlockID == block.id
                            ) {
                                renderBlockContent(for: block)
                            }
                            // Drag and Drop (iOS 16+ / macOS 13+ simplified pattern possible,
                            // or standard .onDrag/.onDrop).
                            // For simplicity and "Calm" feel, we rely on List's native reorder if using List,
                            // but user spec asked for ScrollView + VStack.
                            // We will implement manual drag handle logic if requested, or wrap in efficient List later.
                            // For Phase 1.2b, we'll assume basic rendering first.
                            .id(block.id)
                            .onTapGesture {
                                focusedField = .block(block.id)
                                viewModel.selectedBlockID = block.id
                            }
                        }
                    }
                }
                .padding()
                // Overscroll for keyboard
                .padding(.bottom, 100)
            }
            .background(Color.theme.background)
            .onChange(of: viewModel.blocks.count) {
                // Scroll to bottom on add
                if let last = viewModel.blocks.last {
                    withAnimation {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: validationViewModel.activeHighlightBlockID) {
                if let blockID = validationViewModel.activeHighlightBlockID {
                    withAnimation {
                        proxy.scrollTo(blockID, anchor: .center)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func renderBlockContent(for block: Block) -> some View {
        switch block.content {
        case .text(let text):
            TextBlockView(
                text: Binding(
                    get: { text },
                    set: { viewModel.updateBlockContent(id: block.id, text: $0) }
                ),
                isFocused: $focusedField,
                blockID: block.id
            )
        case .heading(let text):
            HeadingBlockView(
                text: Binding(
                    get: { text },
                    set: { viewModel.updateBlockContent(id: block.id, text: $0) }
                ),
                isFocused: $focusedField,
                blockID: block.id
            )
        case .separator:
            SeparatorBlockView()
        case .variableReference(let name):
             Text("{{ \(name) }}") // Placeholder
                 .font(Font.theme.code)
                 .foregroundStyle(Color.theme.brandPrimary)
        }
    }
}
