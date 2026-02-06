import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/serializable_game_state.dart';
import 'package:football_academy_game/models/difficulty.dart';
import 'package:football_academy_game/models/player.dart';
import 'package:football_academy_game/models/staff.dart';
import 'package:football_academy_game/models/tournament.dart';
import 'package:football_academy_game/models/news_item.dart';
import 'package:football_academy_game/models/rival_academy.dart';
import 'package:football_academy_game/models/ai_club.dart';

void main() {
  group('GameState Validation', () {
    late GameStateManager gameStateManager;

    setUp(() {
      gameStateManager = GameStateManager();
    });

    SerializableGameState createValidState({
      double? balance,
      String? academyName,
      List<Player>? academyPlayers,
      List<NewsItem>? newsItems,
      int? trainingFacilityLevel,
      List<RivalAcademy>? rivalAcademies,
      List<AIClub>? aiClubs,
    }) {
      return SerializableGameState(
        currentDate: DateTime(2025, 1, 1),
        academyName: academyName ?? "Test Academy",
        academyPlayers: academyPlayers ?? [],
        hiredStaff: [],
        balance: balance ?? 50000.0,
        weeklyIncome: 1000,
        totalWeeklyWages: 0,
        activeTournaments: [],
        completedTournaments: [],
        trainingFacilityLevel: trainingFacilityLevel ?? 1,
        scoutingFacilityLevel: 1,
        medicalBayLevel: 1,
        merchandiseStoreLevel: 0,
        fans: 100,
        academyReputation: 100,
        newsItems: newsItems ?? [],
        difficulty: Difficulty.Normal,
        themeMode: ThemeMode.system,
        rivalAcademies: rivalAcademies ?? [],
        aiClubs: aiClubs ?? [],
        playerAcademyTier: 0,
      );
    }

    test('valid state passes validation', () {
      final state = createValidState();
      // Should not throw
      gameStateManager.validateLoadedState(state);
    });

    test('throws on infinite balance', () {
      final state = createValidState(balance: double.infinity);
      expect(() => gameStateManager.validateLoadedState(state), throwsFormatException);
    });

    test('throws on NaN balance', () {
      final state = createValidState(balance: double.nan);
      expect(() => gameStateManager.validateLoadedState(state), throwsFormatException);
    });

    test('throws on overly long academy name', () {
      final state = createValidState(academyName: 'A' * 51); // Max 25 or 50? Let's assume 25 for strictness
      expect(() => gameStateManager.validateLoadedState(state), throwsFormatException);
    });

    test('throws on excessive players', () {
      // Create a dummy player
      final player = Player.createWithTargetSkill(
          id: 'p1', name: 'Test', age: 16, naturalPosition: PlayerPosition.Forward, targetSkill: 50, potentialSkill: 80, weeklyWage: 100, reputation: 10);

      final state = createValidState(academyPlayers: List.generate(201, (_) => player)); // Limit 200
      expect(() => gameStateManager.validateLoadedState(state), throwsFormatException);
    });

    test('throws on excessive news items', () {
      final news = NewsItem.create(title: 'T', description: 'D', type: NewsItemType.Generic, date: DateTime.now());
      final state = createValidState(newsItems: List.generate(501, (_) => news)); // Limit 500
      expect(() => gameStateManager.validateLoadedState(state), throwsFormatException);
    });

    test('throws on invalid facility level', () {
      final state = createValidState(trainingFacilityLevel: 0); // Must be >= 1
      expect(() => gameStateManager.validateLoadedState(state), throwsFormatException);

      final state2 = createValidState(trainingFacilityLevel: 21); // Must be <= 20
      expect(() => gameStateManager.validateLoadedState(state2), throwsFormatException);
    });
  });
}
