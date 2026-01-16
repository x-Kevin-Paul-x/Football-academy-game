## 2024-05-23 - Hardcoded Colors vs Theme Agnosticism
**Learning:** Hardcoding colors (e.g. `Colors.grey[800]`) in widgets like `Chip` breaks visual consistency when switching themes (Light/Dark) or migrating to Material 3.
**Action:** Always use `Theme.of(context).colorScheme` (e.g., `surfaceContainerHighest`, `onSurfaceVariant`) to ensure widgets adapt automatically to the active theme.

**Learning:** Users (even simulated ones!) appreciate knowing what a button does before they click it, especially for "destructive" or "state-changing" actions like advancing time.
**Action:** Always add `Tooltip`s to primary action buttons that perform significant state changes.

## 2024-05-24 - Composite Widget Accessibility
**Learning:** Composite indicators (Stack of CircularProgressIndicator + Text) are read as fragmented nodes by screen readers, confusing users.
**Action:** Wrap composite visual widgets in `Semantics` with `excludeSemantics: true` to provide a single, coherent label and value (e.g., "Skill: 85 out of 100").

## 2024-05-24 - Semantic Empty States
**Learning:** Empty states often lack focus for screen readers. Wrapping the entire empty state container (Icon + Text) in a single `Semantics` widget with a descriptive `label` provides a faster, clearer status update than traversing individual elements.
**Action:** Wrap empty state `Column`s in `Semantics(label: '...', child: ...)` instead of relying on individual text nodes.
