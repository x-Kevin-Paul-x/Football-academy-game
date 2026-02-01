## 2024-05-23 - [Avoid Defensive Copies in Getters]
**Learning:** `List.unmodifiable` and `Map.unmodifiable` perform a full O(N) copy of the source collection. In Flutter, using these in getters accessed by `build` methods or Consumers causes significant unnecessary allocation and GC pressure.
**Action:** Use `UnmodifiableListView` and `UnmodifiableMapView` from `dart:collection` for O(1) read-only views of internal state.

## 2025-05-27 - [Optimize NewsItems Getter]
**Learning:** Returning `List.unmodifiable(list.reversed)` in a getter is expensive O(N) because it iterates and copies on every access.
**Action:** Inverted storage order to newest-first (using `insert(0, item)`) and switched getter to `UnmodifiableListView(list)` for O(1) access. Sorted by date in `loadGame` to handle legacy saves. Reduced getter time by ~96%.
