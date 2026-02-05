## 2024-05-23 - [Integrity Check on Financial Transactions]
**Vulnerability:** The `FinanceService` allowed negative values in `addIncome` and `deductExpense`, enabling logic bugs where expenses could increase balance and income could decrease it.
**Learning:** Even internal services in local games need input validation to prevent state corruption from complex logic elsewhere (like merchandise loss calculation).
**Prevention:** Enforce strict input validation (non-negative) on all financial transaction methods and handle "negative income" as explicit expenses at the call site.

## 2025-05-23 - [Input Validation for FinanceService Initialization]
**Vulnerability:** `FinanceService.initialize` accepted invalid values (NaN balance, negative wages) from save data, allowing state corruption, infinite money glitches (negative wages increasing balance), and potential application instability.
**Learning:** Implicit trust in deserialized data, even from "local" save files, is a security vulnerability. Critical state initialization methods must strictly validate inputs regardless of the trusted nature of the caller.
**Prevention:** Added strict input validation to `FinanceService.initialize` to enforce finite numbers for balance and non-negative values for wages, income, and merchandise stock, throwing `ArgumentError` if violated.
