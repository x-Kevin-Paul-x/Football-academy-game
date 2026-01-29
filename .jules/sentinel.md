## 2024-05-23 - [Integrity Check on Financial Transactions]
**Vulnerability:** The `FinanceService` allowed negative values in `addIncome` and `deductExpense`, enabling logic bugs where expenses could increase balance and income could decrease it.
**Learning:** Even internal services in local games need input validation to prevent state corruption from complex logic elsewhere (like merchandise loss calculation).
**Prevention:** Enforce strict input validation (non-negative) on all financial transaction methods and handle "negative income" as explicit expenses at the call site.

## 2025-02-18 - [Missing Save Game Validation]
**Vulnerability:** `GameStateManager.loadGame` lacked input validation for loaded data, despite documentation suggesting it existed. This could allow malicious save files to cause DoS (e.g., massive lists) or state corruption (NaN balance).
**Learning:** Security controls mentioned in documentation or memory must be verified in the actual codebase ("ghost features"). Trust code, not docs.
**Prevention:** Implemented `validateLoadedState` with strict bounds checking and added a regression test to ensure it remains active.
