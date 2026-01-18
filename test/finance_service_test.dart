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
  });
}
