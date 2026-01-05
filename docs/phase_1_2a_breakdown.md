# Phase 1.2a Task Breakdown: Design System & Application Shells
**Parent Plan**: [Implementation Plan B](implementation_plan_B_design_system.md)
**Compliance**: GEMINI.md

This phase focuses exclusively on the visual foundations and navigation structure. **Zero business logic** will be implemented.

## 1. Theme System (Foundation)
- [ ] **Color Tokens**: Implement `Color.theme` extension.
    - [ ] Surfaces (`background`, `surfaceSecondary`, `surfaceTertiary`)
    - [ ] Content (`textPrimary`, `textSecondary`, `textTertiary`)
    - [ ] Accents (`brandPrimary`, `brandSubtle`, `destructive`, `warning`)
- [ ] **Typography**: Implement `Font.theme` extension.
    - [ ] Mapped to Dynamic Type (`header`, `sectionHeader`, `body`, `code`, `caption`).
- [ ] **Layout Constants**: Structs for `Spacing` and `Radius`.

## 2. Core UI Components (Reusable)
- [ ] **ContextCapsule**: 
    - [ ] Rounded rectangle style with icon support.
    - [ ] Zero interactions (for now).
- [ ] **AppCard**:
    - [ ] Standard container with `surfaceTertiary` background.
    - [ ] Used for List Rows.
- [ ] **StandardHeader**:
    - [ ] Reusable Toolbar wrapper.
- [ ] **EmptyStateView**:
    - [ ] Icon + Message + Action Button.

## 3. Application Shells (Navigation)
- [ ] **Navigation State**:
    - [ ] `NavigationManager` (ObservableObject) to handle selection state.
- [ ] **Mac/iPad Shell**:
    - [ ] `AppSidebarShell`: `NavigationSplitView` (2-column).
    - [ ] Sidebar List (Projects Dummy Data).
    - [ ] Detail Area (Placeholder).
- [ ] **iPhone Shell**:
    - [ ] `AppTabShell`: `TabView` with 3 tabs (Projects, Create, Settings).

## 4. Verification Checkpoints
- [ ] **Preview Tests**: Ensure all components render in Light/Dark mode.
- [ ] **Compilation**: App builds without warnings.
- [ ] **GEMINI Compliance**:
    - [ ] No Business Logic in Views (Mock data only).
    - [ ] British English in all UI strings.
    - [ ] Strict strict concurrency checks.

## 5. Exit Criteria
- The App runs.
- On Mac/iPad: Sidebar is visible, navigation works between items (dummy content).
- On iPhone: Tabs are visible, navigation works.
- Theme colors change correctly with System Appearance.
