# Implementation Plan C: Prompt Editor & Block Engine UX

> [!IMPORTANT]
> **Status**: Waiting for Approval
> **Scope**: User Experience & Interaction Design Only. **No Implementation/Code details.**
> **Critical Instruction**: Before executing this plan, review `GEMINI.md` and ensure full compliance.

## 1. Acknowledgement of UX Constraints (Section 19)

By submitting this plan, user experience commits to the following principles:

1.  **Calm Editor**: The editor is a place for "long uninterrupted thinking" (19.7.1). UI noise is minimized.
2.  **Predictability**: Changes feel local and predictable. No auto-rearranging content without user intent.
3.  **Focus**: The editor header persists (18.5.2), but toolbars fade or minimize when typing.
4.  **Safety**: All destructive actions (block delete) are clear and reversible (Undo support).

---

## 2. Editor Canvas Behaviour

### A. The Canvas
*   **Structure**: A scrollable vertical stack of "Blocks".
*   **Visuals**:
    *   Background: System Background.
    *   Padding: Comfortable horizontal padding (`spacing.medium`) to readability width.
    *   Overscroll: Bottom padding ensures the last block is never stuck behind the keyboard.
*   **Empty State**: (Section 19.5)
    *   If no blocks exist, a "Calm" invitation appears: "Start typing or add a block to begin."
    *   Action: "Add Text Block" (Primary).

### B. Block Selection & Focus
*   **Tap Interaction**: Tapping a block focuses it.
    *   **Text Block**: Cursor appears at tap position. Keyboard rises.
    *   **Structural Block** (e.g., Separator): Selection border appears.
*   **Active State**:
    *   The active block is visually distinct (subtle border or elevation).
    *   Inactive blocks remain fully visible (no "dimming" distraction).

---

## 3. Block Interaction Engine

### A. Block Types
1.  **Text Block** (Default): Multiline text input. Auto-expanding height.
2.  **Heading Block**: Large, bold text for structural division.
3.  **Separator Block**: Horizontal line (visual break only).
4.  **Reusable Block Reference**: A read-only "Embed" of a separate library block.

### B. Ordering & Rearrangement
*   **Handle**: A unified "Drag Handle" (Six-dot icon) appears on the leading edge of the *active* block only (to reduce noise).
*   **Drag Interaction**:
    *   Long-press handle -> Lift.
    *   Drag vertically -> Spacer gaps open in real-time.
    *   Drop -> Snap to new index. Haptic feedback (`selection`).
*   **Keyboard Reorder**:
    *   Mac/iPad Hardware Keyboard: `Cmd+Opt+Up/Down` moves the focused block.

### C. Creation & Deletion
*   **Creation**:
    *   **Toolbar**: A persistent "Add Block" bar sits above the keyboard (iOS) or at bottom of window (Mac).
    *   **Quick Actions**: "+ Text", "+ Variable", "+ Capsule".
    *   **Placement**: New blocks append to the end (default) or insert below the active block (if focused).
*   **Deletion**:
    *   **Swipe**: Standard swipe-to-delete (iOS).
    *   **Menu**: "Delete Block" in contextual menu.
    *   **Backspace**: If a Text Block is empty and user hits Backspace, the block is deleted and focus moves up (like Note-taking apps).

---

## 4. Context Capsules & Variables (UX)

### A. Variables (`{{variable}}`)
*   **Input**: User types `{{`.
*   **Suggestion**: A lightweight popover appears matching known project variables.
*   **Appearance**:
    *   While editing: Monospaced font, colored syntax highlighting (e.g., `textTertiary` or `brandSubtle`).
    *   While reviewing: Can toggle "Rendered View" to see value.

### B. Context Capsules (Chips)
*   **Insertion**: Via "Add Block" or "Insert" menu.
*   **Visual**:
    *   Inline or Block-level elements.
    *   Icon + Title + "Source" label.
    *   Color: Surface Secondary background, subtle border.
*   **Interaction**:
    *   **Read-Only**: Tapping opens a "Peek" sheet showing the full content of the capsule (e.g., a snippet).
    *   **Edit**: "Edit" button inside the Peek sheet. This prevents accidental edits in the main flow.

---

## 5. Keyboard & Desktop Power UX (Mac/iPad)

### A. Focus Navigation
*   `Tab` / `Shift+Tab`: Move focus between blocks.
*   `Enter`: Break current text block into two (cursor split) OR create new text block below (if at end).

### B. Shortcuts
*   `Cmd+B/I`: Formatting (if supported).
*   `Cmd+Enter`: "Run Validation" (Trigger Primary Action).
*   `Cmd+S`: Save (Manual save visual feedback, though auto-save is continuous).

---

## 6. Feedback & Safety

*   **Saving**:
    *   No "Save" button blocking the UI.
    *   Subtle "Saved" toast/indicator in the header only when network/disk activity finishes.
*   **Validation**:
    *   Validation runs are triggered manually (User Control principle 19.2.3).
    *   Results appear in a **Drawer/Sidebar** (not a modal), preserving context.
    *   Clicking a finding scrolls the Editor to the relevant block and highlights the text span.

---

**Risks**:
*   **Input Latency**: Large scrolling lists of text inputs can be jerky in SwiftUI.
*   **Mitigation**: We will use efficient list rendering (LazyStacks) only if necessary, but prefer `ScrollView` + `VStack` for stability of text focus if the document is reasonably sized (<100 blocks).

---

## 7. Final Compliance Check
Before marking this phase complete:
*   [ ] Confirm codebase adheres to **GEMINI.md** naming and documentation rules.
*   [ ] Verify British English spelling throughout.
*   [ ] Ensure no hidden complexity or opaque one-liners in UX logic.

**Ready for Review.**
