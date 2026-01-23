import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';

void main() {
  group('GameStateManager NewsItems Performance & Logic', () {
    late GameStateManager gameStateManager;

    setUp(() {
      gameStateManager = GameStateManager();
    });

    test('newsItems getter returns initial items (e.g. Pro Leagues)', () {
      // It is not empty because of initial Pro Leagues
      expect(gameStateManager.newsItems, isNotEmpty);
    });

    test('newsItems returns items in descending date order (Newest First)', () {
      // Note: GameStateManager init adds 3 news items for Pro Leagues.
      int initialCount = gameStateManager.newsItems.length;

      // Upgrade 1: Adds News Item 1 (Level 2)
      gameStateManager.upgradeTrainingFacility();
      // Upgrade 2: Adds News Item 2 (Level 3)
      gameStateManager.upgradeTrainingFacility();

      final news = gameStateManager.newsItems;
      expect(news.length, initialCount + 2);

      // Expected Order: Newest (Level 3) -> Next Newest (Level 2) -> Initial items...
      // Since .reversed is used currently (and we will switch to insert(0)), Newest should be at index 0.
      expect(news[0].title, contains('Facility Upgraded'));
      expect(news[0].description, contains('Level 3'));

      expect(news[1].title, contains('Facility Upgraded'));
      expect(news[1].description, contains('Level 2'));
    });

    // Skip limit test as it requires adding 100+ items which is hard to simulate cleanly here.
  });
}
