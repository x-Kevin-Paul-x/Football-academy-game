import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/services/finance_service.dart';

void main() {
  test('FinanceService.initialize validates inputs', () {
    final service = FinanceService();

    // Check validation for Balance
    expect(() => service.initialize(
      balance: double.nan,
      weeklyIncome: 1000,
      totalWeeklyWages: 500
    ), throwsArgumentError);

    expect(() => service.initialize(
      balance: double.infinity,
      weeklyIncome: 1000,
      totalWeeklyWages: 500
    ), throwsArgumentError);

    // Check validation for Weekly Income
    expect(() => service.initialize(
      balance: 1000.0,
      weeklyIncome: -100,
      totalWeeklyWages: 500
    ), throwsArgumentError);

    // Check validation for Wages
    expect(() => service.initialize(
      balance: 1000.0,
      weeklyIncome: 1000,
      totalWeeklyWages: -500
    ), throwsArgumentError);

    // Check validation for Merch Stock
    expect(() => service.initialize(
      balance: 1000.0,
      weeklyIncome: 1000,
      totalWeeklyWages: 500,
      merchStockValue: -10.0
    ), throwsArgumentError);

    // Check validation for Consecutive Negative Weeks
    expect(() => service.initialize(
      balance: 1000.0,
      weeklyIncome: 1000,
      totalWeeklyWages: 500,
      consecutiveNegativeWeeks: -1
    ), throwsArgumentError);

    // Verify valid input works
    service.initialize(
      balance: 50000.0,
      weeklyIncome: 1000,
      totalWeeklyWages: 500
    );
    expect(service.balance, 50000.0);
  });
}
