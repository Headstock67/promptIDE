/*
 AppTabShell: The main navigation structure for iPhone.
 Layer: App (Navigation)
 Pattern: Shell
*/

import SwiftUI

public struct AppTabShell: View {
    
    @EnvironmentObject var navManager: NavigationManager
    // We will inject AppContainer via EnvironmentObject in the future, or passed down.
    // For now, shells focus on layout.
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $navManager.activeTab) {
            
            // Tab 1: Projects
            NavigationStack {
                // Placeholder for Project List
                VStack(spacing: Layout.Spacing.large) {
                    StandardHeader(title: "Projects", subtitle: "Your local prompts")
                    
                    EmptyStateView(
                        icon: "folder",
                        message: "No projects yet.",
                        actionTitle: "Create Project",
                        action: { /* No-Op */ }
                    )
                }
                .padding()
            }
            .tabItem {
                Label("Projects", systemImage: AppTab.projects.icon)
            }
            .tag(AppTab.projects)
            
            // Tab 2: Create (Modal Trigger)
            Text("Create Sheet Trigger")
                .tabItem {
                    Label("Create", systemImage: AppTab.create.icon)
                }
                .tag(AppTab.create)
            
            // Tab 3: Settings
            NavigationStack {
                VStack {
                    StandardHeader(title: "Settings")
                    Spacer()
                }
                .padding()
            }
            .tabItem {
                Label("Settings", systemImage: AppTab.settings.icon)
            }
            .tag(AppTab.settings)
        }
    }
}

#Preview {
    AppTabShell()
        .environmentObject(NavigationManager())
}
