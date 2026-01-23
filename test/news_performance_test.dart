import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/models/news_item.dart';

void main() {
  test('NewsItems getter performance benchmark', () {
    final gameState = GameStateManager();

    // Populate with 110 items to trigger the cap (max 100)
    for (int i = 0; i < 110; i++) {
      gameState.addNewsItemForTest(NewsItem.create(
        title: 'News $i',
        description: 'Description $i',
        date: DateTime.now().add(Duration(minutes: i)),
      ));
    }

    // Verify count is capped at 100
    expect(gameState.newsItems.length, 100);

    // Warmup
    for (int i = 0; i < 100; i++) {
      final _ = gameState.newsItems;
    }

    // Benchmark
    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 100000; i++) {
      final items = gameState.newsItems;
      if (items.isNotEmpty) {
        final first = items.first; // Force some access
      }
    }
    stopwatch.stop();

    print('Time taken for 100,000 accesses: ${stopwatch.elapsedMilliseconds} ms');

    // Verify order (currently Newest First)
    // We added 0..109. Cap logic (removeAt(0)) removes 0..9.
    // Remaining in _newsItems (Oldest->Newest): 10, 11, ..., 109.
    // newsItems getter (reversed): 109, 108, ..., 10.

    final firstItem = gameState.newsItems.first;
    final lastItem = gameState.newsItems.last;

    expect(firstItem.title, 'News 109');
    expect(lastItem.title, 'News 10');
  });
}
