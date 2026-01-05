# Implementation Plan F: Enterprise Policy Enforcement UX & Behaviour

> [!IMPORTANT]
> **Status**: Waiting for Approval
> **Scope**: User Experience & Interaction Design Only. **No Implementation/Code details.**
> **Critical Instruction**: Before executing this plan, review `GEMINI.md` and ensure full compliance.

## 1. Acknowledgement of Enterprise UX Constraints

By submitting this plan, user experience commits to the following principles:

1.  **Non-Blocking Editing**: We **NEVER** prevent the user from typing. Forbidden terms are flagged, not censored.
2.  **Clear Attribution**: Users must know *why* an action is blocked ("Action blocked by Organization Policy", not just "Error").
3.  **Export Gating**: The boundary of enforcement is the *Export* action (getting data out), not the creation process.
4.  **Transparency**: The user must be able to see exactly what policies are applied to their device.

---

## 2. Editor Interaction (Policy Flags)

### A. Violation Presentation
*   **Context**: User types a word on the `forbiddenTerms` list.
*   **Feedback**:
    *   **In-Editor**: No red squiggles (Calm principle).
    *   **Validation Sidebar**: A new finding appears immediately (or on next validation run).
*   **Visual**:
    *   **Icon**: Shield with Slash (Red).
    *   **Category**: "Policy Violation".
    *   **Text**: "The term '[Term]' is prohibited by your organization."
*   **Behavior**:
    *   Tapping the finding highlights the term in the editor.
    *   The finding persists until the term is removed.

### B. Header Status
*   If *any* blocking policy violations exist:
    *   The **Export Button** in the editor header changes state.
    *   **Visual**: Dimmed (Disabled) OR Warning Icon badge (depending on Platform strictness).
    *   **Tap**: Tapping the disabled/warning export button reveals the "Policy Check" sheet.

---

## 3. The Export Gate (Crucial UX)

### A. Scenario: Clean Export
*   User taps Export.
*   Validation runs. No violations.
*   **Disclaimer Injection**: If policy requires a disclaimer:
    *   A Toast appears: "Organization disclaimer added."
    *   The export payload has the text appended automatically.

### B. Scenario: Blocked Export (Violation Present)
*   User taps Export.
*   **UI**: A **Sheet** is presented (not a native alert).
*   **Header**: "Export Blocked".
*   **Body**: "Your content contains terms prohibited by [Organization Name]. Please resolve these issues to proceed."
*   **List**: Displays the specific Blocking Findings.
*   **Action**: "Dismiss" (Primary). The user *cannot* bypass this screen.

### C. Scenario: Policy-Disabled Export
*   If `policy.allowExport == false` (Total lockdown):
    *   The Export button is hidden or permanently disabled.
    *   Tapping it (if visible) shows a Toast: "Exporting is disabled by your policy."

---

## 4. Management Visibility (Transparency)

### A. Settings "Managed" View
*   **Entry**: "Managed by [Organization]" row in Settings.
*   **Appears**: Only when managed configuration is detected.
*   **Content**:
    *   **Header**: Organization Name & Logo (if available/generic).
    *   **Status**: "Active" (Green).
    *   **Policy List (Read-Only)**:
        *   "Exporting: [Allowed/Blocked]"
        *   "Disclaimers: [Enabled/Disabled]"
        *   "Restricted Terms: [Count] active rules"

---

**Risks**:
*   **Frustration**: Users may type a long prompt and only realize at the end they can't export it.
*   **Mitigation**: The Validation Sidebar is available anytime. If a *Blocking* violation exists, we may consider a subtle "Shield" icon in the status bar of the editor to hint at the blockage before the export attempt.

---

## 5. Final Compliance Check
Before marking this phase complete:
*   [ ] Confirm codebase adheres to **GEMINI.md** naming and documentation rules.
*   [ ] Verify British English spelling throughout.
*   [ ] Ensure "Block" logic is traceable and not a silent failure.

**Ready for Review.**
