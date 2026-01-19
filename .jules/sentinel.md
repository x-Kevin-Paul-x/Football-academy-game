## 2024-05-23 - [Integrity Check on Financial Transactions]
**Vulnerability:** The `FinanceService` allowed negative values in `addIncome` and `deductExpense`, enabling logic bugs where expenses could increase balance and income could decrease it.
**Learning:** Even internal services in local games need input validation to prevent state corruption from complex logic elsewhere (like merchandise loss calculation).
**Prevention:** Enforce strict input validation (non-negative) on all financial transaction methods and handle "negative income" as explicit expenses at the call site.

## 2025-05-24 - [Finite Number Validation in Finance]
**Vulnerability:** `FinanceService` arithmetic operations were vulnerable to `NaN` and `Infinity` propagation, potentially corrupting the game state permanently if a calculation elsewhere failed.
**Learning:** `double` types in Dart (and many languages) do not throw on `NaN` or `Infinity`, silently allowing invalid states to persist.
**Prevention:** Explicitly check `.isFinite` for all numeric inputs in critical state management services, especially those handling "currency".
