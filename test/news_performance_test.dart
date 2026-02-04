
import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/models/news_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Benchmark newsItems getter performance', () {
    SharedPreferences.setMockInitialValues({});

    final manager = GameStateManager();

    // Populate with 100 items (max cap)
    for (int i = 0; i < 100; i++) {
      manager.addTestNewsItem(NewsItem.create(
        title: 'Test News $i',
        description: 'Description',
        date: DateTime.now().add(Duration(minutes: i))
      ));
    }

    final stopwatch = Stopwatch()..start();

    // Access getter 100,000 times
    for (int i = 0; i < 100000; i++) {
      final items = manager.newsItems;
      // Access an element to ensure evaluation if lazy (UnmodifiableListView is lazy, but List.unmodifiable is not)
      if (items.isNotEmpty) {
        final first = items.first;
      }
    }

    stopwatch.stop();
    print('Execution time for 100,000 accesses: ${stopwatch.elapsedMilliseconds}ms');
  });
}
