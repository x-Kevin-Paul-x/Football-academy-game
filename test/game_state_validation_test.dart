import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/serializable_game_state.dart';
import 'package:football_academy_game/models/difficulty.dart';
import 'package:football_academy_game/models/news_item.dart';
import 'package:flutter/material.dart';

// Helper to create a valid base state
SerializableGameState createValidState() {
  return SerializableGameState(
    currentDate: DateTime.now(),
    academyName: 'Valid Academy',
    academyPlayers: [],
    hiredStaff: [],
    balance: 50000.0,
    weeklyIncome: 1000,
    totalWeeklyWages: 0,
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
    playerAcademyTier: 1,
    fans: 100,
  );
}

void main() {
  group('GameStateManager Validation', () {
    late GameStateManager manager;

    setUp(() {
      manager = GameStateManager();
    });

    test('validateLoadedState returns true for valid state', () {
      final state = createValidState();
      expect(manager.validateLoadedState(state), isTrue);
    });

    test('validateLoadedState detects invalid academy name length', () {
      final longName = 'A' * 26; // Limit is 25
      final state = createValidState();
      // Use reflection or copyWith if available, otherwise recreate
      final invalidState = SerializableGameState(
        currentDate: state.currentDate,
        academyName: longName,
        academyPlayers: state.academyPlayers,
        hiredStaff: state.hiredStaff,
        balance: state.balance,
        weeklyIncome: state.weeklyIncome,
        totalWeeklyWages: state.totalWeeklyWages,
        activeTournaments: state.activeTournaments,
        completedTournaments: state.completedTournaments,
        trainingFacilityLevel: state.trainingFacilityLevel,
        scoutingFacilityLevel: state.scoutingFacilityLevel,
        medicalBayLevel: state.medicalBayLevel,
        academyReputation: state.academyReputation,
        newsItems: state.newsItems,
        difficulty: state.difficulty,
        themeMode: state.themeMode,
        rivalAcademies: state.rivalAcademies,
        aiClubs: state.aiClubs,
        playerAcademyTier: state.playerAcademyTier,
        fans: state.fans,
      );

      expect(manager.validateLoadedState(invalidState), isFalse);
    });

    test('validateLoadedState detects NaN balance', () {
      final state = createValidState();
      final invalidState = SerializableGameState(
        currentDate: state.currentDate,
        academyName: state.academyName,
        academyPlayers: state.academyPlayers,
        hiredStaff: state.hiredStaff,
        balance: double.nan,
        weeklyIncome: state.weeklyIncome,
        totalWeeklyWages: state.totalWeeklyWages,
        activeTournaments: state.activeTournaments,
        completedTournaments: state.completedTournaments,
        trainingFacilityLevel: state.trainingFacilityLevel,
        scoutingFacilityLevel: state.scoutingFacilityLevel,
        medicalBayLevel: state.medicalBayLevel,
        academyReputation: state.academyReputation,
        newsItems: state.newsItems,
        difficulty: state.difficulty,
        themeMode: state.themeMode,
        rivalAcademies: state.rivalAcademies,
        aiClubs: state.aiClubs,
        playerAcademyTier: state.playerAcademyTier,
        fans: state.fans,
      );

      expect(manager.validateLoadedState(invalidState), isFalse);
    });

    test('validateLoadedState detects Infinity balance', () {
      final state = createValidState();
      final invalidState = SerializableGameState(
        currentDate: state.currentDate,
        academyName: state.academyName,
        academyPlayers: state.academyPlayers,
        hiredStaff: state.hiredStaff,
        balance: double.infinity,
        weeklyIncome: state.weeklyIncome,
        totalWeeklyWages: state.totalWeeklyWages,
        activeTournaments: state.activeTournaments,
        completedTournaments: state.completedTournaments,
        trainingFacilityLevel: state.trainingFacilityLevel,
        scoutingFacilityLevel: state.scoutingFacilityLevel,
        medicalBayLevel: state.medicalBayLevel,
        academyReputation: state.academyReputation,
        newsItems: state.newsItems,
        difficulty: state.difficulty,
        themeMode: state.themeMode,
        rivalAcademies: state.rivalAcademies,
        aiClubs: state.aiClubs,
        playerAcademyTier: state.playerAcademyTier,
        fans: state.fans,
      );

      expect(manager.validateLoadedState(invalidState), isFalse);
    });

    test('validateLoadedState detects invalid facility level (too high)', () {
      final state = createValidState();
      final invalidState = SerializableGameState(
        currentDate: state.currentDate,
        academyName: state.academyName,
        academyPlayers: state.academyPlayers,
        hiredStaff: state.hiredStaff,
        balance: state.balance,
        weeklyIncome: state.weeklyIncome,
        totalWeeklyWages: state.totalWeeklyWages,
        activeTournaments: state.activeTournaments,
        completedTournaments: state.completedTournaments,
        trainingFacilityLevel: 21, // Max 20
        scoutingFacilityLevel: state.scoutingFacilityLevel,
        medicalBayLevel: state.medicalBayLevel,
        academyReputation: state.academyReputation,
        newsItems: state.newsItems,
        difficulty: state.difficulty,
        themeMode: state.themeMode,
        rivalAcademies: state.rivalAcademies,
        aiClubs: state.aiClubs,
        playerAcademyTier: state.playerAcademyTier,
        fans: state.fans,
      );

      expect(manager.validateLoadedState(invalidState), isFalse);
    });

    test('validateLoadedState detects invalid facility level (too low)', () {
      final state = createValidState();
      final invalidState = SerializableGameState(
        currentDate: state.currentDate,
        academyName: state.academyName,
        academyPlayers: state.academyPlayers,
        hiredStaff: state.hiredStaff,
        balance: state.balance,
        weeklyIncome: state.weeklyIncome,
        totalWeeklyWages: state.totalWeeklyWages,
        activeTournaments: state.activeTournaments,
        completedTournaments: state.completedTournaments,
        trainingFacilityLevel: 0, // Min 1
        scoutingFacilityLevel: state.scoutingFacilityLevel,
        medicalBayLevel: state.medicalBayLevel,
        academyReputation: state.academyReputation,
        newsItems: state.newsItems,
        difficulty: state.difficulty,
        themeMode: state.themeMode,
        rivalAcademies: state.rivalAcademies,
        aiClubs: state.aiClubs,
        playerAcademyTier: state.playerAcademyTier,
        fans: state.fans,
      );

      expect(manager.validateLoadedState(invalidState), isFalse);
    });

     test('validateLoadedState detects invalid news items count', () {
      final state = createValidState();
      final List<NewsItem> tooManyNews = List.generate(501, (index) => NewsItem.create(
          title: 'News $index',
          description: 'Desc',
          type: NewsItemType.Generic,
          date: DateTime.now()
      ));

      final invalidState = SerializableGameState(
        currentDate: state.currentDate,
        academyName: state.academyName,
        academyPlayers: state.academyPlayers,
        hiredStaff: state.hiredStaff,
        balance: state.balance,
        weeklyIncome: state.weeklyIncome,
        totalWeeklyWages: state.totalWeeklyWages,
        activeTournaments: state.activeTournaments,
        completedTournaments: state.completedTournaments,
        trainingFacilityLevel: state.trainingFacilityLevel,
        scoutingFacilityLevel: state.scoutingFacilityLevel,
        medicalBayLevel: state.medicalBayLevel,
        academyReputation: state.academyReputation,
        newsItems: tooManyNews,
        difficulty: state.difficulty,
        themeMode: state.themeMode,
        rivalAcademies: state.rivalAcademies,
        aiClubs: state.aiClubs,
        playerAcademyTier: state.playerAcademyTier,
        fans: state.fans,
      );

      expect(manager.validateLoadedState(invalidState), isFalse);
    });
  });
}
