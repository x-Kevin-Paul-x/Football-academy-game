import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/models/news_item.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // GameStateManager might depend on it for loading

void main() {
  test('NewsItems should be ordered newest first and capped at 100', () {
    final gameState = GameStateManager();
    gameState.resetGame(); // Clears everything (including news)

    // Initially empty (or maybe has initial items from reset logic, let's verify)
    // Actually resetGame -> _scheduleInitialProLeagues calls _addNewsItem
    // So it might not be empty.

    // Let's add explicit test items with dates to be sure.
    final now = DateTime.now();
    final olderDate = now.subtract(const Duration(days: 1));
    final newerDate = now;

    final itemOld = NewsItem.create(title: 'Old Item', description: 'Old', date: olderDate);
    final itemNew = NewsItem.create(title: 'New Item', description: 'New', date: newerDate);

    // Current logic: Add adds to end.
    // If we want [New, Old] in getter, we should add Old then New.
    gameState.addTestNewsItem(itemOld);
    gameState.addTestNewsItem(itemNew);

    // Verify getter returns [New, Old] (or at least New is before Old if mixed with other items)
    // Since resetGame adds items, we need to check relative order of OUR items.

    final news = gameState.newsItems;
    final indexOld = news.indexWhere((i) => i.title == 'Old Item');
    final indexNew = news.indexWhere((i) => i.title == 'New Item');

    expect(indexNew, lessThan(indexOld), reason: "Newer item should appear before older item");

    // Verify Cap
    // Add 105 more items.
    for (int i = 0; i < 105; i++) {
        gameState.addTestNewsItem(NewsItem.create(title: 'Spam $i', description: 'Spam'));
    }

    expect(gameState.newsItems.length, lessThanOrEqualTo(100));
  });
}
