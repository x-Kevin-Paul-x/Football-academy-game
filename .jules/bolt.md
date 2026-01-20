## 2024-05-23 - [Avoid Defensive Copies in Getters]
**Learning:** `List.unmodifiable` and `Map.unmodifiable` perform a full O(N) copy of the source collection. In Flutter, using these in getters accessed by `build` methods or Consumers causes significant unnecessary allocation and GC pressure.
**Action:** Use `UnmodifiableListView` and `UnmodifiableMapView` from `dart:collection` for O(1) read-only views of internal state.

## 2024-05-24 - [Store Data in Display Order]
**Learning:** Collections displayed in a specific order (e.g., newest-first news feeds) should be stored internally in that matching order to enable O(1) getters and avoid repetitive `.reversed` or sorting operations.
**Action:** When a UI list requires a specific order (like reverse chronological), maintain that order during insertion (e.g., `insert(0, item)`) rather than transforming it on every read. This shifts the cost to the infrequent write operation instead of the frequent read operation.
