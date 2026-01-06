/*
 NavigationManager: Handles global navigation state.
 Layer: App (Navigation)
 Pattern: State Object
*/

import SwiftUI
import Combine

public enum AppTab: Int, CaseIterable, Identifiable {
    case projects
    case create
    case settings
    
    public var id: Int { rawValue }
    
    public var title: String {
        switch self {
        case .projects: return "Projects"
        case .create: return "Create"
        case .settings: return "Settings"
        }
    }
    
    public var icon: String {
        switch self {
        case .projects: return "folder.fill"
        case .create: return "plus.circle.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

@MainActor
public class NavigationManager: ObservableObject {
    
    // MARK: - Tab State (iPhone)
    @Published public var activeTab: AppTab = .projects
    
    // MARK: - Selection State (iPad/Mac)
    @Published public var selectedProjectID: UUID?
    @Published public var selectedPromptID: UUID?
    
    // MARK: - Inspector State
    @Published public var isInspectorPresented: Bool = true
    
    public init() {}
    
    /// Navigate to a specific project (e.g., after creation).
    public func navigate(toProject id: UUID) {
        self.activeTab = .projects
        self.selectedProjectID = id
    }
}
