import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/models/news_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('News Feed Order Tests', () {
    late GameStateManager gameStateManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      gameStateManager = GameStateManager();
      // Ensure the news list is empty (or we account for initial items)
      // Since resetGame isn't called, it might have initial scheduled items?
      // _scheduleInitialProLeagues adds news.
    });

    test('News items should be returned in Newest-First order', () {
      final item1 = NewsItem.create(
          title: 'Oldest', description: '1', date: DateTime(2023, 1, 1));
      final item2 = NewsItem.create(
          title: 'Middle', description: '2', date: DateTime(2023, 1, 2));
      final item3 = NewsItem.create(
          title: 'Newest', description: '3', date: DateTime(2023, 1, 3));

      gameStateManager.addTestNewsItem(item1);
      gameStateManager.addTestNewsItem(item2);
      gameStateManager.addTestNewsItem(item3);

      final news = gameStateManager.newsItems;

      // We expect Newest First
      expect(news[0].title, equals('Newest'));
      expect(news[1].title, equals('Middle'));
      expect(
          news[2].title,
          equals(
              'Oldest')); // The 3rd item (index 2) should be 'Oldest' assuming no other initial news

      // If there are other initial news, we just check relative order of our added items
      final idx1 = news.indexWhere((n) => n.title == 'Oldest');
      final idx2 = news.indexWhere((n) => n.title == 'Middle');
      final idx3 = news.indexWhere((n) => n.title == 'Newest');

      expect(idx3, lessThan(idx2));
      expect(idx2, lessThan(idx1));
    });

    test('News items cap at 100', () {
      // Add 105 items
      for (int i = 0; i < 105; i++) {
        gameStateManager.addTestNewsItem(NewsItem.create(
          title: 'Item $i',
          description: 'Desc',
          date: DateTime.now().add(Duration(seconds: i)),
        ));
      }

      expect(gameStateManager.newsItems.length, lessThanOrEqualTo(100));
      // The newest item (Item 104) should be present
      expect(
          gameStateManager.newsItems.any((n) => n.title == 'Item 104'), isTrue);
      // The oldest items (Item 0..4) should be gone
      expect(
          gameStateManager.newsItems.any((n) => n.title == 'Item 0'), isFalse);
    });
  });
}
