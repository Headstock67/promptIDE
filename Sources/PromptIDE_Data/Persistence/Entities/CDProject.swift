/*
 Managed Object definition for CDProject.
 Layer: Data
*/
import CoreData

@objc(CDProject)
public class CDProject: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var summary: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var deletedAt: Date?
    @NSManaged public var prompts: Set<CDPrompt>?
}
