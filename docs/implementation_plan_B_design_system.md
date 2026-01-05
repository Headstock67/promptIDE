# Implementation Plan B: Design System & Application Shells

> [!IMPORTANT]
> **Status**: Waiting for Approval
> **Scope**: UI Foundations Only. No Feature Logic.
> **Critical Instruction**: Before executing this plan, review `GEMINI.md` and ensure full compliance.

## 1. Acknowledgement of Design Constraints (Section 18)

By submitting this plan, implementation commits to the following Design Rules:

1.  **No New Patterns**: We will strictly use the **Tab Shell** (iPhone only) and **Sidebar Shell** (iPad/macOS).
2.  **Native-First**: SwiftUI `NavigationStack` and `NavigationSplitView`. No custom navigation controllers.
3.  **Semantic Theming**: All colors and fonts defined as semantic tokens (e.g., `Color.theme.surfaceSecondary`) not raw values.
4.  **Component Reuse**: We will build and strictly reuse canonical components for Lists, Headers, and Cards.
5.  **UX Guidelines**: "Calm" aesthetics (no gamification), "Progressive Power" (hidden complexity), and "Safe" interactions (undo support).

---

## 2. Theme System Implementation

We will implement a `Theme` struct accessed via `Color.theme` and `Font.theme` to enforce consistency.

### A. Color Tokens (Semantic)
*   **Surfaces**:
    *   `background`: System background (Adaptable).
    *   `surfaceSecondary`: Sidebar / List row background (Subtle gray).
    *   `surfaceTertiary`: Input fields / Card backgrounds.
*   **Content**:
    *   `textPrimary`: High emphasis.
    *   `textSecondary`: Medium emphasis (metadata).
    *   `textTertiary`: Low emphasis (placeholders).
*   **Accents** (Used sparingly per UX rules):
    *   `brandPrimary`: App tint color.
    *   `brandSubtle`: Tint with low opacity (backgrounds).
    *   `destructive`: Red (Delete actions).
    *   `warning`: Yellow/Orange (Validation findings).

### B. Typography
*   **Strategy**: Strictly use **Dynamic Type** system fonts.
*   **Styles**:
    *   `header`: Large Title / Title 1 (Bold).
    *   `sectionHeader`: Headline (Semibold, Uppercase optional).
    *   `body`: Body (Regular).
    *   `code`: Monospaced (for Editor blocks).
    *   `caption`: Footnote / Caption (Metadata).

### C. Spacing & Layout
*   **Grid**: 4pt baseline logic.
    *   `spacing.small` (4pt)
    *   `spacing.standard` (8pt)
    *   `spacing.medium` (16pt)
    *   `spacing.large` (24pt)
*   **Corner Radii**: Strictly defined (e.g., `radius.card` = 12pt, `radius.capsule` = infinity).

---

## 3. Application Shells (Section 18.3)

### A. iPhone: Tab Shell
*   **Component**: `AppTabShell`
*   **Structure**: `TabView` (Bottom Bar).
    *   **Tab 1: Projects**: `NavigationStack` -> Project List.
    *   **Tab 2: Create**: Modal presentation trigger (creates draft).
    *   **Tab 3: Settings**: `NavigationStack` -> Settings List.
*   **Constraint**: This shell is for **iPhone only**.

### B. iPad & macOS: Sidebar Shell
*   **Component**: `AppSidebarShell`
*   **Structure**: `NavigationSplitView(sidebar: ..., detail: ...)` (2-Column).
    *   **Sidebar**: Navigation only (Library, Projects, Tags).
    *   **Detail**: Content area (List or Editor).
    *   **Constraint**: Strictly **2-column** default. Right-hand context sidebar is an overlay/inspector, not a 3rd navigation column.
*   **Inspector**: `inspector(isPresented: ...)` modifier for the Right-hand Context Sidebar (Validation/Properties).

---

## 4. Core UI Components

### A. Global Components (Section 18.5 - 18.10)
1.  **`StandardHeader`**:
    *   Wraps `ToolbarItem` logic.
    *   Props: `title`, `subtitle`, `primaryAction`.
2.  **`EditorHeader`**:
    *   Document title input.
    *   "Export" button (Right).
    *   "Version" indicator (Left/Below).
3.  **`ContextCapsule`**:
    *   Visual: Rounded rect, subtle border, icon + truncated text.
    *   Interactive: Tap to inspect (Popover/Sheet).
4.  **`AppCard`** (for Lists):
    *   VStack with `surfaceTertiary` background.
    *   Standard padding (`spacing.medium`).
    *   Shadows: **None** (Flat, border-based or color-based separation for "Calm" feel).

### B. List Patterns (Section 18.8)
1.  **`SimpleListRow`**:
    *   Icon | Title (VStack: Subtitle) | Spacer | Badge | Chevron.
2.  **`CardList`** (Option A: List-based):
    *   **Structure**: `LazyVStack` (Single Column) or System List with Custom Cell.
    *   **Visual**: Large visual cards (Prompts/Templates).
    *   **Behavior**: Standard vertical entry list behavior. **No Grids**.
3.  **`FilterDrawer`**:
    *   **iPhone**: `sheet(presentationDetents: [.medium])` (Bottom Drawer).
    *   **iPad/macOS**: `popover(attachmentAnchor: ...)` or **Left Overlay Drawer** (if implemented custom, but Popover is standard native equivalent for 'Drawer' in this context). *Refinement to spec request*: "Popover anchored to Filter button" for macOS, "Left overlay drawer" for iPad. We will implement these strictly.

---

## 5. Interaction & Feedback (UX Section 19)

### A. Feedback Utility
*   **`FeedbackManager`**:
    *   Haptic Engine (iOS): `selection`, `success`, `error` (light).
    *   Toast Overlay: ZStack overlay for "Saved", "Copied". NO system alerts for successes.
*   **States**:
    *   **Empty**: `EmptyStateView(icon, message, action)` shown in lists.
    *   **Loading**: Shimmer effect on placeholder cards (Skeleton loader), never a full-screen spinner.

### B. Modals (Terminology Mapping)
*   **`AppSheet`** (= Section 18.11 **Form/Wizard Modal**):
    *   Standard wrapper for sheets with a "Cancel/Done" toolbar interaction.
    *   Used for: Creation Wizards, Settings sub-pages.
*   **`DestructiveConfirmation`** (= Section 18.11 **Confirmation Modal**):
    *   Custom action sheet (iOS) / Dialog (macOS).
    *   Red "Delete" button, clear "Cancel".

---

## 6. Accessibility Strategy (Section 19.13)
*   **Dynamic Type**: All views use `scaledMetric` or standard fonts.
*   **VoiceOver**:
    *   All Icon-only buttons must have `.accessibilityLabel`.
    *   Capsules must read "Source type, Title".
    *   Validation findings must read "Warning: [Content]".
*   **Contrast**: Theme colors verified against WCAG AA.

---

## 7. Development Phases (Plan B)

*   **B1: Theme Engine**: Define Tokens, Fonts, Spacing in `UIComponents`.
*   **B2: Layout Shells**: Build `AppRoot` switching between iPad/Mac (Sidebar) and Phone (Tab).
*   **B3: Core Components**: Build Header, Capsule, Card, EmptyState views.
*   **B4: Sheets & Feedback**: Build Toast system and Modal wrappers.

---

**Risks**:
*   **iPad/Mac Consistency**: Ensuring `NavigationSplitView` behaves robustly on iPad (3-column vs 2-column) without "Layout Drift".
*   **Mitigation**: We will stick to 2-column (Sidebar + Detail) for simplicity unless 3-column is strictly needed for the Prompt List -> Editor flow.

---

## 8. Final Compliance Check
Before marking this phase complete:
*   [ ] Confirm codebase adheres to **GEMINI.md** naming and documentation rules.
*   [ ] Verify British English spelling throughout.
*   [ ] Ensure UI code is clear, readable, and properly documented.

**Ready for Review.**
