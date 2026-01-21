## 2024-05-23 - [Integrity Check on Financial Transactions]
**Vulnerability:** The `FinanceService` allowed negative values in `addIncome` and `deductExpense`, enabling logic bugs where expenses could increase balance and income could decrease it.
**Learning:** Even internal services in local games need input validation to prevent state corruption from complex logic elsewhere (like merchandise loss calculation).
**Prevention:** Enforce strict input validation (non-negative) on all financial transaction methods and handle "negative income" as explicit expenses at the call site.

## 2024-05-24 - [DoS Prevention in Save File Loading]
**Vulnerability:** The game blindly loaded unlimited lists from save files, which could cause Out-Of-Memory crashes if a save file was corrupted or maliciously tampered with (e.g., millions of players).
**Learning:** Even in local games, deserialization of "untrusted" (user-modifiable) files needs bounds checking to ensure application stability and prevent resource exhaustion.
**Prevention:** Implemented a validation step (`validateSaveData`) immediately after JSON decoding to enforce reasonable maximum limits on collection sizes before object instantiation.
