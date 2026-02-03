import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Benchmark newsItems getter performance and verify order', () {
    SharedPreferences.setMockInitialValues({}); // Mock SharedPreferences
    final gameStateManager = GameStateManager();

    // Generate news items by advancing week
    // Each advanceWeek adds at least "Weekly Finances" news, plus potential scouting/tournament news
    // 50 weeks should give > 50 items.
    for (int i = 0; i < 50; i++) {
      gameStateManager.advanceWeek();
    }

    // Verify we have items
    final initialItems = gameStateManager.newsItems;
    expect(initialItems, isNotEmpty);
    print('News items count: ${initialItems.length}');

    // Verify order: Newest first.
    // The first item should have a date >= the second item.
    for (int i = 0; i < initialItems.length - 1; i++) {
      // compareTo returns 1 if this is after other.
      // We expect items[i].date >= items[i+1].date
      // So items[i].date.compareTo(items[i+1].date) should be >= 0
      expect(initialItems[i].date.compareTo(initialItems[i+1].date) >= 0, true,
        reason: 'Item at $i (${initialItems[i].date}) should be newer or equal to item at ${i+1} (${initialItems[i+1].date})');
    }

    // Benchmark
    final stopwatch = Stopwatch()..start();
    const iterations = 100000;
    for (int i = 0; i < iterations; i++) {
      final items = gameStateManager.newsItems;
      if (items.isEmpty) throw Exception('Should not be empty');
      // Access an element to ensure list is realized if lazy (List.unmodifiable isn't lazy in that sense, but good measure)
      final first = items.first;
    }
    stopwatch.stop();

    print('Time taken for $iterations accesses: ${stopwatch.elapsedMilliseconds} ms');
  });
}
