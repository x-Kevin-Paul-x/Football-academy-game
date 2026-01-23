import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/models/difficulty.dart';

void main() {
  group('Security - Input Validation', () {
    test('isValidAcademyName allows valid names', () {
      expect(GameStateManager.isValidAcademyName('My Academy'), isTrue);
      expect(GameStateManager.isValidAcademyName('FC United'), isTrue);
      expect(GameStateManager.isValidAcademyName('Team 1'), isTrue);
      expect(GameStateManager.isValidAcademyName('Abc'), isTrue); // Min length 3
    });

    test('isValidAcademyName rejects invalid names', () {
      expect(GameStateManager.isValidAcademyName(''), isFalse); // Empty
      expect(GameStateManager.isValidAcademyName('A'), isFalse); // Too short
      expect(GameStateManager.isValidAcademyName('AB'), isFalse); // Too short
      expect(GameStateManager.isValidAcademyName('This name is way too long for the game'), isFalse); // > 25 chars
      expect(GameStateManager.isValidAcademyName('Team@'), isFalse); // Special char
      expect(GameStateManager.isValidAcademyName('Team_1'), isFalse); // Underscore not allowed by alphanumeric+space regex
      expect(GameStateManager.isValidAcademyName('Select * From Users'), isFalse); // SQLi attempt (contains special chars anyway)
      expect(GameStateManager.isValidAcademyName('<script>'), isFalse); // XSS attempt
    });
  });

  group('GameStateManager - Reset Game Security', () {
    test('resetGame accepts valid name', () {
      final gameState = GameStateManager();
      gameState.resetGame(academyName: 'Secure FC', difficulty: Difficulty.Hard);

      expect(gameState.academyName, 'Secure FC');
      expect(gameState.difficulty, Difficulty.Hard);
    });

    test('resetGame rejects invalid name and uses default', () {
      final gameState = GameStateManager();
      // Attempt to set invalid name via resetGame
      gameState.resetGame(academyName: '<Bad Name>', difficulty: Difficulty.Normal);

      // Should fallback to default
      expect(gameState.academyName, 'My Academy');
      expect(gameState.difficulty, Difficulty.Normal);
    });

     test('resetGame handles null name correctly', () {
      final gameState = GameStateManager();
      gameState.resetGame(academyName: null);

      expect(gameState.academyName, 'My Academy');
    });
  });
}
