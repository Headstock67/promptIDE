# Implementation Plan A: Core Architecture & Data Layer

> [!IMPORTANT]
> **Status**: Waiting for Approval
> **Scope**: Foundation & Data Layer Only. No UI, No Editor Logic.
> **Critical Instruction**: Before executing this plan, review `GEMINI.md` and ensure full compliance.

## 1. Acknowledgement of Hard Constraints

By submitting this plan, implementation commits to the following non-negotiable constraints:

1.  **Apple-only APIs**: Pure Swift/SwiftUI. No 3rd party SDKs, analytics, or external APIs.
2.  **Offline-first**: Zero network dependency for core function. No "offline mode" (always offline).
3.  **Privacy & Security**:
    *   **Data**: `NSPersistentContainer` only. **NO CloudKit** entitlements or references.
    *   **File Protection**: `FileProtectionType.complete` enforced on the persistent store.
    *   **Application Encryption**: Column-level encryption for sensitive fields using CryptoKit (ChaChaPoly/AES-GCM) with keys in Keychain.
4.  **Architecture**: MVVM + Unidirectional Flow. Constructor-based DI. Policy injected into Domain. UI reads Policy, not Config.
5.  **UI/UX**: (Not covered in this plan, but acknowledged) Adherence to Section 18/19.
6.  **No Code**: This document contains only architectural specifications, no production code.

---

## 2. High-Level Architecture

The application follows a **Clean Architecture** approach tailored for iOS/macOS, isolating the Domain logic from the Data mechanics and UI presentation.

```mermaid
graph TD
    subgraph "Presentation Layer (UI/Features)"
        Views[SwiftUI Views]
        VM[ViewModels]
        VM --> Views
    end

    subgraph "Domain Layer (Business Logic)"
        Entities[Entities (Swift Structs)]
        ReposProtocol[Repository Protocols]
        ServicesProtocol[Service Protocols]
        Policy[PolicyRules (Enterprise)]
        
        VM --> ServicesProtocol
        VM --> ReposProtocol
    end

    subgraph "Data Layer (Persistence & Infra)"
        CoreData[Core Data Store]
        ReposImpl[Repository Implementations]
        Crypto[CryptoService]
        Keychain[Keychain]
        Config[ConfigurationService]
        
        ReposImpl -- implements --> ReposProtocol
        ReposImpl --> CoreData
        ReposImpl --> Crypto
        Crypto --> Keychain
        Config -- reads --> ManagedConf[Managed App Config]
    end
    
    subgraph "Dependency Injection (App Composition)"
        Assembler[AppAssembler]
        
        Assembler -- injects --> VM
        Assembler -- composes --> ReposImpl
        Assembler -- composes --> Config
        Config -- injects Policy --> Assembler
    end
```

**Data Flow**: Unidirectional.
1.  **Action**: UI sends Intent to ViewModel.
2.  **Logic**: ViewModel calls Domain Service/Repository.
3.  **Data**: Repository reads/writes to Encrypted Core Data.
4.  **State**: ViewModel updates Published properties.
5.  **Render**: View reflects State.

---

## 3. Module Structure & Responsibilities

The project will use **Swift Package Manager (SPM)** to enforce separation of concerns.

### A. `PromptIDE` (App Target)
*   **Role**: Application Entry Point (`@main`), Platform Integrations (SceneDelegate), Composition Root.
*   **Dependencies**: `PromptIDE_Features`, `PromptIDE_Data`.

### B. `PromptIDE_Domain` (Library)
*   **Role**: The "Heart" of the application. Pure Swift. No Core Data imports (entities are mapped), no UI imports.
*   **Contents**:
    *   **Entities**: `Project`, `Prompt`, `Block` (Structs).
    *   **Protocols**: `PromptRepositoryProtocol`, `SecurityServiceProtocol`.
    *   **Models**: `ValidationFinding`, `PolicyRules`.
*   **Dependencies**: None (Leaf node).

### C. `PromptIDE_Data` (Library)
*   **Role**: Implementation of persistence and infrastructure.
*   **Contents**:
    *   **Core Data**: `NSPersistentContainer` stack, `.xcdatamodeld`.
    *   **Mappings**: DTOs (`NSManagedObject` subclasses) <-> Domain Entities.
    *   **Services**: `CoreDataPromptRepository`, `DeviceSecurityService` (Keychain).
*   **Dependencies**: `PromptIDE_Domain`.

### D. `PromptIDE_Features` (Library)
*   **Role**: UI Schemes and ViewModels.
*   **Contents**: SwiftUI Views, ViewModels, Theme definitions.
*   **Dependencies**: `PromptIDE_Domain`, `PromptIDE_Data` (only for DI composition if needed, strictly prefers Domain types).

---

## 4. Data Layer Design

### Core Data Stack
*   **Container**: `NSPersistentContainer` (Standard).
*   **Store Type**: SQLite.
*   **Location**: Application Support Directory (default).
*   **Protection**: The store URL receives `FileProtectionType.complete` assignment immediately upon creation.

### Schema & Migration
*   **Versioning**: Lightweight migration enabled (`NSMigratePersistentStoresAutomaticallyOption`, `NSInferMappingModelAutomaticallyOption`).
*   **Manual Migration**: For future encryption schema changes, we will implement `NSEntityMigrationPolicy`.
*   **Entities**:
    *   `CDProject`: id, title, createdAt, updatedAt, *encryptedDescription*.
    *   `CDPrompt`: id, title, versionIndex, *encryptedContent*, project (relationship).
    *   `CDBlock`: id, type, *encryptedJsonData*, prompt (relationship).

### Soft Delete Strategy
*   **Implementation**: All core entities (`Project`, `Prompt`) have a `deletedAt: Date?` attribute.
*   **Filtering**: Predicates default to `deletedAt == nil`.
*   **Pruning**: A background `MaintenanceService` runs yearly or on user action to permanently remove soft-deleted items > 30 days old.

---

## 5. Encryption Implementation Plan

We employ a **Defense-in-Depth** strategy.

### Layer 1: File-System Encryption (OS)
*   **Mechanism**: iOS/macOS Data Protection.
*   **Implementation**:
    *   When setting up `NSPersistentStoreDescription`:
    *   `storeDescription.setOption(FileProtectionType.complete as NSObject, forKey: NSPersistentStoreFileProtectionKey)`
*   **Effect**: The entire SQLite file is encrypted by the hardware engine and is inaccessible while the device is locked.

### Layer 2: Application-Level Encryption (CryptoKit)
*   **Target**: Highly sensitive user generated text (e.g., Prompt body, Block content). Meta-data (Creation dates, IDs) remain unencrypted for performance/querying.
*   **Key Management**:
    *   **Key Generation**: `SymmetricKey(size: .bits256)`.
    *   **Storage**: Stored in **Keychain** with `kSecAttrAccessibleAfterFirstUnlock`.
    *   **Rotation**: Not planned for V1, but architecture supports key versioning.
*   **Transformation**:
    *   We will use a **Repository-level transformation** pattern (not `ValueTransformer` inside Core Data to decouple Logic from ObjC runtime).
    *   **Write**: Repository calls `CryptoService.encrypt(string) -> Data`. `CDPrompt.encryptedContent` (Binary Data) is saved.
    *   **Read**: Repository reads `CDPrompt.encryptedContent`, calls `CryptoService.decrypt(data) -> String`. Domain Entity receives plain String.

---

## 6. Dependency Injection & App Composition

We use a **Composition Root** pattern (Pure DI).

### Infrastructure
*   **Protocol**: `AppDependences` defines the contract (`promptRepository`, `settingsService`, etc.).
*   **Assembler**: A struct `production` that initializes the `PersistenceController`, `CryptoService`, and `ConfigurationService`.

### Composition Flow (App Launch)
1.  **`@main` App**: Init `AppAssembler`.
2.  **Assembler**:
    *   Init `KeychainHelper`.
    *   Init `CryptoService(keychain)`.
    *   Init `PersistenceController(crypto)`.
    *   Init `ConfigurationService.loadPolicy()`.
3.  **Injection**:
    *   `AppAssembler` creates `MainViewModel(repository: ..., policy: ...)`.
    *   Views receive ViewModels via `@StateObject` init or `.environmentObject` if global scope is strictly needed (avoided where possible).

---

## 7. Enterprise Policy Injection Plan

### Step 1: Managed App Config (Read)
*   **Source**: `UserDefaults.standard.dictionary(forKey: "com.apple.configuration.managed")`.
*   **Timing**: Read strictly at **App Launch** and on `didChange` notification.

### Step 2: Transformation
*   **Service**: `ConfigurationService`.
*   **Logic**: Parses the reckless dictionary into a type-safe `PolicyRules` struct.
    *   `PolicyRules.isExportAllowed: Bool`
    *   `PolicyRules.forbiddenTerms: [String]`
    *   `PolicyRules.requiredDisclaimer: String?`
*   **Default**: If no config found, `PolicyRules.standard` (permissive) is used.

### Step 3: Injection
*   The `PolicyRules` struct is passed into the `AppAssembler` and subsequently injected into the `PromptEngine` and `ValidationEngine` as a constant configuration.
*   **Constraint Check**: UI components never import `ConfigurationService`. They only see `viewModel.policy.isExportAllowed`.

---

## 8. Risks and Mitigations

| Risk | Mitigation |
| :--- | :--- |
| **Performance overhead of column encryption** | Only encrypt body text. Keep list-view metadata (Titles/Dates) plain text (protected by Layer 1). |
| **Keychain item loss** | If Keychain item is lost, data is unrecoverable. We will implement robust error handling during Key retrieval and "sanity check" alerts on install. |
| **Database Corruption** | Standard SQLite integrity checks on launch. Local backup export feature (future). |
| **Enterprise Policy Latency** | Policies are cached in-memory as `PolicyRules` after launch. App restart required for highly complex policy changes (acceptable constraint). |

## 9. Open Questions

*   **None**. The feedback from the master plan review clarified the CloudKit vs. Core Data ambiguity. We are proceeding with `NSPersistentContainer` only.

---

**Ready for Review.**

---

## 10. Addendum (v1): Sync Strategy & Data Portability

### A. Single-Device Confirmation
*   **V1 Scope**: Strictly single-device. No iCloud Sync. No CloudKit.
*   **Constraint**: No network sync code or entitlements will be included in the V1 build.

### B. Future Sync Readiness
To ensure V2 sync is feasible without breaking changes, V1 schema decisions include:
*   **Primary Keys**: Using `UUID` string/data for all ID fields (No auto-incrementing Integers) to prevent collision on merge.
*   **Timestamps**: All entities include `updatedAt` for Last-Write-Wins conflict resolution logic in future.
*   **Tombstones**: The "Soft Delete" strategy (`deletedAt`) facilitates future deletion propagation.

### C. Encrypted Vault Export/Import (V1 Feature)
Since cloud sync is prohibited, we provide a manual "Air Gap" transfer mechanism.

*   **Format**: `.pidevault` (Custom extension).
    *   Container: ZIP archive.
    *   Content: JSON dump of Project/Prompts (Encrypted) + Manifest.
*   **Security**:
    *   **Encryption**: AES-256-GCM.
    *   **Key Derivation**: `scrypt` from User Passphrase (user must enter a password to export).
    *   **Trust**: The export is an opaque blob.
*   **Import Logic**:
    *   **Action**: "Import Vault" from Settings.
    *   **Behavior**:
        1.  **Decrypt**: User enters passphrase.
        2.  **Conflict Check**: Match incoming UUIDs against local store.
        3.  **Strategy**: **Merge**.
            *   *New UUID*: Insert.
            *   *Existing UUID*: Overwrite local copy (User must explicitly confirm "Replace duplicates").
    *   **Constraint**: Import is a foreground, blocking operation.

---

## 11. Final Compliance Check
Before marking this phase complete:
*   [ ] Confirm codebase adheres to **GEMINI.md** naming and documentation rules.
*   [ ] Verify British English spelling throughout.
*   [ ] Ensure no "magic numbers" or opaque logic in Data Layer.

**Ready for Review.**
