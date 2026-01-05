# GEMINI.md - Authoritative Coding Standards & Rules

> [!IMPORTANT]
> **Mandatory Compliance**: All code written for Prompt IDE must strictly adhere to these rules.
> Failure to comply will result in rejection.

## 1. Coding Standards (Non-Negotiable)

All code must be written to be readable and understandable by a non-technical human.

### 1.1 Language & Style
*   **British English (GB) only**: `initialise`, `colour`, `favour`, `behaviour`, `analyser`.
*   **Tone**: Calm, professional tone in comments and identifiers.
*   **Prohibited**: Slang, abbreviations, shorthand.

### 1.2 Naming Rules (Mandatory)
Names must describe **what** the thing is and **why** it exists.

*   **Allowed**: `encryptedPromptContent`, `validatePromptAgainstEnterprisePolicy()`, `persistentStoreFileProtectionApplier`.
*   **Not Allowed**: `tmp`, `mgr`, `svc`, `data`, `utils`, `helper` (unless extremely specific like `KeychainHelper`).

### 1.3 File-Level Documentation
Every file must begin with a header comment explaining:
*   **Responsibility**: What this file is responsible for.
*   **Exclusions**: What it deliberately does not do.
*   **Layer**: Domain, Data, UI, etc.

*Example:*
```swift
/*
 This file defines the PromptEditorViewModel, which coordinates user-driven prompt editing behaviour.
 It does not perform persistence, validation, or policy enforcement directly.
 Layer: Presentation
*/
```

### 1.4 Function-Level Documentation
Every public function and every non-trivial private function must include:
*   **What**: The action performed.
*   **Why**: The reason strictly.
*   **Inputs/Outputs**: Parameters and returns.
*   **Side Effects**: Any state changes or IO.

### 1.5 Inline Commentary
Inside functions:
*   Explain **intent**, not syntax.
*   Describe expected outcomes.
*   Clarify edge cases.
*   **Structure**: Prefer explicit control flow over cleverness (No chaining one-liners that hide logic).

---

## 2. Architectural Discipline
*   **Pattern**: MVVM with strict unidirectional data flow.
*   **Boundaries**: No UI reading `UserDefaults` or Configuration directly. Domain/Policy must be injected.
*   **Leakage**: No cross-layer leakage.
*   **DI**: Dependency Injection via **constructors only**.
*   **Clarity**: If a dependency is unclear, stop and ask.

### 2.1 UI Purity Rule (Non-Negotiable)
SwiftUI Views are presentation-only. They must contain **no business logic**.

The UI layer **may**:
*   Render state provided by ViewModels.
*   Collect user input.
*   Forward user intent (tap, type, drag, dismiss).
*   Display feedback (toasts, sheets, disabled states).

The UI layer **must not**:
*   Decide whether actions are allowed (export, create, validate, purchase).
*   Implement policy decisions (enterprise rules, forbidden terms).
*   Implement validation rules or risk analysers.
*   Perform encryption, persistence, or entitlement checks.
*   Read `UserDefaults`, Managed Configuration, or Keychain directly.
*   Contain conditional business branching that changes outcomes.

**All decisions must come from injected Domain services via ViewModels.**

### 2.2 ViewModel Responsibility Rule (Strict)
ViewModels coordinate user intent and expose UI-ready state.

ViewModels **may**:
*   Call Domain services and repositories.
*   Transform Domain results into published UI state.
*   Hold transient UI state (selection, focus, active block).

ViewModels **must not**:
*   Re-implement Domain rules.
*   Contain policy or entitlement logic beyond delegating to Domain.
*   Access `UserDefaults` or Managed Configuration directly.

### 2.3 “Who Decided?” Test (Quick Enforcement Check)
If a View or ViewModel contains logic like:
`if userIsAllowedToExport { ... }`

Then the code must make it explicit that:
*   The **Domain layer** decided this.
*   The **UI** is only reflecting it.

**If the decision originates in a View, ViewModel, or UserDefaults, it is a defect.**

---

## 3. Automated Testing (Mandatory)

Testing is not optional and must be developed alongside production code.

### 3.1 Test-First Bias
For each significant unit of logic:
*   A test must exist.
*   The test must describe intent in **plain English**.
*   The test must be readable by non-developers.

### 3.2 Required Test Types
*   **A. Unit Tests**: Domain entities, Validation analysers, Policy logic, Subscription decisions. (Deterministic & Offline).
*   **B. ViewModel Tests**: State transitions, User intent handling. (No UI rendering assertions).
*   **C. Security Tests**: Verify encryption (not stored in plain text), Keychain failure handling, FileProtection application.
*   **D. Enterprise Policy Tests**: Inject mock `PolicyRules`, verify gating at boundaries.

---

## 4. Test Structure & Naming
*   **Location**: Tests live alongside their target module.
*   **Naming**: Must describe behaviour.
    *   *Good*: `test_export_is_blocked_when_forbidden_terms_exist()`
    *   *Bad*: `test_export_blocked_case_1()`

---

## 5. Continuous Verification
*   Each module must compile independently.
*   Tests must pass before moving to the next feature.
*   Incremental, reviewable delivery only. No large dumps.

---

## 6. Explicit Instruction
If any requirement, behaviour, or dependency is unclear, you must **pause and ask for clarification**. Do not infer. Do not assume. do not silently simplify.
