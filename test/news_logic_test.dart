import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/models/news_item.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock SharedPreferences and PathProvider if necessary, though simpler unit test might pass
  // if we avoid calling methods that use them.

  group('News Feed Logic', () {
    late GameStateManager gameState;

    setUp(() {
       // Mock SharedPreferences values (optional but good practice)
       const MethodChannel('plugins.flutter.io/shared_preferences')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getAll') {
          return <String, dynamic>{}; // Return empty map
        }
        return null;
      });

      gameState = GameStateManager();
    });

    test('Adds news items and maintains size limit', () {
      // Add 105 items
      for (int i = 0; i < 105; i++) {
        gameState.addNewsItemForTest(NewsItem.create(
          title: 'News $i',
          description: 'Description $i',
          date: DateTime.now().add(Duration(minutes: i)),
        ));
      }

      // Check size limit
      expect(gameState.newsItems.length, 100);

      // Verify ordering
      // Expected behavior: Newest items first.
      // Added 0..104 (where 104 is newest).
      // Limit removes oldest (0..4).
      // Remaining in feed: 104 down to 5.

      expect(gameState.newsItems.first.title, 'News 104');
      expect(gameState.newsItems.last.title, 'News 5');
    });
  });
}
