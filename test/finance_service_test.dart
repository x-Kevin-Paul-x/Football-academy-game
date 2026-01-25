import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/services/finance_service.dart';

void main() {
  group('FinanceService Security Tests', () {
    late FinanceService financeService;

    setUp(() {
      financeService = FinanceService();
      // Reset to known state if needed, though constructor sets defaults
      financeService.initialize(
        balance: 50000.0,
        weeklyIncome: 1000,
        totalWeeklyWages: 0,
      );
    });

    test('addIncome should throw ArgumentError for negative amounts', () {
      expect(() => financeService.addIncome(-100), throwsArgumentError);
    });

    test('deductExpense should throw ArgumentError for negative amounts', () {
      expect(() => financeService.deductExpense(-100), throwsArgumentError);
    });

    test('canAfford should throw ArgumentError for negative amounts', () {
      expect(() => financeService.canAfford(-100), throwsArgumentError);
    });

    test('addIncome should work for positive amounts', () {
      double initialBalance = financeService.balance;
      financeService.addIncome(100);
      expect(financeService.balance, initialBalance + 100);
    });

    test('deductExpense should work for positive amounts', () {
      double initialBalance = financeService.balance;
      financeService.deductExpense(100);
      expect(financeService.balance, initialBalance - 100);
    });

    // NaN and Infinity Tests

    test('initialize should throw ArgumentError if balance is NaN', () {
      expect(
        () => financeService.initialize(
          balance: double.nan,
          weeklyIncome: 1000,
          totalWeeklyWages: 0,
        ),
        throwsArgumentError,
      );
    });

    test('initialize should throw ArgumentError if balance is Infinity', () {
      expect(
        () => financeService.initialize(
          balance: double.infinity,
          weeklyIncome: 1000,
          totalWeeklyWages: 0,
        ),
        throwsArgumentError,
      );
    });

    test('initialize should throw ArgumentError if merchStockValue is NaN', () {
      expect(
        () => financeService.initialize(
          balance: 50000.0,
          weeklyIncome: 1000,
          totalWeeklyWages: 0,
          merchStockValue: double.nan,
        ),
        throwsArgumentError,
      );
    });

    test('addIncome should throw ArgumentError if amount is NaN', () {
      expect(() => financeService.addIncome(double.nan), throwsArgumentError);
    });

    test('addIncome should throw ArgumentError if amount is Infinity', () {
      expect(() => financeService.addIncome(double.infinity), throwsArgumentError);
    });

    test('deductExpense should throw ArgumentError if amount is NaN', () {
      expect(() => financeService.deductExpense(double.nan), throwsArgumentError);
    });

    test('deductExpense should throw ArgumentError if amount is Infinity', () {
      expect(() => financeService.deductExpense(double.infinity), throwsArgumentError);
    });

    test('canAfford should throw ArgumentError if amount is NaN', () {
      expect(() => financeService.canAfford(double.nan), throwsArgumentError);
    });

    test('canAfford should throw ArgumentError if amount is Infinity', () {
      expect(() => financeService.canAfford(double.infinity), throwsArgumentError);
    });
  });
}
