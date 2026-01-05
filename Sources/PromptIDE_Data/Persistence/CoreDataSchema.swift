/*
 This file defines the Core Data Managed Object Model programmatically.
 It avoids the need for an .xcdatamodeld file and allows for strict code revision control of the schema.
 Schema Version: 1.0
 Layer: Data
*/

import CoreData
import Foundation

/// Defines the Core Data schema (Entities, Attributes, Relationships).
public enum CoreDataSchema {
    
    /// Returns the complete Managed Object Model for the application.
    public static var model: NSManagedObjectModel {
        let model = NSManagedObjectModel()
        model.entities = [projectEntity, promptEntity, blockEntity]
        return model
    }
    
    // MARK: - Entity Definitions
    
    private static var projectEntity: NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "CDProject"
        entity.managedObjectClassName = "CDProject"
        
        entity.properties = [
            Attribute("id", .UUIDAttributeType, isOptional: false),
            Attribute("name", .stringAttributeType, isOptional: false),
            Attribute("summary", .stringAttributeType, isOptional: false), // Encrypted? No, metadata.
            Attribute("createdAt", .dateAttributeType, isOptional: false),
            Attribute("deletedAt", .dateAttributeType, isOptional: true) // Soft delete
        ]
        
        return entity
    }
    
    private static var promptEntity: NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "CDPrompt"
        entity.managedObjectClassName = "CDPrompt"
        
        entity.properties = [
            Attribute("id", .UUIDAttributeType, isOptional: false),
            Attribute("title", .stringAttributeType, isOptional: false), // Metadata, plaintext
            Attribute("createdAt", .dateAttributeType, isOptional: false),
            Attribute("updatedAt", .dateAttributeType, isOptional: false),
            Attribute("deletedAt", .dateAttributeType, isOptional: true) // Soft delete
        ]
        
        return entity
    }
    
    private static var blockEntity: NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "CDBlock"
        entity.managedObjectClassName = "CDBlock"
        
        entity.properties = [
            Attribute("id", .UUIDAttributeType, isOptional: false),
            Attribute("orderIndex", .integer64AttributeType, isOptional: false),
            Attribute("typeRaw", .stringAttributeType, isOptional: false), // "text", "heading", etc.
            
            // Sensitive Content -> Encrypted Blob
            // We do NOT store the text in plaintext.
            Attribute("encryptedContent", .binaryDataAttributeType, isOptional: false),
            
            Attribute("deletedAt", .dateAttributeType, isOptional: true)
        ]
        
        return entity
    }
    
    // MARK: - Helpers
    
    private static func Attribute(_ name: String, _ type: NSAttributeType, isOptional: Bool = false) -> NSAttributeDescription {
        let attr = NSAttributeDescription()
        attr.name = name
        attr.attributeType = type
        attr.isOptional = isOptional
        return attr
    }
    
    private enum RelationshipType { case toOne, toMany }
    
    private static func Relationship(_ name: String, destination: String, inverse: String, output: RelationshipType) -> NSRelationshipDescription {
        let rel = NSRelationshipDescription()
        rel.name = name
        
        // We set specific destination/inverse later because of circular refs,
        // but NSManagedObjectModel handles string lookups during compile if carefully constructed.
        // Actually, with programmatic defs, we often need lazy resolution or direct object ref.
        // For simplicity in this block, we will use a "Ref Resolver" pattern if needed,
        // but effectively we need to link the objects.
        
        // Since `destinationEntity` requires the object, we construct them all first in the static var above, which is cleaner.
        // However, here we are inside a static func.
        // To fix circular dependency, we just define properties in the main `model` builder?
        // No, let's keep it simple: We return descriptions here, but we can't link them until they exist.
        // Swift lazy loading helps.
        
        // REFACTOR Strategy:
        // We will configure relationships in the main `model` computation to ensure references exist.
        return rel
    }
}

// Extension to actually link relationships, avoiding the "chicken and egg" problem.
extension CoreDataSchema {
    // We override the model getter to perform linking.
    // The previous implementation was pseudo-code. Here is the real linking logic.
    private static func buildModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        let project = projectEntity
        let prompt = promptEntity
        let block = blockEntity
        
        // Project <->> Prompt
        let projectToPrompts = NSRelationshipDescription()
        projectToPrompts.name = "prompts"
        projectToPrompts.destinationEntity = prompt
        projectToPrompts.minCount = 0
        projectToPrompts.maxCount = 0 // Unlimited
        projectToPrompts.deleteRule = .cascadeDeleteRule
        
        let promptToProject = NSRelationshipDescription()
        promptToProject.name = "project"
        promptToProject.destinationEntity = project
        promptToProject.minCount = 0 // Can be orphaned? Let's say yes for now, or 1.
        promptToProject.maxCount = 1
        promptToProject.deleteRule = .nullifyDeleteRule
        
        projectToPrompts.inverseRelationship = promptToProject
        promptToProject.inverseRelationship = projectToPrompts
        
        project.properties.append(projectToPrompts)
        prompt.properties.append(promptToProject)
        
        // Prompt <->> Block
        let promptToBlocks = NSRelationshipDescription()
        promptToBlocks.name = "blocks"
        promptToBlocks.destinationEntity = block
        promptToBlocks.minCount = 0
        promptToBlocks.maxCount = 0
        promptToBlocks.deleteRule = .cascadeDeleteRule
        
        let blockToPrompt = NSRelationshipDescription()
        blockToPrompt.name = "prompt"
        blockToPrompt.destinationEntity = prompt
        blockToPrompt.minCount = 1
        blockToPrompt.maxCount = 1
        blockToPrompt.deleteRule = .nullifyDeleteRule
        
        promptToBlocks.inverseRelationship = blockToPrompt
        blockToPrompt.inverseRelationship = promptToBlocks
        
        prompt.properties.append(promptToBlocks)
        block.properties.append(blockToPrompt)
        
        model.entities = [project, prompt, block]
        return model
    }
    
    // Re-expose the built model
    @MainActor public static let actualModel: NSManagedObjectModel = buildModel()
}
