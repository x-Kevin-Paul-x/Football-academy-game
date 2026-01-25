import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/models/news_item.dart';

void main() {
  group('GameStateManager News Logic', () {
    late GameStateManager gameStateManager;

    setUp(() {
      gameStateManager = GameStateManager();
      gameStateManager.resetGame(); // Ensure clean state
    });

    test('News items are returned in newest-first order', () {
      final item1 = NewsItem.create(
        title: "News 1",
        description: "Older news",
        date: DateTime(2023, 1, 1),
      );
      gameStateManager.addTestNewsItem(item1);

      final item2 = NewsItem.create(
        title: "News 2",
        description: "Newer news",
        date: DateTime(2023, 1, 2),
      );
      gameStateManager.addTestNewsItem(item2);

      // item2 was added last, so with our optimization (insert at 0), it should be at index 0.
      expect(gameStateManager.newsItems.length, 2);
      expect(gameStateManager.newsItems[0].title, "News 2");
      expect(gameStateManager.newsItems[1].title, "News 1");
    });

    test('News items are capped at 100', () {
      // Add 110 items
      for (int i = 0; i < 110; i++) {
        gameStateManager.addTestNewsItem(NewsItem.create(
          title: "News $i",
          description: "Desc",
          date: DateTime(2023, 1, 1).add(Duration(days: i)),
        ));
      }

      expect(gameStateManager.newsItems.length, 100);

      // The newest item (News 109) should be at index 0
      expect(gameStateManager.newsItems[0].title, "News 109");
      // The oldest item (News 10) should be at index 99 (since 0-9 were removed)
      expect(gameStateManager.newsItems.last.title, "News 10");
    });
  });
}
