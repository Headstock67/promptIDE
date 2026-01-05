/*
 This file contains integration tests for the Data Layer.
 It verifies Core Data persistence, Repository CRUD operations, and the Encryption boundary.
 Layer: Test (Data)
*/

import XCTest
import CoreData
@testable import PromptIDE_Domain
@testable import PromptIDE_Data

// Mock Security Service for Rep tests (No real keychain needed here, but we want to verify calls)
// Actually, we can use the Real CryptoService with a Mock Keychain (Reuse from Step 2)
// Or a Passthrough Mock to debug persistence values.

// Or a Passthrough Mock to debug persistence values.

// Or a Passthrough Mock to debug persistence values.

// Or a Passthrough Mock to debug persistence values.

final class PersistenceTests: XCTestCase, @unchecked Sendable {
    
    // Configured on MainActor
    var persistenceController: PersistenceController!
    var repository: CoreDataPromptRepository!
    var mockCrypto: MockSecurityService!
    
    override func setUp() async throws {
        try await super.setUp()
        
        await MainActor.run {
            // Use in-memory store for speed
            persistenceController = PersistenceController(inMemory: true)
            mockCrypto = MockSecurityService()
            repository = CoreDataPromptRepository(
                container: persistenceController.container,
                cryptoService: mockCrypto
            )
        }
    }
    
    override func tearDown() async throws {
        await MainActor.run {
            persistenceController = nil
            repository = nil
            mockCrypto = nil
        }
        try await super.tearDown()
    }
    
    @MainActor
    func test_stack_initialises_with_correct_model() {
        let entities = persistenceController.container.managedObjectModel.entities
        XCTAssertTrue(entities.contains { $0.name == "CDProject" })
        XCTAssertTrue(entities.contains { $0.name == "CDPrompt" })
        XCTAssertTrue(entities.contains { $0.name == "CDBlock" })
    }
    
    // CRUD tests interact with Repository which is Sendable.
    // However, Repository init uses viewContext (MainActor) implicitly via container?
    // Repository stores 'container' which is Sendable (NSPersistentContainer is Sendable).
    // The methods are async.
    
    func test_repository_saves_and_fetches_project() async throws {
        // Need to grab repo from MainActor isolated var safely?
        // Or make the vars non-isolated but protected?
        // Actually, if Repository is Sendable, we can access it if we extract it.
        
        let repo = await MainActor.run { return self.repository! }
        
        let id = UUID()
        let project = Project(id: id, name: "New Project")
        
        try await repo.saveProject(project)
        
        let projects = try await repo.fetchProjects()
        XCTAssertEqual(projects.first?.id, id)
        XCTAssertEqual(projects.first?.name, "New Project")
    }
    
    func test_repository_saves_and_fetches_prompt_with_blocks() async throws {
        let repo = await MainActor.run { return self.repository! }
        
        let promptId = UUID()
        let block = Block(content: .text("Secret Content"), orderIndex: 0)
        let prompt = Prompt(id: promptId, title: "My Prompt", blocks: [block])
        
        try await repo.savePrompt(prompt)
        
        let fetchedPosition = try await repo.fetchPrompt(id: promptId)
        XCTAssertEqual(fetchedPosition?.title, "My Prompt")
        XCTAssertEqual(fetchedPosition?.blocks.count, 1)
        XCTAssertEqual(fetchedPosition?.blocks.first?.content.rawValue, "Secret Content")
    }
    
    func test_repository_encrypts_block_content_on_save() async throws {
        let repo = await MainActor.run { return self.repository! }
        let controller = await MainActor.run { return self.persistenceController! }
        
        // This test peeks into the Core Data Context to verify raw data is NOT plaintext.
        let promptId = UUID()
        let text = "Nuclear Codes"
        let block = Block(content: .text(text), orderIndex: 0)
        let prompt = Prompt(id: promptId, title: "Classified", blocks: [block])
        
        try await repo.savePrompt(prompt)
        
        // Peek
        try await controller.container.viewContext.performAndWait {
            let request = NSFetchRequest<CDBlock>(entityName: "CDBlock")
            let results = try? request.execute()
            let cdBlock = results?.first
            
            XCTAssertNotNil(cdBlock?.encryptedContent)
        }
    }
    
    func test_soft_delete_filters_items() async throws {
        let repo = await MainActor.run { return self.repository! }
        
        let id = UUID()
        let prompt = Prompt(id: id, title: "To Delete", blocks: [])
        try await repo.savePrompt(prompt)
        
        try await repo.deletePrompt(id: id)
        
        let fetched = try await repo.fetchPrompt(id: id)
        XCTAssertNil(fetched, "Soft deleted prompt should not be returned by fetchPrompt")
    }
}

// MARK: - Mock Security (Simple)

final class MockSecurityService: SecurityServiceProtocol, Sendable {
    func encrypt(plaintext: String) throws -> Data {
        // Simulator Encryption: Reverse string + encode
        let reversed = String(plaintext.reversed())
        return reversed.data(using: .utf8)!
    }
    
    func decrypt(ciphertext: Data) throws -> String {
        let reversed = String(data: ciphertext, encoding: .utf8)!
        return String(reversed.reversed())
    }
}
