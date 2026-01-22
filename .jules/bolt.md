## 2024-05-23 - [Avoid Defensive Copies in Getters]
**Learning:** `List.unmodifiable` and `Map.unmodifiable` perform a full O(N) copy of the source collection. In Flutter, using these in getters accessed by `build` methods or Consumers causes significant unnecessary allocation and GC pressure.
**Action:** Use `UnmodifiableListView` and `UnmodifiableMapView` from `dart:collection` for O(1) read-only views of internal state.

## 2025-05-27 - [Store Data in Display Order]
**Learning:** Storing chronological data (like news feeds) in "Oldest First" order requires `list.reversed` and often a copy to display "Newest First" (common UI pattern). This forces O(N) operations in the hot path (UI rendering).
**Action:** Store the data internally in the expected display order (e.g., prepend new items with `insert(0)`) to allow O(1) getters, shifting the cost to the write operation (which is much less frequent than read).
