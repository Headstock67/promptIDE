/*
 This file implements the CoreDataPromptRepository.
 It bridges the Domain Layer (Repositories) with the Data Layer (Core Data).
 It is responsible for:
 1. Translating Domain Entities <-> NSManagedObjects
 2. Managing the Core Data Context (perform, save)
 3. Invoking the CryptoService to encrypt/decrypt sensitive fields during translation
 
 Layer: Data (Repository)
*/

import Foundation
import CoreData
import PromptIDE_Domain

public final class CoreDataPromptRepository: PromptRepositoryProtocol, Sendable {
    
    private let container: NSPersistentContainer
    private let cryptoService: SecurityServiceProtocol
    
    public init(container: NSPersistentContainer, cryptoService: SecurityServiceProtocol) {
        self.container = container
        self.cryptoService = cryptoService
    }
    
    // MARK: - Projects
    
    public func fetchProjects() async throws -> [Project] {
        let request = NSFetchRequest<CDProject>(entityName: "CDProject")
        request.predicate = NSPredicate(format: "deletedAt == nil")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        return try await container.viewContext.perform {
            let results = try request.execute()
            return results.compactMap { self.mapToDomain($0) }
        }
    }
    
    public func saveProject(_ project: Project) async throws {
        let taskContext = container.newBackgroundContext()
        taskContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        
        try await taskContext.perform {
            let request = NSFetchRequest<CDProject>(entityName: "CDProject")
            request.predicate = NSPredicate(format: "id == %@", project.id as CVarArg)
            
            let result = try request.execute().first ?? CDProject(context: taskContext)
            
            result.id = project.id
            result.name = project.name
            result.summary = project.summary // Metadata, so plaintext is acceptable.
            result.createdAt = project.createdAt
            result.deletedAt = nil // Ensure it's active
            
            if taskContext.hasChanges {
                try taskContext.save()
            }
        }
    }
    
    // MARK: - Prompts
    
    public func fetchPrompt(id: UUID) async throws -> Prompt? {
        let request = NSFetchRequest<CDPrompt>(entityName: "CDPrompt")
        request.predicate = NSPredicate(format: "id == %@ AND deletedAt == nil", id as CVarArg)
        
        return try await container.viewContext.perform {
            guard let result = try request.execute().first else { return nil }
            return try self.mapToDomain(result)
        }
    }
    
    public func savePrompt(_ prompt: Prompt) async throws {
        let taskContext = container.newBackgroundContext()
        taskContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        
        try await taskContext.perform {
            let request = NSFetchRequest<CDPrompt>(entityName: "CDPrompt")
            request.predicate = NSPredicate(format: "id == %@", prompt.id as CVarArg)
            
            let cdPrompt = try request.execute().first ?? CDPrompt(context: taskContext)
            
            // Update Prompt Fields
            cdPrompt.id = prompt.id
            cdPrompt.title = prompt.title
            cdPrompt.createdAt = prompt.createdAt
            cdPrompt.updatedAt = prompt.updatedAt
            cdPrompt.deletedAt = nil
            
            // Handle Blocks
            // Strategy: Since this is a full save, we reconcile the blocks.
            // 1. Fetch existing blocks
            let existingBlocks = cdPrompt.blocks as? Set<CDBlock> ?? []
            
            // 2. Update or Create blocks from Domain
            for block in prompt.blocks {
                let cdBlock = existingBlocks.first { $0.id == block.id } ?? CDBlock(context: taskContext)
                cdBlock.id = block.id
                cdBlock.orderIndex = Int64(block.orderIndex)
                cdBlock.typeRaw = self.blockTypeString(block.content)
                cdBlock.prompt = cdPrompt
                cdBlock.deletedAt = nil
                
                // Encryption Step!
                let rawContent = block.content.rawValue
                cdBlock.encryptedContent = try self.cryptoService.encrypt(plaintext: rawContent)
            }
            
            // 3. Delete blocks not in the domain model (orphans)
            // Implementation detail: If a block was removed from the prompt struct, it should be deleted.
            let incomingIDs = Set(prompt.blocks.map { $0.id })
            for existing in existingBlocks {
                if let id = existing.id, !incomingIDs.contains(id) {
                    taskContext.delete(existing)
                }
            }
            
            if taskContext.hasChanges {
                try taskContext.save()
            }
        }
    }
    
    public func deletePrompt(id: UUID) async throws {
        let taskContext = container.newBackgroundContext()
        try await taskContext.perform {
            let request = NSFetchRequest<CDPrompt>(entityName: "CDPrompt")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            if let result = try request.execute().first {
                result.deletedAt = Date() // Soft delete
                // Do we cascade soft delete to blocks? Explicitly yes.
                if let blocks = result.blocks {
                   blocks.forEach { $0.deletedAt = Date() }
                }
                
                try taskContext.save()
            }
        }
    }
    
    // MARK: - Mappers (Private)
    
    private func mapToDomain(_ cdProject: CDProject) -> Project? {
        guard let id = cdProject.id,
              let name = cdProject.name,
              let createdAt = cdProject.createdAt else { return nil }
        
        return Project(
            id: id,
            name: name,
            summary: cdProject.summary ?? "",
            createdAt: createdAt
        )
    }
    
    private func mapToDomain(_ cdPrompt: CDPrompt) throws -> Prompt? {
        guard let id = cdPrompt.id,
              let title = cdPrompt.title,
              let createdAt = cdPrompt.createdAt,
              let updatedAt = cdPrompt.updatedAt,
              let _ = cdPrompt.managedObjectContext else { return nil }
        
        // Map Blocks
        // Warning: Accessing cdPrompt.blocks directly might fault.
        // We do this inside the perform block passed from fetch, so context is valid.
        
        var domainBlocks: [Block] = []
        if let cdBlocks = cdPrompt.blocks {
            for cdBlock in cdBlocks {
                // Skip soft deleted blocks
                if cdBlock.deletedAt != nil { continue }
                
                if let block = try mapToDomain(cdBlock) {
                    domainBlocks.append(block)
                }
            }
        }
        
        return Prompt(
            id: id,
            title: title,
            blocks: domainBlocks,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    private func mapToDomain(_ cdBlock: CDBlock) throws -> Block? {
        guard let id = cdBlock.id,
              let typeRaw = cdBlock.typeRaw,
              let encryptedData = cdBlock.encryptedContent else { return nil }
        
        // Decryption Step!
        let plaintext = try cryptoService.decrypt(ciphertext: encryptedData)
        
        // Correction for Variable reconstruction
        // If type is variable, plaintext "should" be "{{name}}".
        let finalContent: BlockContent
        if typeRaw == "variable" {
            let name = plaintext.replacingOccurrences(of: "{{", with: "").replacingOccurrences(of: "}}", with: "")
            finalContent = .variableReference(name: name)
        } else if typeRaw == "separator" {
            finalContent = .separator
        } else if typeRaw == "heading" {
            finalContent = .heading(plaintext)
        } else {
            finalContent = .text(plaintext)
        }
        
        return Block(
            id: id,
            content: finalContent,
            orderIndex: Int(cdBlock.orderIndex)
        )
    }
    
    private func blockTypeString(_ content: BlockContent) -> String {
        switch content {
        case .text: return "text"
        case .heading: return "heading"
        case .separator: return "separator"
        case .variableReference: return "variable"
        }
    }
}
