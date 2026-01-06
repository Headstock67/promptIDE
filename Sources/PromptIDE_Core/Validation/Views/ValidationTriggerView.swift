/*
 ValidationTriggerView.swift
 Layer: App (Validation/Views)
 
 Toolbar button to trigger validation analysis.
*/

import SwiftUI

public struct ValidationTriggerView: View {
    
    @ObservedObject var viewModel: ValidationFindingsViewModel
    let onTrigger: () -> Void
    
    public init(viewModel: ValidationFindingsViewModel, onTrigger: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onTrigger = onTrigger
    }
    
    public var body: some View {
        Button(action: onTrigger) {
            HStack(spacing: 4) {
                if viewModel.isAnalyzing {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Image(systemName: "stethoscope") // or 'eye'
                }
                Text("Check")
            }
        }
        .disabled(viewModel.isAnalyzing)
    }
}
