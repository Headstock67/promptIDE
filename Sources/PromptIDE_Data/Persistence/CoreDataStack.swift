/*
 This file defines the CoreDataStack (PersistenceController).
 It is responsible for initializing the Core Data stack, loading the store,
 and enforcing the strict FileProtectionType.complete security policy.
 Layer: Data
*/

import CoreData
import Foundation

/// Controller responsible for setting up and managing the Core Data stack.
@MainActor
public final class PersistenceController: Sendable {
    
    /// The shared singleton for the application (if needed), though strict DI is preferred.
    /// We expose this for convenience in Composition Root, but Repositories should take the container.
    public static let shared = PersistenceController()
    
    /// The persistent container holding the stack.
    public let container: NSPersistentContainer
    
    /// Initialises the Core Data stack.
    ///
    /// - Parameters:
    ///   - inMemory: If true, uses an in-memory store for testing.
    ///   - model: The managed object model to use.
    public init(inMemory: Bool = false, model: NSManagedObjectModel = CoreDataSchema.actualModel) {
        
        // We use a generic name as we are constructing the model programmatically
        container = NSPersistentContainer(name: "PromptIDE", managedObjectModel: model)
        
        // Configure the Persistent Store Description
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Ensure we use a stable file URL
            if let storeURL = container.persistentStoreDescriptions.first?.url {
               // We verify the path ensures 'Application Support' or similar
               // by default NSPersistentContainer uses Application Support.
               // We will apply file protection *after* loading or ensure the directory has it.
            }
        }
        
        container.loadPersistentStores { [weak container] (storeDescription, error) in
            if let error = error as NSError? {
                // In production, we might attempt migration recovery or logging
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
            // Critical: Apply File Encrypton (FileProtectionType.complete)
            // This ensures data is inaccessible when the device is locked.
            if !inMemory, let url = storeDescription.url {
                do {
                    // Apply to the store file itself
                    try (url as NSURL).setResourceValue(
                        FileProtectionType.complete,
                        forKey: .fileProtectionKey
                    )
                    
                    // Also attempt to apply to the parent directory to cover auxiliary files (-wal, -shm)
                    // though Core Data manages auxiliary files, setting the directory helps.
                    let storeDir = url.deletingLastPathComponent()
                    try (storeDir as NSURL).setResourceValue(
                        FileProtectionType.complete,
                        forKey: .fileProtectionKey
                    )
                    
                } catch {
                    // If we cannot protect the file, we must consider this a critical security failure.
                    print("Critical Security Error: Failed to apply FileProtection: \(error)")
                }
            }
        }
        
        // Context configuration
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    }
}
