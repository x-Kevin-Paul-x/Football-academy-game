import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/serializable_game_state.dart';
import 'package:football_academy_game/models/difficulty.dart';
import 'package:football_academy_game/models/player.dart';
import 'package:football_academy_game/models/news_item.dart'; // Added import

void main() {
  group('GameStateManager Security Validation', () {
    late GameStateManager gameStateManager;

    setUp(() {
      gameStateManager = GameStateManager();
    });

    SerializableGameState createValidState({
      String academyName = "My Academy",
      double balance = 50000.0,
      int trainingFacilityLevel = 1,
      int academyPlayersCount = 0,
      int newsItemsCount = 0,
    }) {
      return SerializableGameState(
        currentDate: DateTime(2025, 1, 1),
        academyName: academyName,
        academyPlayers: List.generate(academyPlayersCount, (i) => Player.createWithTargetSkill(
            id: 'p$i', name: 'Player $i', age: 18, naturalPosition: PlayerPosition.Forward,
            targetSkill: 50, potentialSkill: 80, weeklyWage: 100, reputation: 10,
        )),
        hiredStaff: [],
        balance: balance,
        weeklyIncome: 1000,
        totalWeeklyWages: 0,
        activeTournaments: [],
        completedTournaments: [],
        trainingFacilityLevel: trainingFacilityLevel,
        scoutingFacilityLevel: 1,
        medicalBayLevel: 1,
        merchandiseStoreLevel: 0,
        fans: 100,
        academyReputation: 100,
        newsItems: List.generate(newsItemsCount, (i) => NewsItem.create(
          title: 'News $i', description: 'Desc', type: NewsItemType.Generic, date: DateTime.now()
        )),
        difficulty: Difficulty.Normal,
        themeMode: ThemeMode.system,
        rivalAcademies: [],
        aiClubs: [],
        playerAcademyTier: 0,
        consecutiveNegativeWeeks: 0,
        isGameOver: false,
        isForcedSellActive: false,
      );
    }

    test('validateLoadedState accepts valid state', () {
      final state = createValidState();
      expect(gameStateManager.validateLoadedState(state), isTrue);
    });

    test('validateLoadedState accepts names with standard punctuation', () {
      final state = createValidState(academyName: "St. Mary's Academy-West");
      expect(gameStateManager.validateLoadedState(state), isTrue);
    });

    test('validateLoadedState rejects short academy name', () {
      final state = createValidState(academyName: "AB");
      expect(gameStateManager.validateLoadedState(state), isFalse);
    });

    test('validateLoadedState rejects long academy name', () {
      final state = createValidState(academyName: "A" * 26);
      expect(gameStateManager.validateLoadedState(state), isFalse);
    });

    test('validateLoadedState rejects invalid characters in academy name', () {
      final state = createValidState(academyName: "Bad<Script>");
      expect(gameStateManager.validateLoadedState(state), isFalse);
    });

    test('validateLoadedState rejects NaN balance', () {
      final state = createValidState(balance: double.nan);
      expect(gameStateManager.validateLoadedState(state), isFalse);
    });

    test('validateLoadedState rejects Infinite balance', () {
      final state = createValidState(balance: double.infinity);
      expect(gameStateManager.validateLoadedState(state), isFalse);
    });

    test('validateLoadedState rejects excessive players (DoS prevention)', () {
      final state = createValidState(academyPlayersCount: 201);
      expect(gameStateManager.validateLoadedState(state), isFalse);
    });

    test('validateLoadedState rejects excessive news items (DoS prevention)', () {
      final state = createValidState(newsItemsCount: 501);
      expect(gameStateManager.validateLoadedState(state), isFalse);
    });

    test('validateLoadedState rejects invalid facility levels', () {
      final state = createValidState(trainingFacilityLevel: 0);
      expect(gameStateManager.validateLoadedState(state), isFalse);

      final state2 = createValidState(trainingFacilityLevel: 21);
      expect(gameStateManager.validateLoadedState(state2), isFalse);
    });
  });
}
