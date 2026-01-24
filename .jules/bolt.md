## 2024-05-23 - [Avoid Defensive Copies in Getters]
**Learning:** `List.unmodifiable` and `Map.unmodifiable` perform a full O(N) copy of the source collection. In Flutter, using these in getters accessed by `build` methods or Consumers causes significant unnecessary allocation and GC pressure.
**Action:** Use `UnmodifiableListView` and `UnmodifiableMapView` from `dart:collection` for O(1) read-only views of internal state.

## 2024-05-22 - Optimize Getter Performance for Reversed Lists
**Learning:** Flutter's `List.unmodifiable` constructor iterates and copies the entire iterable. When used with `.reversed` in a getter (e.g., `List.unmodifiable(_list.reversed)`), it creates an O(N) allocation on every access. For frequently accessed UI state getters, this adds significant overhead.
**Action:** Store the list internally in the desired presentation order (Newest-First) so the getter can simply return `UnmodifiableListView(_list)`, which is O(1). Handle the "add" cost (O(N) insert) at the write source, which is typically much less frequent than the read source.
