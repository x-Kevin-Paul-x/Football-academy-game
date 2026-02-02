import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('NewsItems getter performance and order benchmark', () {
    final gameState = GameStateManager();

    // Populate news items
    // advanceWeek usually adds Finance, Scouting, etc. news.
    // 60 weeks should be enough to fill the buffer (max 100).
    print('Populating news items...');
    for (int i = 0; i < 60; i++) {
      gameState.advanceWeek();
    }

    final newsCount = gameState.newsItems.length;
    print('News items count: $newsCount');
    expect(newsCount, lessThanOrEqualTo(100));
    expect(newsCount, greaterThan(10)); // Should have plenty

    // Benchmark getter
    final stopwatch = Stopwatch()..start();
    int accessCount = 100000;

    for (int i = 0; i < accessCount; i++) {
      final items = gameState.newsItems;
      // Access first element to ensure lazy iterables are evaluated if any
      if (items.isNotEmpty) {
        final _ = items.first;
      }
    }

    stopwatch.stop();
    print('Time to access newsItems $accessCount times: ${stopwatch.elapsedMilliseconds}ms');

    // Verify Order (Newest First)
    // The current implementation (before optimization) appends to list (Old->New) and reverses in getter (New->Old).
    // So index 0 should be newer than index 1.
    final items = gameState.newsItems;
    if (items.length >= 2) {
      // Allow equality because multiple news can happen on same date
      bool isNewestFirst = true;
      for (int i = 0; i < items.length - 1; i++) {
        // date comparisons: newer isAfter older.
        // We expect items[i] >= items[i+1].
        // So !items[i].isBefore(items[i+1])
        if (items[i].date.isBefore(items[i+1].date)) {
           // Wait, if identical timestamps, isBefore is false.
           // If items[i] is strictly older than items[i+1], that's wrong.
           // We want descending order.
           isNewestFirst = false;
           print('Order violation at index $i: ${items[i].date} is before ${items[i+1].date}');
           break;
        }
      }
      expect(isNewestFirst, isTrue, reason: 'News items should be ordered newest first');
    }
  });
}
