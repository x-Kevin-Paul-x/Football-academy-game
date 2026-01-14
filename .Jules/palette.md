## 2024-05-23 - Micro-interactions matter

**Learning:** Users (even simulated ones!) appreciate knowing what a button does before they click it, especially for "destructive" or "state-changing" actions like advancing time.
**Action:** Always add `Tooltip`s to primary action buttons that perform significant state changes.

## 2024-05-24 - Composite Widget Accessibility
**Learning:** Composite indicators (Stack of CircularProgressIndicator + Text) are read as fragmented nodes by screen readers, confusing users.
**Action:** Wrap composite visual widgets in `Semantics` with `excludeSemantics: true` to provide a single, coherent label and value (e.g., "Skill: 85 out of 100").
