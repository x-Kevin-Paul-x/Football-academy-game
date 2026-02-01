## 2025-05-23 - Disabled State Feedback
**Learning:** Users often get frustrated by disabled buttons without knowing *why* they are disabled. Adding a `Tooltip` wrapper around a disabled button (e.g., `ElevatedButton` with `onPressed: null`) allows interaction (hover/long-press) to reveal the reason (e.g., "Insufficient funds").
**Action:** Always wrap disabled action buttons in a `Tooltip` that conditionally explains the requirement or the action.
