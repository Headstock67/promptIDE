/*
 Dependency Injection Container for Prompt IDE.
 Only the Composition Root (PromptIDEApp) should hold a reference to this.
 Layer: App (Composition Root)
*/

import Foundation
import SwiftUICore // For Environment injection availability if needed
import PromptIDE_Domain
import PromptIDE_Data

@MainActor
public final class AppContainer: ObservableObject {
    
    // Core Infrastructure
    public let persistenceController: PersistenceController
    public let appLockService: AppLockService
    public let cryptoService: SecurityServiceProtocol
    
    // Repositories
    public let promptRepository: PromptRepositoryProtocol
    
    // Features / ViewModels Dependencies
    // (Future: ValidationService, etc.)
    
    public init(inMemory: Bool = false) {
        // 1. Infrastructure
        self.persistenceController = PersistenceController(inMemory: inMemory)
        
        // 2. Security
        // In real app, we use real Crypto. In tests/previews, maybe mock.
        // For now, we always use real CryptoService which depends on KeychainHelper.
        let keychain = KeychainHelper()
        self.cryptoService = CryptoService(keychain: keychain)
        
        self.appLockService = AppLockService()
        
        // 3. Repositories
        self.promptRepository = CoreDataPromptRepository(
            container: persistenceController.container,
            cryptoService: cryptoService
        )
        
        // Log initialization
        print("🟢 AppContainer Initialized (InMemory: \(inMemory))")
    }
}
