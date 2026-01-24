import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';

void main() {
  test('News items are stored correctly and capped at 100', () {
    final gsm = GameStateManager();

    // Initial state
    // _scheduleInitialProLeagues adds 3 news items on initialization
    expect(gsm.newsItems.length, 3);

    // Add 105 weeks of news (Weekly Finances is added every week)
    for (int i = 0; i < 105; i++) {
      gsm.advanceWeek();
    }

    // Verify limit
    expect(gsm.newsItems.length, 100, reason: "News items should be capped at 100");

    // Verify order (Newest first)
    // index 0 should be newer (larger DateTime) or same time as index 1
    final newest = gsm.newsItems[0];
    final secondNewest = gsm.newsItems[1];

    // Allow same moment because multiple items can be added in the same week/day
    expect(newest.date.compareTo(secondNewest.date) >= 0, isTrue,
      reason: "Index 0 should be newer or equal to Index 1 (Newest-First)");

    // The oldest item (at index 99) should correspond to the 6th week (since 0-4 were removed)
    // We can't easily check exact date without calculating, but we can verify sorted descending order

    for (int i = 0; i < gsm.newsItems.length - 1; i++) {
      expect(gsm.newsItems[i].date.compareTo(gsm.newsItems[i+1].date) >= 0, isTrue,
        reason: "Items should be sorted by date descending at index $i");
    }
  });
}
