## 2024-05-23 - [Avoid Defensive Copies in Getters]
**Learning:** `List.unmodifiable` and `Map.unmodifiable` perform a full O(N) copy of the source collection. In Flutter, using these in getters accessed by `build` methods or Consumers causes significant unnecessary allocation and GC pressure.
**Action:** Use `UnmodifiableListView` and `UnmodifiableMapView` from `dart:collection` for O(1) read-only views of internal state.

## 2024-05-24 - [Store Data in Display Order]
**Learning:** Storing list data in reverse order of its display requirement (e.g., Oldest-First vs Newest-First) forces `O(N)` reversal operations in getters. When combined with `UnmodifiableListView`, this often leads to `List.unmodifiable(list.reversed)` which triggers an unnecessary copy.
**Action:** Store data in the internal list in the exact order required by the primary UI (e.g., Newest-First using `insert(0, item)`). This enables `O(1)` getters via `UnmodifiableListView`.
