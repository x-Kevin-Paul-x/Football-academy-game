## 2024-05-23 - Hardcoded Colors vs Theme Agnosticism
**Learning:** Hardcoding colors (e.g. `Colors.grey[800]`) in widgets like `Chip` breaks visual consistency when switching themes (Light/Dark) or migrating to Material 3.
**Action:** Always use `Theme.of(context).colorScheme` (e.g., `surfaceContainerHighest`, `onSurfaceVariant`) to ensure widgets adapt automatically to the active theme.

**Learning:** Users (even simulated ones!) appreciate knowing what a button does before they click it, especially for "destructive" or "state-changing" actions like advancing time.
**Action:** Always add `Tooltip`s to primary action buttons that perform significant state changes.

## 2024-05-24 - Composite Widget Accessibility
**Learning:** Composite indicators (Stack of CircularProgressIndicator + Text) are read as fragmented nodes by screen readers, confusing users.
**Action:** Wrap composite visual widgets in `Semantics` with `excludeSemantics: true` to provide a single, coherent label and value (e.g., "Skill: 85 out of 100").

## 2024-05-25 - Tooltips on Disabled Buttons
**Learning:** Placing a `Tooltip` inside a disabled button (wrapping the child text) prevents the tooltip from appearing because the disabled button consumes or blocks hit testing.
**Action:** Always wrap the *entire* button widget (e.g., `ElevatedButton`) with the `Tooltip` widget to ensure the message is accessible even when the button is disabled.
 
 ## 2024-05-25 - Empty State Consistency
**Learning:** Fragmented empty states (e.g., bare `Text` vs ad-hoc `Column`s) lead to inconsistent user experience and missing accessibility context.
**Action:** Use the shared `EmptyState` widget which wraps content in a single `Semantics` container and uses `Theme` colors (Outline for icon, OnSurfaceVariant for text).
