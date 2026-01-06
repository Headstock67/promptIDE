/*
 FindingCardView.swift
 Layer: App (Validation/Components)
 
 Displays a single validation finding summary.
*/

import SwiftUI

public struct FindingCardView: View {
    
    let finding: ValidationFindingViewModel
    let onDismiss: () -> Void
    
    public init(finding: ValidationFindingViewModel, onDismiss: @escaping () -> Void) {
        self.finding = finding
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: Layout.Spacing.standard) {
            // Icon
            Image(systemName: finding.category.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(finding.category.color)
                .frame(width: 24, height: 24)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(finding.title)
                    .font(Font.theme.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.theme.textPrimary)
                
                Text(finding.message)
                    .font(Font.theme.caption)
                    .foregroundStyle(Color.theme.textSecondary)
                    .lineLimit(3)
                
                // Snippet (Optional context)
                Text("\"\(finding.snippet)\"")
                    .font(Font.theme.code) // Use code font for distinction
                    .font(.caption2)
                    .foregroundStyle(Color.theme.textTertiary)
                    .padding(.top, 4)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Layout.Spacing.standard)
        .background(Color.theme.surfaceSecondary)
        .cornerRadius(Layout.Radius.card)
        // Swipe to dismiss
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDismiss) {
                Label("Ignore", systemImage: "eye.slash")
            }
        }
    }
}
