# Task: Prompt IDE Implementation

## Phase 0: Architecture & Design Definition (Section 16 Obligations)
- [x] Create Core Architecture Note
- [x] Create Privacy and Encryption Architecture Note
- [x] Create Validation Intelligence Architecture Note
- [x] Create Monetisation and StoreKit Design Note
- [x] Create Enterprise Architecture Note
- [/] **User Approval of Architecture Notes** <!-- Critical Gate: Approved -->
- [x] Create Implementation Plan A (Core Architecture)
- [x] Create Implementation Plan B (Design System)
- [x] Create Implementation Plan C (Prompt Editor UX)
- [x] Create Implementation Plan D (Validation UX)
- [x] Create Implementation Plan E (Monetisation UX)
- [x] Create Implementation Plan F (Enterprise UX)
- [x] Create GEMINI.md (Authoritative Rules)

## Phase 1: Foundation & Core Systems (See phase_1_1_breakdown.md)
- [x] Initialze Xcode Project & SPM Structure (Domain, Data, App)
- [x] **Infrastructure**: KeychainHelper, CryptoService, AppLockService
- [x] **Domain**: Entities (Project, Prompt, Block), Protocols
- [ ] **Data**: Core Data Stack (Encryption), Repositories, DTOs
- [ ] **DI**: AppAssembler & Composition Root
- [ ] **Tests**: Security Tests, Entity Tests, Repository Integration Tests

## Phase 1.2: UI Implementation (Strict Phasing)
### 1.2a: Design System & Application Shells
- [x] **Theme System**: Colors, Fonts, Layout (`Color.theme`, `Font.theme`).
- [x] **Components**: `ContextCapsule`, `AppCard`, `StandardHeader`, `EmptyStateView`.
- [x] **Shells**:
    - [x] `NavigationManager` (State).
    - [x] `AppSidebarShell` (Mac/iPad 2-column).
    - [x] `AppTabShell` (iPhone TabView).
- [x] **Verification**: Previews, Dark Mode, GEMINI Compliance.

### 1.2b: Editor Core UI
- [ ] Block Rendering Logic.
- [ ] Focus Management.
- [ ] Interaction Handling for Blocks.

### 1.2c: Validation UI
- [ ] Validation Findings Panel.
- [ ] Highlight Overlays.

### 1.2d: Monetisation UI
- [ ] Paywalls & Settings.
- [ ] Entitlement Indicators.

### 1.2e: Enterprise UI
- [ ] Managed Policy Indicators.
- [ ] Export Gate UI.

## Phase 3: Prompt Editor & Management (Logic Integration)
- [ ] Implement Project & File Management Logic
- [ ] Integrate Editor Canvas with Data Layer
- [ ] Implement Encrypted Vault Export/Import

## Phase 4: AI Validation Engine
- [ ] specialized NLP Analysis Service (NaturalLanguage)
- [ ] Heuristic Analysis Engine
- [ ] Validation UI Integration

## Phase 5: Monetisation (StoreKit Logic)
- [ ] Implement StoreKit 2 Manager
- [ ] Build Paywall & Tier Logic
- [ ] Implement Feature Gating

## Phase 6: Enterprise Features (Logic)
- [ ] Implement Managed App Configuration Reading
- [ ] Build Policy Enforcer
- [ ] Implement Enterprise Export Safeguards

## Phase 7: Hardening & Review
- [ ] Security Audit (File Protection, Keychain)
- [ ] UX Audit (Calmness, Responsiveness)
- [ ] Accessibility Audit
- [ ] Final Performance Tuning

## Phase 8: Verification & Delivery
- [ ] Final Manual Verification Run

