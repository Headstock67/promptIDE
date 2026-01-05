/*
 Managed Object definition for CDBlock.
 Layer: Data
*/
import CoreData

@objc(CDBlock)
public class CDBlock: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var orderIndex: Int64
    @NSManaged public var typeRaw: String? // "text", "heading", "separator"
    @NSManaged public var encryptedContent: Data? // The secure payload
    @NSManaged public var deletedAt: Date?
    @NSManaged public var prompt: CDPrompt?
}
