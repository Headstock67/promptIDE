/*
 EditorView: The composition root for the Editor feature.
 Layer: App (Editor/Views)
 Responsibilities:
 - Initializes or receives the EditorViewModel.
 - Provides the Toolbar (Add Block actions).
 - Wraps the EditorCanvas.
*/

import SwiftUI
import PromptIDE_Domain

public struct EditorView: View {
    @StateObject private var viewModel: EditorViewModel
    @StateObject private var validationViewModel = ValidationFindingsViewModel()
    @State private var isInspectorPresented: Bool = false
    
    // In strict DI, we might inject this, but for Phase 1 series,
    // we instantiate the transient VM here or pass an existing prompt.
    public init(prompt: Prompt? = nil) {
        // Load initial blocks if prompt provided
        let initialBlocks = prompt?.blocks ?? []
        _viewModel = StateObject(wrappedValue: EditorViewModel(initialBlocks: initialBlocks))
    }
    
    public var body: some View {
        EditorCanvas(
            viewModel: viewModel,
            validationViewModel: validationViewModel
        )
            .navigationTitle(Text("Editor")) // Dynamic later
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                // Validation Trigger (Leading on iPad/Mac, Trailing on iPhone, or just automatic)
                ToolbarItem(placement: .automatic) {
                    ValidationTriggerView(viewModel: validationViewModel) {
                        // Run mock scan
                        Task {
                            await validationViewModel.scan(blocks: viewModel.blocks)
                            isInspectorPresented = true
                        }
                    }
                }
                
                // Add Block Menu
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        ForEach(BlockType.allCases) { type in
                            Button {
                                viewModel.addBlock(type: type)
                            } label: {
                                Label(type.label, systemImage: type.icon)
                            }
                        }
                    } label: {
                        Label("Add Block", systemImage: "plus")
                    }
                }
            }
            .inspector(isPresented: $isInspectorPresented) {
                ValidationInspectorView(viewModel: validationViewModel)
                    .inspectorColumnWidth(min: 250, ideal: 300, max: 400)
                    .presentationDetents([.medium, .large]) // Sheet on iPhone
            }
    }
}

#Preview {
    NavigationStack {
        EditorView()
    }
}
