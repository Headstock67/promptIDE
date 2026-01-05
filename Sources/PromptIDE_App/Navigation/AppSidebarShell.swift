/*
 AppSidebarShell: The main navigation structure for iPad and macOS.
 Layer: App (Navigation)
 Pattern: Shell
*/

import SwiftUI

public struct AppSidebarShell: View {
    
    @EnvironmentObject var navManager: NavigationManager
    
    public init() {}
    
    public var body: some View {
        NavigationSplitView {
            // Sidebar
            List(selection: $navManager.selectedProjectID) {
                NavigationLink(value: UUID()) {
                    Label("Example Project", systemImage: "folder")
                }
                // Later: ForEach(projects)
            }
            .navigationTitle("Library")
            #if os(macOS)
            .navigationSplitViewColumnWidth(min: 200, ideal: 250)
            #endif
            
            // Toolbar for sidebar actions
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {}) {
                        Label("New Project", systemImage: "plus")
                    }
                }
            }
            
        } detail: {
            // Detail Area
            if let selectedProject = navManager.selectedProjectID {
                VStack {
                    StandardHeader(title: "Project Detail", subtitle: selectedProject.uuidString)
                    EmptyStateView(
                        icon: "doc.text",
                        message: "Select a prompt to edit",
                        actionTitle: "New Prompt",
                        action: {}
                    )
                }
                .padding()
            } else {
                EmptyStateView(
                    icon: "sidebar.left",
                    message: "Select a project from the sidebar"
                )
            }
        }
        // Inspector for validation/metadata (iPad/Mac pattern)
        .inspector(isPresented: $navManager.isInspectorPresented) {
            VStack {
                StandardHeader(title: "Inspector")
                Text("Validation & Info")
                    .foregroundStyle(Color.theme.textSecondary)
                Spacer()
            }
            .padding()
            #if os(macOS)
            .inspectorColumnWidth(min: 200, ideal: 250)
            #endif
        }
    }
}

#Preview {
    AppSidebarShell()
        .environmentObject(NavigationManager())
}
