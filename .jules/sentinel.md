## 2024-05-23 - [Integrity Check on Financial Transactions]
**Vulnerability:** The `FinanceService` allowed negative values in `addIncome` and `deductExpense`, enabling logic bugs where expenses could increase balance and income could decrease it.
**Learning:** Even internal services in local games need input validation to prevent state corruption from complex logic elsewhere (like merchandise loss calculation).
**Prevention:** Enforce strict input validation (non-negative) on all financial transaction methods and handle "negative income" as explicit expenses at the call site.

## 2025-05-26 - [Integrity of Loaded Game State]
**Vulnerability:** The `GameStateManager` and `FinanceService` accepted corrupted save data (e.g., negative wages, infinite balance) without validation, leading to potential game state corruption or crashes.
**Learning:** `json_serializable` only handles structural validation. Semantic validation of loaded data is crucial, especially for save files that can be modified by users.
**Prevention:** Implement a dedicated validation step (`validateLoadedState`) immediately after deserialization to check boundaries and logical consistency before applying the state.
