## 2024-05-23 - [Integrity Check on Financial Transactions]
**Vulnerability:** The `FinanceService` allowed negative values in `addIncome` and `deductExpense`, enabling logic bugs where expenses could increase balance and income could decrease it.
**Learning:** Even internal services in local games need input validation to prevent state corruption from complex logic elsewhere (like merchandise loss calculation).
**Prevention:** Enforce strict input validation (non-negative) on all financial transaction methods and handle "negative income" as explicit expenses at the call site.

## 2024-05-24 - [Save File Integrity]
**Vulnerability:** Game save files were plain JSON without any integrity verification, allowing trivial tampering and risking crashes from disk corruption.
**Learning:** "Security through obscurity" (like a salted hash in a local app) is a valid layer of defense against casual tampering and corruption, even if not cryptographically secure against determined attackers with reverse engineering tools.
**Prevention:** Wrap persisted data with a generated checksum (HMAC or salted hash) and enforce verification on load, while maintaining backward compatibility for legacy data.
