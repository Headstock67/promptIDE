/*
 ValidationInspectorView.swift
 Layer: App (Validation/Views)
 
 The side panel / sheet displaying validation results.
 Grouped by category.
*/

import SwiftUI

public struct ValidationInspectorView: View {
    
    @ObservedObject var viewModel: ValidationFindingsViewModel
    
    public init(viewModel: ValidationFindingsViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Validation Findings")
                    .font(Font.theme.header)
                    .foregroundStyle(Color.theme.textPrimary)
                Spacer()
                if viewModel.isAnalyzing {
                    ProgressView()
                        .controlSize(.small)
                }
            }
            .padding()
            .background(Color.theme.surfaceSecondary)
            
            if viewModel.findings.isEmpty && !viewModel.isAnalyzing {
                // Empty State
                VStack(spacing: Layout.Spacing.medium) {
                    Spacer()
                    Image(systemName: "checkmark.shield")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.green.opacity(0.8))
                    Text("No obvious risks detected.")
                        .font(Font.theme.body)
                        .fontWeight(.medium)
                    Text("Remember to verify claims manually.")
                        .font(Font.theme.caption)
                        .foregroundStyle(Color.theme.textSecondary)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .padding()
            } else {
                // Findings List
                List {
                    // Group findings by category
                    ForEach(ValidationCategory.allCases) { category in
                        let categoryFindings = viewModel.findings.filter { $0.category == category }
                        if !categoryFindings.isEmpty {
                            Section(header: Text(category.title)) {
                                ForEach(categoryFindings) { finding in
                                    FindingCardView(finding: finding) {
                                        withAnimation {
                                            viewModel.dismiss(id: finding.id)
                                        }
                                    }
                                    .onTapGesture {
                                        viewModel.selectFinding(finding)
                                    }
                                    .listRowInsets(EdgeInsets()) // Edge-to-edge
                                    .listRowBackground(Color.clear)
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .background(Color.theme.background)
    }
}
