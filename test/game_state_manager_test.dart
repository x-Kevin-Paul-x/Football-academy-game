import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/serializable_game_state.dart';
import 'package:football_academy_game/models/difficulty.dart';
import 'package:football_academy_game/models/player.dart';
import 'package:flutter/material.dart';

void main() {
  group('GameStateManager Integrity Tests', () {
    late GameStateManager gameStateManager;

    setUp(() {
      gameStateManager = GameStateManager();
    });

    SerializableGameState createValidState({
      double balance = 1000.0,
      String academyName = "Valid Name",
      List<Player>? players,
    }) {
      return SerializableGameState(
        currentDate: DateTime(2025, 1, 1),
        academyName: academyName,
        academyPlayers: players ?? [],
        hiredStaff: [],
        balance: balance,
        weeklyIncome: 500,
        totalWeeklyWages: 200,
        activeTournaments: [],
        completedTournaments: [],
        trainingFacilityLevel: 1,
        scoutingFacilityLevel: 1,
        medicalBayLevel: 1,
        academyReputation: 100,
        newsItems: [],
        difficulty: Difficulty.Normal,
        themeMode: ThemeMode.system,
        rivalAcademies: [],
        aiClubs: [],
        playerAcademyTier: 3,
      );
    }

    test('validateLoadedState accepts valid state', () {
      final state = createValidState();
      expect(() => gameStateManager.validateLoadedState(state), returnsNormally);
    });

    test('validateLoadedState throws on NaN balance', () {
      final state = createValidState(balance: double.nan);
      expect(
        () => gameStateManager.validateLoadedState(state),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('Integrity Error: Balance is invalid'))),
      );
    });

    test('validateLoadedState throws on Infinity balance', () {
      final state = createValidState(balance: double.infinity);
      expect(
        () => gameStateManager.validateLoadedState(state),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('Integrity Error: Balance is invalid'))),
      );
    });

    test('validateLoadedState throws on excessive academy name length', () {
      final longName = 'A' * 26; // 26 chars
      final state = createValidState(academyName: longName);
      expect(
        () => gameStateManager.validateLoadedState(state),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('Integrity Error: Academy Name is too long'))),
      );
    });

    test('validateLoadedState throws on excessive player list size', () {
      final players = List.generate(201, (index) => Player.createWithTargetSkill(
        id: 'p$index',
        name: 'Player $index',
        age: 18,
        naturalPosition: PlayerPosition.Forward,
        targetSkill: 50,
        potentialSkill: 80,
        weeklyWage: 100,
        reputation: 10,
      ));
      final state = createValidState(players: players);
      expect(
        () => gameStateManager.validateLoadedState(state),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('Integrity Error: Player list is excessively large'))),
      );
    });
  });
}
