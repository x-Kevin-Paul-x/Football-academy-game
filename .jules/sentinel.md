## 2024-05-23 - [Integrity Check on Financial Transactions]
**Vulnerability:** The `FinanceService` allowed negative values in `addIncome` and `deductExpense`, enabling logic bugs where expenses could increase balance and income could decrease it.
**Learning:** Even internal services in local games need input validation to prevent state corruption from complex logic elsewhere (like merchandise loss calculation).
**Prevention:** Enforce strict input validation (non-negative) on all financial transaction methods and handle "negative income" as explicit expenses at the call site.

## 2024-05-24 - [Insecure Deserialization of Game State]
**Vulnerability:** The `loadGame` method blindly trusted data from the save file (JSON), allowing potentially corrupted or malicious data (Infinite balance, excessive list sizes) to crash the application or cause undefined behavior (DoS).
**Learning:** `SerializableGameState` using `json_annotation` handles types but does not enforce logical constraints or safety bounds. Validation must explicitly occur post-deserialization before state application.
**Prevention:** Implemented a strict `validateLoadedState` method verifying bounds (finite numbers, list length limits, reasonable ranges) before applying the loaded state.
