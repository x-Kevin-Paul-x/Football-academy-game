## 2025-02-18 - Local Save File Integrity
**Vulnerability:** Insecure Deserialization of local save files (`academy_save.json`). The application loaded JSON directly into the game state without validating bounds, types (beyond basic JSON types), or list sizes. This allowed for potential DoS (via huge lists) or logic corruption (via infinite/NaN values).
**Learning:** Local storage is untrusted input. Users (or malware) can modify local files. Treating local save data as trusted internal state is a common oversight in single-player games/apps.
**Prevention:** Implement a strict validation layer (like `validateLoadedState`) that runs immediately after deserialization and before the state is applied to the application logic. Enforce limits on strings, lists, and numeric ranges.
