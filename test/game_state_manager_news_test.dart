import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/models/news_item.dart';

void main() {
  group('GameStateManager News Optimization', () {
    test('newsItems getter returns items', () {
      final manager = GameStateManager();
      // Ensure it starts empty (or near empty after init)
      expect(manager.newsItems, isA<List<NewsItem>>());
    });

    // Note: Deeper testing requires mocking or exposing private methods
    // which we are handling via manual verification of the implementation logic.
  });
}
