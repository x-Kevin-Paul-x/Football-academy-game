import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/serializable_game_state.dart';
import 'package:football_academy_game/models/difficulty.dart';
import 'package:flutter/material.dart';
import 'package:football_academy_game/models/news_item.dart';
import 'package:football_academy_game/models/player.dart';

void main() {
  group('GameStateManager Validation Tests', () {
    late GameStateManager gameStateManager;

    setUp(() {
      gameStateManager = GameStateManager();
    });

    SerializableGameState createValidState({
      double balance = 50000.0,
      String academyName = 'My Academy',
      List<NewsItem>? newsItems,
      List<Player>? academyPlayers,
    }) {
      return SerializableGameState(
        currentDate: DateTime(2025, 1, 1),
        academyName: academyName,
        academyPlayers: academyPlayers ?? [],
        hiredStaff: [],
        balance: balance,
        weeklyIncome: 1000,
        totalWeeklyWages: 0,
        activeTournaments: [],
        completedTournaments: [],
        trainingFacilityLevel: 1,
        scoutingFacilityLevel: 1,
        medicalBayLevel: 1,
        academyReputation: 100,
        newsItems: newsItems ?? [],
        difficulty: Difficulty.Normal,
        themeMode: ThemeMode.system,
        rivalAcademies: [],
        aiClubs: [],
        playerAcademyTier: 0,
      );
    }

    test('validateLoadedState returns true for valid state', () {
      final state = createValidState();
      expect(gameStateManager.validateLoadedState(state), isTrue);
    });

    test('validateLoadedState returns false for NaN balance', () {
      final state = createValidState(balance: double.nan);
      expect(gameStateManager.validateLoadedState(state), isFalse);
    });

    test('validateLoadedState returns false for Infinity balance', () {
      final state = createValidState(balance: double.infinity);
      expect(gameStateManager.validateLoadedState(state), isFalse);
    });

    test('validateLoadedState returns false for academyName > 25 chars', () {
      final state = createValidState(academyName: 'A' * 26);
      expect(gameStateManager.validateLoadedState(state), isFalse);
    });

    test('validateLoadedState returns true for academyName <= 25 chars', () {
      final state = createValidState(academyName: 'A' * 25);
      expect(gameStateManager.validateLoadedState(state), isTrue);
    });

    test('validateLoadedState returns false for newsItems > 500', () {
      final newsItems = List.generate(501, (index) => NewsItem.create(
        title: 'Title',
        description: 'Desc',
        type: NewsItemType.Generic,
        date: DateTime.now(),
      ));
      final state = createValidState(newsItems: newsItems);
      expect(gameStateManager.validateLoadedState(state), isFalse);
    });

    test('validateLoadedState returns false for academyPlayers > 200', () {
      // Mocking players might be verbose, let's use a minimal mock or just rely on the list check if the method only checks list length.
      // We need to create valid Player objects or the SerializableGameState constructor might fail if it validates? No, it just takes the list.
      // But creating 201 players is heavy.
      // Let's assume the method just checks .length.
      // We'll create a dummy list of nulls? No, explicit typing.
      // We need real Player objects.
      // Use Player.createWithTargetSkill for ease.
      final players = List.generate(201, (index) => Player.createWithTargetSkill(
        id: 'p_$index',
        name: 'Player $index',
        age: 18,
        naturalPosition: PlayerPosition.Forward,
        targetSkill: 50,
        potentialSkill: 70,
        weeklyWage: 100,
        reputation: 10,
      ));
      final state = createValidState(academyPlayers: players);
      expect(gameStateManager.validateLoadedState(state), isFalse);
    });
  });
}
