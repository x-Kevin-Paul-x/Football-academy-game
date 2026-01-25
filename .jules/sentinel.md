## 2024-05-23 - [Integrity Check on Financial Transactions]
**Vulnerability:** The `FinanceService` allowed negative values in `addIncome` and `deductExpense`, enabling logic bugs where expenses could increase balance and income could decrease it.
**Learning:** Even internal services in local games need input validation to prevent state corruption from complex logic elsewhere (like merchandise loss calculation).
**Prevention:** Enforce strict input validation (non-negative) on all financial transaction methods and handle "negative income" as explicit expenses at the call site.

## 2025-05-23 - [Finance Service Input Sanitization]
**Vulnerability:** The `FinanceService` methods `addIncome`, `deductExpense`, and `canAfford` were vulnerable to `NaN` (Not-a-Number) and `Infinity` values, which could corrupt the game state (e.g. `NaN < 0` is false, bypassing negative checks). `initialize` also lacked validation.
**Learning:** Checking for `< 0` is insufficient for `double` types in Dart/Flutter. Explicit `.isFinite` checks are required to prevent numerical instability or poisoning from corrupted save data.
**Prevention:** Always validate `double` inputs with `!value.isFinite` before processing financial transactions.
