import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/services/finance_service.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/serializable_game_state.dart';
import 'package:football_academy_game/models/difficulty.dart';
import 'package:flutter/material.dart';

void main() {
  group('Security Tests', () {
    test('FinanceService rejects negative wages', () {
      final finance = FinanceService();
      // Expect ArgumentError when initializing with negative wages
      expect(() => finance.initialize(
        balance: 1000,
        weeklyIncome: 0,
        totalWeeklyWages: -500
      ), throwsArgumentError);
    });

    test('FinanceService rejects negative income', () {
        final finance = FinanceService();
        expect(() => finance.initialize(
            balance: 1000,
            weeklyIncome: -100,
            totalWeeklyWages: 0
        ), throwsArgumentError);
    });

    test('FinanceService rejects infinite balance', () {
        final finance = FinanceService();
        expect(() => finance.initialize(
            balance: double.infinity,
            weeklyIncome: 100,
            totalWeeklyWages: 0
        ), throwsArgumentError);
    });

    test('GameStateManager validation rejects invalid state', () {
      final manager = GameStateManager();

      // Helper to create a basic valid state
      SerializableGameState createState({
          double balance = 1000,
          int wages = 0,
          String name = 'Test Academy',
          int training = 1,
      }) {
          return SerializableGameState(
              currentDate: DateTime.now(),
              academyName: name,
              academyPlayers: [],
              hiredStaff: [],
              balance: balance,
              weeklyIncome: 1000,
              totalWeeklyWages: wages,
              activeTournaments: [],
              completedTournaments: [],
              trainingFacilityLevel: training,
              scoutingFacilityLevel: 1,
              medicalBayLevel: 1,
              academyReputation: 100,
              newsItems: [],
              difficulty: Difficulty.Normal,
              themeMode: ThemeMode.system,
              rivalAcademies: [],
              aiClubs: [],
              playerAcademyTier: 1,
          );
      }

      // 1. Negative Wages
      expect(manager.validateLoadedState(createState(wages: -100)), isFalse, reason: "Negative wages should be invalid");

      // 2. Infinite Balance
      expect(manager.validateLoadedState(createState(balance: double.infinity)), isFalse, reason: "Infinite balance should be invalid");

      // 3. Long Name
      expect(manager.validateLoadedState(createState(name: 'A' * 30)), isFalse, reason: "Long name should be invalid");

      // 4. Invalid Facility Level
      expect(manager.validateLoadedState(createState(training: 25)), isFalse, reason: "Invalid facility level should be invalid");

      // 5. Valid State
      expect(manager.validateLoadedState(createState()), isTrue, reason: "Valid state should be accepted");
    });
  });
}
