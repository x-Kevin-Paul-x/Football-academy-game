## 2024-05-23 - [Integrity Check on Financial Transactions]
**Vulnerability:** The `FinanceService` allowed negative values in `addIncome` and `deductExpense`, enabling logic bugs where expenses could increase balance and income could decrease it.
**Learning:** Even internal services in local games need input validation to prevent state corruption from complex logic elsewhere (like merchandise loss calculation).
**Prevention:** Enforce strict input validation (non-negative) on all financial transaction methods and handle "negative income" as explicit expenses at the call site.

## 2025-05-24 - [Validate Deserialized Game State]
**Vulnerability:** `loadGame` blindly trusted deserialized JSON data, allowing invalid states (e.g., `NaN` balance, infinite values) or massive list sizes (DoS risk) to be loaded into memory.
**Learning:** Local save files are a form of user input and can be corrupted or tampered with. Trusting them without validation compromises application stability and integrity.
**Prevention:** Implement a strict validation layer (`validateLoadedState`) immediately after deserialization to enforce business rules (bounds, lengths, sanity checks) before applying the state to the application.
