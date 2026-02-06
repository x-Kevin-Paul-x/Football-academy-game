import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/models/news_item.dart';

void main() {
  test('News getter performance benchmark', () {
    final gameState = GameStateManager();
    gameState.clearTestNewsItems();

    // Populate with 100 news items (max cap)
    for (int i = 0; i < 100; i++) {
      gameState.addTestNewsItem(NewsItem.create(
        title: 'News $i',
        description: 'Description $i',
      ));
    }

    final stopwatch = Stopwatch()..start();
    const iterations = 100000;

    // Access the getter repeatedly
    for (int i = 0; i < iterations; i++) {
      final news = gameState.newsItems;
      // Access first element to ensure list is materialized/accessed if lazy
      if (news.isNotEmpty) {
        final _ = news.first;
      }
    }

    stopwatch.stop();
    print('News getter execution time for $iterations calls: ${stopwatch.elapsedMilliseconds}ms');
  });
}
