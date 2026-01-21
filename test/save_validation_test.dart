import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';

void main() {
  group('Save Data Validation', () {
    test('Valid save data passes validation', () {
      final validData = {
        'academyPlayers': [],
        'hiredStaff': [],
        'rivalAcademies': [],
        'aiClubs': [],
        'newsItems': [],
        'activeTournaments': [],
        'completedTournaments': [],
      };
      // Should not throw
      GameStateManager.validateSaveData(validData);
    });

    test('Excessive academyPlayers throws exception', () {
      final data = {
        'academyPlayers': List.filled(201, {}), // Limit 200
      };
      expect(() => GameStateManager.validateSaveData(data), throwsA(isA<Exception>()));
    });

    test('Excessive hiredStaff throws exception', () {
      final data = {
        'hiredStaff': List.filled(101, {}), // Limit 100
      };
      expect(() => GameStateManager.validateSaveData(data), throwsA(isA<Exception>()));
    });

    test('Excessive newsItems throws exception', () {
      final data = {
        'newsItems': List.filled(501, {}), // Limit 500
      };
      expect(() => GameStateManager.validateSaveData(data), throwsA(isA<Exception>()));
    });

    test('Excessive activeTournaments throws exception', () {
      final data = {
        'activeTournaments': List.filled(201, {}), // Limit 200
      };
      expect(() => GameStateManager.validateSaveData(data), throwsA(isA<Exception>()));
    });
  });
}
