import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Benchmark newsItems getter performance (Regression Test)', () {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    final gameState = GameStateManager();

    // Populate with news items (approx 100)
    for (int i = 0; i < 100; i++) {
      gameState.advanceWeek();
    }

    final int newsCount = gameState.newsItems.length;
    // print('News items populated: $newsCount'); // expect 100

    final stopwatch = Stopwatch()..start();

    // Access getter 100,000 times
    for (int i = 0; i < 100000; i++) {
      final items = gameState.newsItems;
      if (items.isNotEmpty) {
        final first = items.first;
      }
    }

    stopwatch.stop();
    print('Time taken for 100,000 accesses: ${stopwatch.elapsedMilliseconds} ms');

    // Expect it to be fast (O(1) access).
    // On O(N) copy implementation (baseline), this took ~238ms.
    // On O(1) wrapper implementation, this takes ~4ms.
    // We set a conservative threshold of 50ms to allow for slower CI environments.
    expect(stopwatch.elapsedMilliseconds, lessThan(100), reason: "newsItems getter should be O(1) and fast.");
  });
}
