## 2024-05-23 - [Avoid Defensive Copies in Getters]
**Learning:** `List.unmodifiable` and `Map.unmodifiable` perform a full O(N) copy of the source collection. In Flutter, using these in getters accessed by `build` methods or Consumers causes significant unnecessary allocation and GC pressure.
**Action:** Use `UnmodifiableListView` and `UnmodifiableMapView` from `dart:collection` for O(1) read-only views of internal state.

## 2024-05-24 - [Align Internal Storage with Display Order]
**Learning:** Storing collections in the opposite order of display forces O(N) operations (e.g., `.reversed`) in getters, which are often called frequently during build.
**Action:** Store data internally in the order it will be displayed (e.g., insert newest items at index 0 for a news feed) to allow O(1) getters. Ensure backward compatibility in `loadGame` by explicitly sorting.
