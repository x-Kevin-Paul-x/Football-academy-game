import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/models/news_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('GameStateManager News Feed Performance Optimization', () {
    late GameStateManager gameStateManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({}); // Mock SharedPreferences
      gameStateManager = GameStateManager();
      gameStateManager.clearTestNewsItems(); // Clear initial news
    });

    test('News items should be returned in newest-first order (based on insertion)', () {
      // Add news items with distinct dates
      final item1 = NewsItem.create(
        title: 'Oldest',
        description: 'First item',
        date: DateTime(2023, 1, 1),
      );
      final item2 = NewsItem.create(
        title: 'Middle',
        description: 'Second item',
        date: DateTime(2023, 1, 2),
      );
      final item3 = NewsItem.create(
        title: 'Newest',
        description: 'Third item',
        date: DateTime(2023, 1, 3),
      );

      // Simulate adding news items (older to newer, as game progresses)
      gameStateManager.addTestNewsItem(item1);
      gameStateManager.addTestNewsItem(item2);
      gameStateManager.addTestNewsItem(item3);

      // Verify order: Newest (item3) -> Middle (item2) -> Oldest (item1)
      // Current behavior: .reversed on getter reverses insertion order.
      expect(gameStateManager.newsItems.length, 3);
      expect(gameStateManager.newsItems[0].title, 'Newest');
      expect(gameStateManager.newsItems[1].title, 'Middle');
      expect(gameStateManager.newsItems[2].title, 'Oldest');
    });

    test('Adding new news item should place it at the beginning (index 0) logically', () {
      final initialItem = NewsItem.create(
        title: 'Existing',
        description: 'Existing item',
        date: DateTime(2023, 1, 1),
      );
      gameStateManager.addTestNewsItem(initialItem);

      final newItem = NewsItem.create(
        title: 'Fresh News',
        description: 'Just happened',
        date: DateTime(2023, 1, 2),
      );
      gameStateManager.addTestNewsItem(newItem);

      expect(gameStateManager.newsItems.first.title, 'Fresh News');
      expect(gameStateManager.newsItems.last.title, 'Existing');
    });
  });
}
