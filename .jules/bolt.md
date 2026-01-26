## 2024-05-23 - [Avoid Defensive Copies in Getters]
**Learning:** `List.unmodifiable` and `Map.unmodifiable` perform a full O(N) copy of the source collection. In Flutter, using these in getters accessed by `build` methods or Consumers causes significant unnecessary allocation and GC pressure.
**Action:** Use `UnmodifiableListView` and `UnmodifiableMapView` from `dart:collection` for O(1) read-only views of internal state.
## 2025-05-22 - Optimizing Relationship Lookups
**Learning:** In Flutter apps with complex state (like ), recurring lookups (e.g., finding a coach for a player) inside  methods (specifically ) can become performance bottlenecks if they involve O(N*M) iteration.
**Action:** Implement cached Maps (e.g., `_playerCoachMap`) for O(1) lookups and ensure they are synchronized with state changes (CRUD operations, load/reset).
## 2025-05-22 - Optimizing Relationship Lookups
**Learning:** In Flutter apps with complex state (like GameStateManager), recurring lookups (e.g., finding a coach for a player) inside build methods (specifically ListView.builder) can become performance bottlenecks if they involve O(N*M) iteration.
**Action:** Implement cached Maps (e.g., _playerCoachMap) for O(1) lookups and ensure they are synchronized with state changes (CRUD operations, load/reset).
