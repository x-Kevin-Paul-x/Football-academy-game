import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('resetGame sets default academy name when no argument is provided', () async {
    SharedPreferences.setMockInitialValues({}); // Mock SharedPreferences
    final gameStateManager = GameStateManager();

    // Simulate a change first to ensure reset does something
    // (Note: we can't easily change _academyName directly as it's private,
    // but we rely on resetGame setting it)

    gameStateManager.resetGame();

    expect(gameStateManager.academyName, "My Academy");
  });

  test('resetGame sets custom academy name when argument is provided', () async {
    SharedPreferences.setMockInitialValues({}); // Mock SharedPreferences
    final gameStateManager = GameStateManager();

    gameStateManager.resetGame(academyName: "Jules Academy");

    expect(gameStateManager.academyName, "Jules Academy");
  });
}
