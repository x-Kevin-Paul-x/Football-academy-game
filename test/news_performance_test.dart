import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/models/news_item.dart';

void main() {
  test('News items are stored in correct order and limited to 100', () async {
    final gameState = GameStateManager();

    // Initial state
    expect(gameState.newsItems.isEmpty, true);

    // Add 105 news items via a mechanism that triggers _addNewsItem
    // We can use advanceWeek which adds a "Weekly Finances" news item.
    // We need to ensure game is not over and not forced sell to advance week.

    for (int i = 0; i < 105; i++) {
      gameState.advanceWeek();
      // Verify the latest item is indeed the one we just added (conceptually)
      // The getter should return newest first.
      expect(gameState.newsItems.first.type, NewsItemType.Finance); // Weekly finances
    }

    // Check limit
    expect(gameState.newsItems.length, 100);

    // Verify order
    // Since we added them sequentially, the dates should be increasing.
    // newsItems getter should return newest (latest date) first.
    final firstItem = gameState.newsItems.first;
    final lastItem = gameState.newsItems.last;

    expect(firstItem.date.isAfter(lastItem.date), true);

    // Check strict ordering
    for (int i = 0; i < gameState.newsItems.length - 1; i++) {
       // item[i] should be newer (or same time) than item[i+1]
       expect(gameState.newsItems[i].date.compareTo(gameState.newsItems[i+1].date) >= 0, true);
    }
  });
}
