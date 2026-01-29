import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/serializable_game_state.dart';
import 'package:football_academy_game/models/difficulty.dart';
import 'package:flutter/material.dart';
import 'package:football_academy_game/models/player.dart';

void main() {
  group('Save/Load Security Tests', () {
    late GameStateManager gameStateManager;

    setUp(() {
      gameStateManager = GameStateManager();
    });

    // Helper to create a valid state with overrides
    SerializableGameState createTestState({
      String? academyName,
      double? balance,
      List<Player>? players,
      int? trainingFacilityLevel,
    }) {
      return SerializableGameState(
        currentDate: DateTime(2025, 1, 1),
        academyName: academyName ?? "Valid Academy",
        academyPlayers: players ?? [],
        hiredStaff: [],
        balance: balance ?? 50000.0,
        weeklyIncome: 1000,
        totalWeeklyWages: 500,
        activeTournaments: [],
        completedTournaments: [],
        trainingFacilityLevel: trainingFacilityLevel ?? 1,
        scoutingFacilityLevel: 1,
        medicalBayLevel: 1,
        academyReputation: 100,
        newsItems: [],
        difficulty: Difficulty.Normal,
        themeMode: ThemeMode.system,
        rivalAcademies: [],
        aiClubs: [],
        playerAcademyTier: 0,
      );
    }

    test('validateLoadedState returns true for valid state', () {
      final state = createTestState();
      expect(gameStateManager.validateLoadedState(state), isTrue);
    });

    test('validateLoadedState returns false for long academy name', () {
      final state = createTestState(academyName: "A" * 26);
      expect(gameStateManager.validateLoadedState(state), isFalse);
    });

    test('validateLoadedState returns false for NaN balance', () {
      final state = createTestState(balance: double.nan);
      expect(gameStateManager.validateLoadedState(state), isFalse);
    });

    test('validateLoadedState returns false for Infinity balance', () {
      final state = createTestState(balance: double.infinity);
      expect(gameStateManager.validateLoadedState(state), isFalse);
    });

    test('validateLoadedState returns false for excessive players', () {
        List<Player> manyPlayers = List.generate(201, (index) => Player(
            id: 'p$index',
            name: 'P$index',
            age: 18,
            naturalPosition: PlayerPosition.Forward,
            potentialSkill: 50,
            weeklyWage: 100,
            preferredPositions: [PlayerPosition.Forward]
        ));
      final state = createTestState(players: manyPlayers);
      expect(gameStateManager.validateLoadedState(state), isFalse);
    });

    test('validateLoadedState returns false for invalid facility level', () {
      final state = createTestState(trainingFacilityLevel: 21);
      expect(gameStateManager.validateLoadedState(state), isFalse);
    });
  });
}
