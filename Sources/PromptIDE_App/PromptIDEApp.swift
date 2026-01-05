/*
 The Composition Root of the Prompt IDE Application.
 Layer: App
*/

import SwiftUI
import PromptIDE_Domain
import PromptIDE_Data

@main
struct PromptIDEApp: App {
    // The single source of truth for dependencies.
    @StateObject private var container: AppContainer
    // The single source of truth for navigation.
    @StateObject private var navManager: NavigationManager
    
    init() {
        // Initialize the composition root
        // In the future, we might decide 'inMemory' based on launch arguments for UI Tests
        let container = AppContainer()
        _container = StateObject(wrappedValue: container)
        
        let navManager = NavigationManager()
        _navManager = StateObject(wrappedValue: navManager)
    }
    
    var body: some Scene {
        WindowGroup {
            AppRoot()
                .environmentObject(navManager)
        }
    }
}
