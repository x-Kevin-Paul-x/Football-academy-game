## 2024-05-23 - [Avoid Defensive Copies in Getters]
**Learning:** `List.unmodifiable` and `Map.unmodifiable` perform a full O(N) copy of the source collection. In Flutter, using these in getters accessed by `build` methods or Consumers causes significant unnecessary allocation and GC pressure.
**Action:** Use `UnmodifiableListView` and `UnmodifiableMapView` from `dart:collection` for O(1) read-only views of internal state.

## 2024-05-24 - [Shift O(N) Operations to Write Path]
**Learning:** For collections accessed frequently by the UI (read-heavy), avoid O(N) transformations like `.reversed` in getters. Instead, maintain the collection in the desired presentation order (e.g., newest-first) during insertion (write path).
**Action:** Use `insert(0, item)` for chronological lists displayed in reverse order, ensuring the getter remains O(1).
