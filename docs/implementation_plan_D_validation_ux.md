# Implementation Plan D: Validation Engine UX & Behaviour

> [!IMPORTANT]
> **Status**: Waiting for Approval
> **Scope**: User Experience & Interaction Design Only. **No Implementation/Code details.**
> **Critical Instruction**: Before executing this plan, review `GEMINI.md` and ensure full compliance.

## 1. Acknowledgement of Validation UX Constraints (Section 19.8)

By submitting this plan, user experience commits to the following principles:

1.  **Advisory Role**: The validator is a "Second Pair of Eyes", not a judge. It never claims objective truth.
2.  **Calm Tone**: Findings use neutral language ("Consider clarifying...", "This claim..."). No "Error", "Hallucination", or "False" labels.
3.  **Non-Blocking**: Validation results never block export or saving (unless Enterprise Policy explicitly gates Export).
4.  **No Scores**: We do not provide a "Trust Score" or "Accuracy Rating" to avoid false confidence.

---

## 2. Validation Workflow

### A. Triggering Validation
*   **Action**: Explicit "Check" button in the Editor Header (Stethoscope or Eye icon).
*   **Behavior**:
    1.  Button state changes to "Analyzing..." (Subtle activity indicator, no modal spinner).
    2.  Analysis runs in background (non-blocking).
    3.  Findings appear asynchronously in the Results Pane.

### B. Results Presentation (The "Findings" Pane)
*   **Location**:
    *   **iPad/macOS**: Right-hand Context Sidebar (`inspector`).
    *   **iPhone**: Bottom Sheet (Medium Detent).
*   **Structure**: Grouped by Category.
    *   *Uncertainty*
    *   *Absolute Claims*
    *   *Source Formatting*
    *   *Entities*
*   **Zero State** (Clean): "No obvious risks detected. Remember to verify claims manually." (Calm positive reinforcement).

---

## 3. Finding Interaction

### A. The Finding Card
*   **Visual**: Small card in the results pane.
*   **Content**:
    *   **Icon**: Specific to category (e.g., Question Mark for Uncertainty).
    *   **Snippet**: Preview of the text with the issue.
    *   **Explanation**: "This sentence uses 'always', which is a strong absolute claim."
*   **Color Coding**:
    *   **Yellow/Orange**: Advisory/Warning (Standard).
    *   **Blue**: Information/Structural (e.g., Entity count).
    *   **No Red**: Red is reserved for Enterprise Policy Violations only.

### B. Navigation (Highlighting)
*   **Action**: Tapping a Finding Card.
*   **Effect**:
    1.  Editor scrolls to the specific Block containing the text.
    2.  The relevant text span is **Highlighted** (e.g., Yellow background highlight).
    3.  Highlight persists until the user edits the block or dismisses the finding.

### C. Resolution
*   **Actions**:
    *   **Edit**: User modifies the text in the Editor. The finding automatically disappears if the trigger text is removed (Reactive).
    *   **Ignore**: User swipes left on the card -> "Dismiss". Validates the user's choice to accept the risk.

---

## 4. Specific UX Behaviors

### A. "Heads Up" Highlighting (Optional)
*   *Future consideration (V2)*: Inline underlining while typing.
*   *V1 Decision*: **Disabled**. Validation is strictly an *on-demand* review mode to preserve the "Calm Editor" state. No wavy red lines while writing.

### B. Enterprise Policy Flags
*   **Differentiation**: Policy violations (e.g., "Forbidden Term") appear in the same list but are visually distinct.
*   **Visual**: Shield Icon, slightly higher emphasis (Bold text).
*   **Tone**: "This term is restricted by your organization policy." (Factual, not scolding).

### C. Export Gate UX
*   If validation findings exist but are only "Advisory":
    *   Export proceeds immediately.
*   If "Enterprise Violations" exist:
    *   Export action presents a **Sheet**.
    *   Title: "Organization Policy Check".
    *   Content: List of blocking violations.
    *   Action: "Edit Document" (Primary), "Cancel". (Export is disabled).

---

## 5. Accessibility Strategy
*   **VoiceOver**:
    *   Finding Cards read: "Advisory: Uncertainty. 'I think maybe'. Double tap to show in editor."
    *   Editor Highlights: Custom rotor action or "Misspelled"-style attribute usage to announce "Text has validation finding" when traversing the editor.
*   **Color Blindness**: Icons must accompany all colored indicators. Do not rely on Yellow vs Blue alone.

---

**Risks**:
*   **Overwhelming Results**: If a user pastes a large text, they might get 50+ findings.
*   **Mitigation**: The Findings Pane will use "Smart Collapse". Show top 3 per category, "Show All" expansion. Priority sorting puts "Absolute Claims" (High Risk) at the top.

---

## 6. Final Compliance Check
Before marking this phase complete:
*   [ ] Confirm codebase adheres to **GEMINI.md** naming and documentation rules.
*   [ ] Verify British English spelling throughout (Example: `Validator`, `Analyser`).
*   [ ] Ensure "Calm" tone is used in all user-facing strings.

**Ready for Review.**
