## 2024-05-23 - Hardcoded Colors vs Theme Agnosticism
**Learning:** Hardcoding colors (e.g. `Colors.grey[800]`) in widgets like `Chip` breaks visual consistency when switching themes (Light/Dark) or migrating to Material 3.
**Action:** Always use `Theme.of(context).colorScheme` (e.g., `surfaceContainerHighest`, `onSurfaceVariant`) to ensure widgets adapt automatically to the active theme.

## 2024-05-23 - Accessibility of Data Visualizations
**Learning:** Visual indicators like `CircularProgressIndicator` are invisible to screen readers without explicit semantics.
**Action:** Wrap data visualizations in `Semantics` (providing `label` and `value`) and `Tooltip` (for long-press/hover discovery) to make them accessible and understandable.
