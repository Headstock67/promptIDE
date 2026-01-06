/*
 AppRoot: The top-level view that switches between shells based on device/size class.
 Layer: App (Navigation)
 Pattern: Root
*/

import SwiftUI

public struct AppRoot: View {
    
    @EnvironmentObject var navManager: NavigationManager
    // We observe size class to determine layout on iPad/iPhone
    @Environment(\.horizontalSizeClass) var sizeClass
    
    public init() {}
    
    public var body: some View {
        #if os(macOS)
        AppSidebarShell()
        #else
        // iOS: Switch based on Horizontal Size Class
        if sizeClass == .compact {
            AppTabShell()
        } else {
            AppSidebarShell()
        }
        #endif
    }
}

#Preview {
    AppRoot()
        .environmentObject(NavigationManager())
}
