## 2024-05-23 - [Integrity Check on Financial Transactions]
**Vulnerability:** The `FinanceService` allowed negative values in `addIncome` and `deductExpense`, enabling logic bugs where expenses could increase balance and income could decrease it.
**Learning:** Even internal services in local games need input validation to prevent state corruption from complex logic elsewhere (like merchandise loss calculation).
**Prevention:** Enforce strict input validation (non-negative) on all financial transaction methods and handle "negative income" as explicit expenses at the call site.

## 2024-05-24 - [Input Validation on Game Load]
**Vulnerability:** The `loadGame` process deserialized JSON directly into the application state without validating constraints (e.g., NaN balance, impossible facility levels, excessive string lengths). This could lead to crashes, DoS (memory exhaustion), or corrupted game state.
**Learning:** `json_serializable` handles type safety but not business logic constraints. Deserialized data from files must be treated as untrusted user input.
**Prevention:** Implemented a `validateLoadedState` method in `GameStateManager` that runs immediately after deserialization and aborts the load if data integrity checks fail.
