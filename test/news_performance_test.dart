import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/models/news_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('NewsItems maintains order and size limit', () {
    final gameState = GameStateManager();
    gameState.clearTestNewsItems();

    // Add 105 items
    for (int i = 0; i < 105; i++) {
      gameState.addTestNewsItem(NewsItem.create(
        title: 'News $i',
        description: 'Description $i',
        date: DateTime.now().add(Duration(minutes: i)),
      ));
    }

    // Verify limit
    expect(gameState.newsItems.length, 100);

    // Verify order (Newest first)
    // The last item added (News 104) should be first
    expect(gameState.newsItems.first.title, 'News 104');
    expect(gameState.newsItems.last.title, 'News 5'); // 0-4 should be removed
  });

  test('NewsItems getter performance benchmark', () {
    final gameState = GameStateManager();
    gameState.clearTestNewsItems();

    // Populate with 100 items
    for (int i = 0; i < 100; i++) {
      gameState.addTestNewsItem(NewsItem.create(
        title: 'News $i',
        description: 'Description $i',
      ));
    }

    final stopwatch = Stopwatch()..start();
    // Access getter 100,000 times
    for (int i = 0; i < 100000; i++) {
      final items = gameState.newsItems;
      // Basic operation to ensure it's not optimized away completely (though in Dart it likely wouldn't be without use)
      if (items.isEmpty) fail('Should not be empty');
    }
    stopwatch.stop();

    print('NewsItems getter 100k accesses: ${stopwatch.elapsedMilliseconds}ms');

    // We expect this to be fast (e.g. < 50ms with optimization, > 100ms without)
  });
}
