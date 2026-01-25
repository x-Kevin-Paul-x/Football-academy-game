## 2024-05-23 - [Avoid Defensive Copies in Getters]
**Learning:** `List.unmodifiable` and `Map.unmodifiable` perform a full O(N) copy of the source collection. In Flutter, using these in getters accessed by `build` methods or Consumers causes significant unnecessary allocation and GC pressure.
**Action:** Use `UnmodifiableListView` and `UnmodifiableMapView` from `dart:collection` for O(1) read-only views of internal state.

## 2024-05-24 - [Optimize Read-Heavy FIFO Queues]
**Learning:** For collections accessed frequently by the UI in a specific order (e.g., newest-first News Feed), store the data internally in that same order. This enables O(1) getters using `UnmodifiableListView` instead of O(N) reversals and defensive copies on every frame.
**Action:** When adding to such lists, use `insert(0, item)` and `removeLast()`. Ensure `loadGame` sorts data to handle legacy save file migration.
