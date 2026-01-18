## 2024-05-23 - [Avoid Defensive Copies in Getters]
**Learning:** `List.unmodifiable` and `Map.unmodifiable` perform a full O(N) copy of the source collection. In Flutter, using these in getters accessed by `build` methods or Consumers causes significant unnecessary allocation and GC pressure.
**Action:** Use `UnmodifiableListView` and `UnmodifiableMapView` from `dart:collection` for O(1) read-only views of internal state.

## 2024-05-24 - [Store Data in Presentation Order]
**Learning:** Storing data in reverse order of how it is presented (e.g. oldest-first when UI needs newest-first) forces getters to perform O(N) reversals or copies on every access.
**Action:** Store data in the order it is most frequently accessed (e.g. newest-first for news feeds) to allow O(1) getters using `UnmodifiableListView`.
