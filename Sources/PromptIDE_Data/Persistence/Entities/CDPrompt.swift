/*
 Managed Object definition for CDPrompt.
 Layer: Data
*/
import CoreData

@objc(CDPrompt)
public class CDPrompt: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var deletedAt: Date?
    @NSManaged public var project: CDProject?
    @NSManaged public var blocks: Set<CDBlock>?
}
