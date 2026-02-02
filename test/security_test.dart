import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/serializable_game_state.dart';
import 'package:football_academy_game/models/difficulty.dart';
import 'package:football_academy_game/models/news_item.dart';

void main() {
  group('Security Tests - Game State Validation', () {
    late GameStateManager gameStateManager;

    setUp(() {
      gameStateManager = GameStateManager();
    });

    SerializableGameState createValidState({
      double balance = 1000.0,
      String academyName = 'Test Academy',
      int totalWeeklyWages = 50,
      int trainingFacilityLevel = 1,
      List<NewsItem>? newsItems,
    }) {
      return SerializableGameState(
        currentDate: DateTime.now(),
        academyName: academyName,
        academyPlayers: [],
        hiredStaff: [],
        balance: balance,
        weeklyIncome: 100,
        totalWeeklyWages: totalWeeklyWages,
        activeTournaments: [],
        completedTournaments: [],
        trainingFacilityLevel: trainingFacilityLevel,
        scoutingFacilityLevel: 1,
        medicalBayLevel: 1,
        merchandiseStoreLevel: 0,
        fans: 100,
        academyReputation: 100,
        newsItems: newsItems ?? [],
        difficulty: Difficulty.Normal,
        themeMode: ThemeMode.system,
        rivalAcademies: [],
        aiClubs: [],
        playerAcademyTier: 0,
      );
    }

    test('validateLoadedState accepts valid state', () {
      final state = createValidState();
      expect(() => gameStateManager.validateLoadedState(state), returnsNormally);
    });

    test('validateLoadedState throws on infinite balance', () {
      final invalidState = createValidState(balance: double.infinity);
      expect(() => gameStateManager.validateLoadedState(invalidState), throwsFormatException);
    });

    test('validateLoadedState throws on NaN balance', () {
      final invalidState = createValidState(balance: double.nan);
      expect(() => gameStateManager.validateLoadedState(invalidState), throwsFormatException);
    });

    test('validateLoadedState throws on negative wages', () {
      final invalidState = createValidState(totalWeeklyWages: -100);
      expect(() => gameStateManager.validateLoadedState(invalidState), throwsFormatException);
    });

    test('validateLoadedState throws on invalid academy name length', () {
      final invalidState = createValidState(academyName: 'A' * 26); // 26 chars
      expect(() => gameStateManager.validateLoadedState(invalidState), throwsFormatException);
    });

    test('validateLoadedState throws on invalid academy name characters', () {
        final invalidState = createValidState(academyName: 'Bad <script> Name');
        expect(() => gameStateManager.validateLoadedState(invalidState), throwsFormatException);
    });

    test('validateLoadedState throws on invalid facility level', () {
      final invalidState = createValidState(trainingFacilityLevel: 21);
      expect(() => gameStateManager.validateLoadedState(invalidState), throwsFormatException);

      final invalidState2 = createValidState(trainingFacilityLevel: 0);
      expect(() => gameStateManager.validateLoadedState(invalidState2), throwsFormatException);
    });

    test('validateLoadedState throws on too many news items', () {
       // Create 501 news items
       final manyNewsItems = List<NewsItem>.generate(501, (index) => NewsItem(
           id: 'news_$index',
           title: 'Test',
           description: 'Test',
           type: NewsItemType.Generic,
           date: DateTime.now()
       ));

       final invalidState = createValidState(newsItems: manyNewsItems);
       expect(() => gameStateManager.validateLoadedState(invalidState), throwsFormatException);
    });
  });
}
