## 2024-05-23 - [Integrity Check on Financial Transactions]
**Vulnerability:** The `FinanceService` allowed negative values in `addIncome` and `deductExpense`, enabling logic bugs where expenses could increase balance and income could decrease it.
**Learning:** Even internal services in local games need input validation to prevent state corruption from complex logic elsewhere (like merchandise loss calculation).
**Prevention:** Enforce strict input validation (non-negative) on all financial transaction methods and handle "negative income" as explicit expenses at the call site.

## 2025-05-27 - [Secure Input Implementation for New Game]
**Vulnerability:** The lack of user input for "Academy Name" forced a hardcoded value, but adding it without validation would have introduced injection risks.
**Learning:** Security enhancements often overlap with feature completion. Implementing a missing feature is the perfect time to establish "Secure by Default" patterns (e.g., allow-lists for characters).
**Prevention:** When introducing new text inputs, immediately apply strict validation rules (e.g., alphanumeric only, length limits) in both the UI and the State Manager layer.
