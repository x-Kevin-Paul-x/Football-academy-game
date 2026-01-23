## 2024-05-23 - [Avoid Defensive Copies in Getters]
**Learning:** `List.unmodifiable` and `Map.unmodifiable` perform a full O(N) copy of the source collection. In Flutter, using these in getters accessed by `build` methods or Consumers causes significant unnecessary allocation and GC pressure.
**Action:** Use `UnmodifiableListView` and `UnmodifiableMapView` from `dart:collection` for O(1) read-only views of internal state.

## 2025-05-24 - [Store Data in Display Order]
**Learning:** If a collection is frequently displayed in a specific order (e.g., newest first), store it in that order internally. Using `.reversed` or sorting in the getter creates a new Iterable/List on every access, defeating the purpose of O(1) views like `UnmodifiableListView`.
**Action:** Invert storage logic (e.g., `insert(0, item)` vs `add(item)`) to match UI needs, ensuring getters remain O(1).
