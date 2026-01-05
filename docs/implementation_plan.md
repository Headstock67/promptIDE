# Implementation Plan - Prompt IDE

> [!IMPORTANT]
> **Approval Required**: As per Specification Section 16, the **Architecture & Design Specifications** (Section I below) must be approved by the User before any code is written.

## I. Architecture & Design Specifications (Required Approvals)

### 1. Core Architecture Note
**Philosophy**: Native, Offline, Deterministic.
- **Pattern**: MVVM (Model-View-ViewModel) with a strict Unidirectional Data Flow for state management within the Editor.
- **Tech Stack**:
    - **UI**: SwiftUI (100% Native). No WebViews.
    - **Concurrency**: Swift Concurrency (`async`/`await`).
    - **Data**: Core Data using `NSPersistentContainer`.
    - **Cloud**: **CloudKit is not used.** No CloudKit entitlements are present. No remote sync is implemented.
    - **DI**: Pure Dependency Injection (Constructor-based).
- **Module Structure**:
    - `AppCore`: Shared logic, models, and data layer.
    - `PromptEngine`: The block-based editing logic and data structures.
    - `ValidationEngine`: The analysis pipeline (NLP + Heuristics).
    - `UIComponents`: Shared design system (Buttons, Shells, Theme).
    - `App-iOS`: iOS/iPadOS specific entry points and navigation.
    - `App-macOS`: macOS specific entry points and window management.

### 2. Privacy and Encryption Architecture Note
**Promise**: Zero Exfiltration. Data At Rest Encryption.
- **Strategy**: We have selected a single, explicit encryption layered approach using only Apple System APIs. **SQLCipher is NOT used.**
    - **Primary Layer (File Level)**: The Core Data underlying SQLite store (`.sqlite`, `.sqlite-wal`, `.sqlite-shm`) will be protected using `FileProtectionType.complete`. This ensures the database is completely inaccessible until the device is unlocked by the user.
    - **Secondary Layer (Application Level)**: Highly sensitive text fields (`Prompt.content`, `Project.description`) will be encrypted at the column level using `CryptoKit` (SymmetricKey) before being written to Core Data.
        - Keys are generated locally and stored securely in the **Secure Enclave / Keychain**.
        - This provides defense-in-depth: even if the file system is compromised, the raw prompt text remains unreadable without the Keychain item.
- **App Lock**: `LocalAuthentication` framework.
    - View modifier `onReceive(scenePhase)` to cover UI with a `PrivacyShieldView` immediately when backgrounded.
    - Biometric challenge (FaceID/TouchID) required to reveal content.

### 3. Validation Intelligence Architecture Note
**Role**: A "Second Pair of Eyes", not a Truth Engine.
- **Pipeline**:
    1.  **Tokenizer**: Break text into sentences/claims using `NaturalLanguage`.
    2.  **Heuristic Analyzers**:
        - *Uncertainty Detector*: Regex/Keyword matching for weak language ("might", "I think").
        - *Absolute Claim Detector*: Catching "always", "never" for highlighting.
        - *Source Checker*: Scanning for URL patterns or citation markers and verifying format only.
    3.  **NLP Model (On-Device)**:
        - `NLTagger` for Named Entity Recognition (NER).
        - Sentence embedding similarity checks to detect *potential* contradictions.
- **Bounding & Constraints**:
    - **Heuristic Only**: This system detects risk, not logical truth. False positives are expecting and acceptable. Findings are advisory suggestions, not errors.
    - **Scope**: Analysis is strictly **single-document**. No cross-document comparison, no historical inference, and no background reprocessing of old prompts.
    - **Determinism**: The same input must always yield the same findings.

### 4. Monetisation and StoreKit Design Note
**Model**: Hybrid (Free, Pro Sub, Lifetime, Enterprise).
- **Implementation**: `StoreKit 2` with a `SubscriptionManager`.
- **Logic**:
    - `Free`: Hard limits checked before creation actions.
    - `Pro` / `Lifetime`: Unlock all limits.
    - `Enterprise`: **Monetisation UI Disabled.**
        - When Enterprise mode is active, the `SubscriptionManager` totally bypasses StoreKit checks.
        - Upsells, Paywalls, and "Pro" badges are hidden.
        - Settings screen displays a "Managed by your organisation" badge.
- **Privacy**: No revenue analytics SDKs.

### 5. Enterprise Architecture Note
**Deployment**: MDM / Managed App Configuration.
- **Mechanism**: `UserDefaults.standard.object(forKey: "com.apple.configuration.managed")`.
- **Injection Policy**:
    - Enterprise configuration is read **once** at app launch (or on `didChange` notification) by a `ConfigurationService`.
    - This service injects a `PolicyRules` object into the Domain Layer (`AppCore`).
    - **UI Rule**: UI components **NEVER** read UserDefaults or Managed Configuration directly. They strictly consume the injected `PolicyRules` (e.g., `canExport: Bool`).
- **Enforcement & UX**:
    - `forbiddenTerms`: Terms are strictly **flagged** using the Validation Engine's finding system.
    - **No Blocking**: Typing is never blocked. Content never disappears. No "red" error states while writing.
    - **Gate**: Enforcement strictly happens at the **Export** action. If policy violations exist, the Export action is disabled with a calm explanation.

---

## II. Proposed Changes & Development Phases

### Phase 1: Foundation & Core Systems
- **Initialize Project**: Swift Package Manager structure.
- **Security**: Implement `BiometricGuard`, `KeychainHelper`, and `CryptoKit` transformers.
- **Data**: Set up Core Data with `NSPersistentContainer` and `FileProtectionType.complete`.

### Phase 2: Design System & Shells
- **Theme**: Implement `Color.theme.surfaceSecondary`, etc.
- **Navigation**: iOS/iPadOS Tab Shells, macOS Sidebar Shell.

### Phase 3: The Prompt Engine
- **Data Model**: `Project` -> `Block` (Ordered set).
- **Editor**: Custom SwiftUI View with "Context Capsules".

### Phase 4: Validation Engine
- **Service**: `AnalysisService` (Heuristics + NLP).
- **UI**: Findings Sidebar/Drawer.

### Phase 5: Monetisation
- Integrate `StoreKit` for Free/Pro/Lifetime logic.

### Phase 6: Enterprise Features
- Implement Managed Config reader (`ConfigurationService`).
- Inject `PolicyRules` into Domain Layer.
- Implement "Export Gate" logic.

### Phase 7: Hardening & Review
- **Security Audit**: Verify File Protection and Keychain integration.
- **UX Audit**: "Calmness" check against Section 19.
- **Accessibility**: VoiceOver and Dynamic Type verification.
- **Performance**: Scroll performance tuning.

## III. Verification Plan

### Automated Tests
- **Unit Tests**:
    - `PromptEngineTests`: Verify Block reordering, creating, deleting.
    - `ValidationTests`: Feed specific strings and assert `Uncertainty` finding is generated.
    - `EnterprisePolicyTests`: Inject a mock `PolicyRules` object and verify `isExportAllowed` returns correct boolean.
- **UI Tests**:
    - Verify App Lock covers content.
    - Verify Enterprise Badge appears when configuration is present.

### Manual Verification
- **App Lock**: Background/Foreground cycles.
- **Offline**: Airplane mode functionality check.
- **Enterprise**: Sideload `.plist` to Simulator and verify Monetisation UI is hidden.
