## 2024-05-23 - [Avoid Defensive Copies in Getters]
**Learning:** `List.unmodifiable` and `Map.unmodifiable` perform a full O(N) copy of the source collection. In Flutter, using these in getters accessed by `build` methods or Consumers causes significant unnecessary allocation and GC pressure.
**Action:** Use `UnmodifiableListView` and `UnmodifiableMapView` from `dart:collection` for O(1) read-only views of internal state.

## 2024-05-24 - [UnmodifiableListView vs List.unmodifiable]
**Learning:** `List.unmodifiable(list.reversed)` creates an intermediate iterable and then a new list copy (O(N)), which is disastrous in a high-frequency Flutter getter. `UnmodifiableListView(list)` wraps the list in O(1).
**Action:** When order matters for display, store the data in the display order internally if possible (e.g. insert at 0), or use a specialized view that doesn't copy, rather than reversing and copying on every read.
