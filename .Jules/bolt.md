# Bolt's Journal

## 2024-05-22 - [Initial Setup]
**Learning:** The journal file was missing.
**Action:** Created the journal to track performance learnings.

## 2024-05-22 - [Flutter TabBarView Optimization]
**Learning:** In Flutter, `TabBarView(children: [...])` evaluates its children list immediately. If the children are created via helper methods (e.g., `_buildList()`) that perform expensive logic (sorting, filtering) *before* returning the Widget, that logic runs for *all* tabs on every parent rebuild, even if tabs are hidden.
**Action:** Always refactor complex tab children into separate `StatelessWidget` or `StatefulWidget` classes. This ensures `build()` (and the expensive logic inside it) is only called when `TabBarView` actually needs to render that specific tab (lazy loading). Scoping `Consumer` inside these child widgets further isolates rebuilds.
