import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';

void main() {
  group('GameStateManager Input Validation', () {
    late GameStateManager gameStateManager;

    setUp(() {
      gameStateManager = GameStateManager();
    });

    test('resetGame should accept valid names', () {
      gameStateManager.resetGame(academyName: 'Valid Name 123');
      expect(gameStateManager.academyName, 'Valid Name 123');
    });

    test('resetGame should trim names', () {
      gameStateManager.resetGame(academyName: '  Trim Me  ');
      expect(gameStateManager.academyName, 'Trim Me');
    });

    test('resetGame should default to My Academy if name is null', () {
      gameStateManager.resetGame();
      expect(gameStateManager.academyName, 'My Academy');
    });

    test('resetGame should throw ArgumentError for names too short (<3)', () {
      expect(() => gameStateManager.resetGame(academyName: 'Ab'), throwsArgumentError);
    });

    test('resetGame should throw ArgumentError for names too long (>25)', () {
      String longName = 'A' * 26;
      expect(() => gameStateManager.resetGame(academyName: longName), throwsArgumentError);
    });

    test('resetGame should throw ArgumentError for invalid characters', () {
      expect(() => gameStateManager.resetGame(academyName: 'Bad Name!'), throwsArgumentError); // ! is invalid
      expect(() => gameStateManager.resetGame(academyName: 'Bad@Name'), throwsArgumentError); // @ is invalid
      expect(() => gameStateManager.resetGame(academyName: '<script>'), throwsArgumentError); // XSS attempt
    });
  });
}
