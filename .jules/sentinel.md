## 2024-05-23 - [Integrity Check on Financial Transactions]
**Vulnerability:** The `FinanceService` allowed negative values in `addIncome` and `deductExpense`, enabling logic bugs where expenses could increase balance and income could decrease it.
**Learning:** Even internal services in local games need input validation to prevent state corruption from complex logic elsewhere (like merchandise loss calculation).
**Prevention:** Enforce strict input validation (non-negative) on all financial transaction methods and handle "negative income" as explicit expenses at the call site.

## 2024-05-24 - [Save File Integrity Validation]
**Vulnerability:** `loadGame` blindly trusted deserialized data from the save file, allowing potentially infinite/NaN balances or massive lists to be loaded into memory.
**Learning:** Deserialization does not equal validation. Type safety in JSON parsing doesn't prevent logical invalidity (e.g. `NaN` is a valid double but invalid game state).
**Prevention:** Implement explicit validation layers (like `validateLoadedState`) immediately after deserialization to enforce business logic constraints (ranges, limits) before applying state.
