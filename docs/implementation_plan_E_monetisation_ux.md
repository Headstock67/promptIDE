# Implementation Plan E: Monetisation & Entitlement UX

> [!IMPORTANT]
> **Status**: Waiting for Approval
> **Scope**: User Experience & Interaction Design Only. **No Implementation/Code details.**
> **Critical Instruction**: Before executing this plan, review `GEMINI.md` and ensure full compliance.

## 1. Acknowledgement of Monetisation UX Constraints (Section 19.12)

By submitting this plan, user experience commits to the following principles:

1.  **Intent-Based Triggers**: Paywalls appear *only* when the user attempts an action that requires a higher tier (e.g., "Create Project #2"). We never nag random upsells.
2.  **No Blocking Saves**: We never block a user from saving existing work. Limits apply to *creation* only.
3.  **Respectful Copy**: We explain the value ("Unlock unlimited projects") rather than shaming limits ("You hit the limit").
4.  **Enterprise Stealth**: If the app detects Enterprise Configuration, **ALL** monetisation UI is completely hidden.

---

## 2. Tier Presentation (Visuals)

### A. The "Pro" Badge
*   **Appearance**: Small, subtle pill badge (`Capsule`).
    *   Text: "PRO" or "LIFETIME".
    *   Color: `brandPrimary` text on `brandSubtle` background.
*   **Location**: Settings Header only. No "Pro" badges cluttering the main list views.

### B. Free Tier Indicators
*   **Limit Counters**: In "Create" screens, show usage.
    *   Example: "Projects: 1/1 Used".
    *   Visual: Subtle footer text, using `textSecondary` color.

---

## 3. Paywall Interaction (The "Upgrade Sheet")

### A. Trigger Scenario: "Creation Limit Reached"
*   **Context**: User on Free Tier (1 Project) taps "+" to create Project #2.
*   **Action**:
    1.  The regular "Create Project" sheet does *not* appear.
    2.  Instead, the **Upgrade Sheet** is presented (`sheet`).
*   **Content**:
    *   **Icon**: Unlock/Star symbol.
    *   **Headline**: "Unlock Unlimited Projects".
    *   **Body**: "The Free tier includes one active project. Upgrade to Prompt IDE Pro to create unlimited projects, use block sets, and access advanced validation."
    *   **Products (Cards)**:
        *   **Pro (Annual/Monthly)**: "Subscribes".
        *   **Lifetime**: "One-time purchase".
    *   **Buttons**: "Restore Purchases" (Secondary), "Cancel" (Close).

### B. Trigger Scenario: "Locked Feature"
*   **Context**: User tries to add a "Pro-only Block" (e.g., a specific complex template).
*   **Action**:
    *   The item in the selector has a subtle Lock icon.
    *   Tapping it opens the Upgrade Sheet with context-specific headline: "Unlock Advanced Blocks".

---

## 4. Settings Integration

### A. Subscription Management
*   **Location**: Top section of Settings.
*   **Free State**:
    *   Row: "Prompt IDE Pro".
    *   Action: "Learn More" -> Opens Upgrade Sheet (Informational Mode).
*   **Pro/Lifetime State**:
    *   Row: "Plan: Pro / Lifetime".
    *   Action: "Manage Subscription" (Opens App Store native sheet).

### B. Restore Purchases
*   **Location**: Explicit row in Settings -> "Restore Purchases".
*   **Behavior**: Non-blocking spinner -> Success Toast ("Purchases Restored").

---

## 5. Enterprise Override Behavior

### A. Detection
*   If `ConfigurationService` reports `isEnterpriseManaged == true`:

### B. UI Transformations
1.  **Paywalls Disabled**: Triggers (e.g., Project Creation) **never** show the Upgrade Sheet.
2.  **Settings**:
    *   The "Prompt IDE Pro" row is **Removed**.
    *   Replaced by: **"Managed by [Organization Name]"** (Static row, Shield icon).
    *   "Restore Purchases" is hidden.
3.  **Limits**: All hard limits (Projects count, Block count) are programmatically lifted to infinity.

---

**Risks**:
*   **Ambiguity**: Users might confuse "Enterprise Managed" with "Pro Status".
*   **Mitigation**: The text "Managed by Organization" is explicitly different from "Pro". We do not use the "Pro" badge for Enterprise; we use a Shield icon.

---

## 6. Final Compliance Check
Before marking this phase complete:
*   [ ] Confirm codebase adheres to **GEMINI.md** naming and documentation rules.
*   [ ] Verify British English spelling (e.g., `Monetisation`, `Authorisation`).
*   [ ] Ensure no "Pro" logic leaks into the Enterprise Stealth mode.

**Ready for Review.**
