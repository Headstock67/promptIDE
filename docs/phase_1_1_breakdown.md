# Phase 1.1 Task Breakdown: Core Domain & Data

> [!IMPORTANT]
> **Status**: Waiting for Approval
> **Context**: Implementation of Core Domain and Data layers only.
> **Authority**: GEMINI.md (Section 20), Plan A (Architecture).

## 1. Project Bootstrap & Structure
*   **Tasks**:
    *   [ ] Initialize Xcode Project (iOS, iPadOS, macOS).
    *   [ ] Setup SPM Modules: `PromptIDE_Domain`, `PromptIDE_Data`, `PromptIDE_App` (Composition Root only, no Business Logic).
    *   [ ] Configure Build Settings (Strict Concurrency, Swift 6 mode if possible).
*   **Plan Map**: Plan A (Section 3 - Module Structure).
*   **Test Coverage**: Compilation checks.
*   **GEMINI.md Check**: Verify British English in target names.

## 2. Infrastructure: Security Layer
*   **Tasks**:
    *   [ ] Implement `KeychainHelper` (Wrapper for SecItem API).
    *   [ ] Implement `CryptoService` (CryptoKit: AES-GCM or ChaChaPoly).
    *   [ ] Implement `AppLockService` (LocalAuthentication) - Infrastructure only. No UI implementation in Phase 1.1.
*   **Plan Map**: Plan A (Section 5 - Encryption), Plan F (Biometrics).
*   **Test Coverage**:
    *   `SecurityTests.swift`: Verify keys saved/loaded. Verify encryption roundtrip produces different ciphertext for same plaintext. Verify decryption restores original.

## 3. Domain Layer (Pure Swift)
*   **Tasks**:
    *   [ ] Define Entities: `Project`, `Prompt`, `Block` (Structs).
    *   [ ] Define Protocols: `PromptRepositoryProtocol`, `SecurityServiceProtocol`.
    *   [ ] Define Models: `ValidationFinding`, `PolicyRules`.
*   **Plan Map**: Plan A (Section 3 - Domain), Plan C (Logic - Entities).
*   **Test Coverage**:
    *   `EntityTests.swift`: Struct initialization and equality checks.
*   **GEMINI.md Check**: Explicit, descriptive naming (`encryptedContent`).

## 4. Data Layer (Persistence)
*   **Tasks**:
    *   [ ] Setup Core Data Stack (`NSPersistentContainer`).
    *   [ ] Apply `FileProtectionType.complete` to Store URL.
    *   [ ] Create Core Data Models (`CDProject`, `CDPrompt`) - Version 1, Lightweight Migration enabled, `deletedAt` included.
    *   [ ] Implement DTO Mappers (DTO -> Domain).
    *   [ ] Implement `CoreDataPromptRepository`.
*   **Plan Map**: Plan A (Section 4 - Data Layer).
*   **Test Coverage**:
    *   `CoreDataStackTests.swift`: Verify store type and protection.
    *   `PromptRepositoryTests.swift`: CRUD operations (Create, Read, Update, Soft-Delete). Verify encryption transformation occurs at boundary.

## 5. Dependency Injection (Composition)
*   **Tasks**:
    *   [ ] Implement `AppAssembler` (Container).
    *   [ ] Define `AppDependences` Protocol.
*   **Plan Map**: Plan A (Section 6 - DI).
*   **Test Coverage**:
    *   `AssemblyTests.swift`: Verify all dependencies resolve without crashing.

## 6. Failure Mode Tests (Recommended)
*   **Tasks**:
    *   [ ] Implement tests for Keychain unavailability (simulated).
    *   [ ] Implement tests for Missing Encryption Key scenarios.
    *   [ ] Implement tests for Store Load failures.
*   **Goal**: Assert fail-safe behaviour early.

---

## Compliance Checklist (Per Task)
- [ ] **GEMINI.md**: British English used? Documentation present?
- [ ] **Specs**: No CloudKit? No 3rd Party?
- [ ] **Tests**: Tests written *before* or *with* code?

**Ready for Approval to Execute.**
