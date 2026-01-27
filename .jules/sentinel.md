## 2024-05-23 - [Integrity Check on Financial Transactions]
**Vulnerability:** The `FinanceService` allowed negative values in `addIncome` and `deductExpense`, enabling logic bugs where expenses could increase balance and income could decrease it.
**Learning:** Even internal services in local games need input validation to prevent state corruption from complex logic elsewhere (like merchandise loss calculation).
**Prevention:** Enforce strict input validation (non-negative) on all financial transaction methods and handle "negative income" as explicit expenses at the call site.

## 2026-01-27 - [Defense-in-Depth for Game State Loading]
**Vulnerability:** Game save files (JSON) were deserialized directly into objects without validation, allowing potential DoS (huge lists) or logic corruption (NaN/Infinity balance) if tampered with.
**Learning:** `json_serializable` handles types but not business logic validation. Sanitizing raw JSON maps *before* deserialization is a clean way to enforce constraints without complex object reconstruction.
**Prevention:** Implement a `validateLoadedState` barrier that sanitizes critical fields (length, range, numeric integrity) before object hydration.
