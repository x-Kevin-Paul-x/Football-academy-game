## 2024-05-23 - [Integrity Check on Financial Transactions]
**Vulnerability:** The `FinanceService` allowed negative values in `addIncome` and `deductExpense`, enabling logic bugs where expenses could increase balance and income could decrease it.
**Learning:** Even internal services in local games need input validation to prevent state corruption from complex logic elsewhere (like merchandise loss calculation).
**Prevention:** Enforce strict input validation (non-negative) on all financial transaction methods and handle "negative income" as explicit expenses at the call site.

## 2025-05-23 - [Input Validation on Local Save Data]
**Vulnerability:** The `loadGame` method blindly trusted deserialized data from `academy_save.json`, allowing potential DoS (via huge lists) and logic corruption (via NaN/Infinity values) if the local file was tampered with.
**Learning:** Local persistence files should be treated as untrusted user input, just like network requests. Deserializers might crash or produce invalid state if not validated.
**Prevention:** Implement a dedicated `_validateSaveData` method that runs immediately after deserialization and checks for data integrity (bounds, types, sanitization) before applying it to the application state.
