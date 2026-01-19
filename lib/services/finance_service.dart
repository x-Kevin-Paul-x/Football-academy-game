import 'package:flutter/foundation.dart';
import '../models/difficulty.dart';

enum BankruptcyStatus {
  Safe,
  Warning,
  ForcedSell,
  GameOver,
}

class FinanceService {
  double _balance = 50000.0;
  int _weeklyIncome = 1000;
  int _totalWeeklyWages = 0;
  double _academyMerchStockValue = 0.0;
  static const double _baseMerchUnitCost = 5.0;

  // Bankruptcy Tracking
  int _consecutiveNegativeWeeks = 0;
  static const int _maxNegativeWeeksMedium = 10;

  double get balance => _balance;
  int get weeklyIncome => _weeklyIncome;
  int get totalWeeklyWages => _totalWeeklyWages;
  double get academyMerchStockValue => _academyMerchStockValue;

  // Initialize with optional values (for loading save data)
  void initialize({
    required double balance,
    required int weeklyIncome,
    required int totalWeeklyWages,
    double merchStockValue = 0.0,
    int consecutiveNegativeWeeks = 0,
  }) {
    _balance = balance;
    _weeklyIncome = weeklyIncome;
    _totalWeeklyWages = totalWeeklyWages;
    _academyMerchStockValue = merchStockValue;
    _consecutiveNegativeWeeks = consecutiveNegativeWeeks;
  }

  // Update Wages
  void updateWeeklyWages(int wages) {
    _totalWeeklyWages = wages;
  }

  // Apply Difficulty Settings (Reset)
  void applyDifficultySettings(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.Easy:
        _balance = 75000.0;
        _weeklyIncome = 1200;
        break;
      case Difficulty.Normal:
        _balance = 50000.0;
        _weeklyIncome = 1000;
        break;
      case Difficulty.Hard:
        _balance = 30000.0;
        _weeklyIncome = 800;
        break;
      case Difficulty.Hardcore:
        _balance = 10000.0;
        _weeklyIncome = 600;
        break;
    }
  }

  // Process Weekly Finances
  // Returns net change
  double processWeek() {
    double previousBalance = _balance;
    _balance += _weeklyIncome;
    _balance -= _totalWeeklyWages;

    // Check if balance is negative for tracking
    if (_balance < 0) {
      _consecutiveNegativeWeeks++;
    } else {
      _consecutiveNegativeWeeks = 0; // Reset if back in green
    }

    return _balance - previousBalance;
  }

  // Getter for persistence
  int get consecutiveNegativeWeeks => _consecutiveNegativeWeeks;

  // Check Bankruptcy Status based on Difficulty
  BankruptcyStatus checkBankruptcyStatus(Difficulty difficulty) {
    if (_balance >= 0) return BankruptcyStatus.Safe;

    switch (difficulty) {
      case Difficulty.Easy:
        return BankruptcyStatus.Safe; // No consequences

      case Difficulty.Normal: // Was Medium in user prompt, mapping Normal to Medium logic
        if (_consecutiveNegativeWeeks >= _maxNegativeWeeksMedium) {
          // Game Over after grace period.
          return BankruptcyStatus.GameOver;
        }
        return BankruptcyStatus.Warning; // Warn player about negative streak

      case Difficulty.Hard:
        // Forced Sell immediately if negative
        return BankruptcyStatus.ForcedSell;

      case Difficulty.Hardcore:
        // Game Over immediately if negative
        return BankruptcyStatus.GameOver;
    }
  }

  // Transaction Methods
  void addIncome(double amount) {
    if (!amount.isFinite || amount < 0) {
      throw ArgumentError('Amount must be a non-negative finite number. Use deductExpense for losses.');
    }
    _balance += amount;
  }

  void deductExpense(double amount) {
    if (!amount.isFinite || amount < 0) {
      throw ArgumentError('Amount must be a non-negative finite number. Use addIncome for refunds/gains.');
    }
    _balance -= amount;
  }

  bool canAfford(double amount) {
    if (!amount.isFinite || amount < 0) {
      throw ArgumentError('Amount to check affordability for must be a non-negative finite number.');
    }
    return _balance >= amount;
  }

  // Specific Merch Logic (migrated basic parts, full logic might stay in manager or move to MerchService)
  void updateMerchStock(double valueChange) {
    _academyMerchStockValue += valueChange;
  }
}
