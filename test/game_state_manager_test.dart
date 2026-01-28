import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/models/difficulty.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('News items are stored in correct order (Newest First)', () async {
    final gameState = GameStateManager();
    // Set difficulty to Easy to ensure enough balance for upgrades
    gameState.setDifficulty(Difficulty.Easy);

    // Note: Constructor might add some initial news items (e.g., from _scheduleInitialProLeagues)
    final initialCount = gameState.newsItems.length;

    // Perform Action 1: Upgrade Training Facility (Level 1 -> 2)
    bool success1 = gameState.upgradeTrainingFacility();
    expect(success1, true, reason: "Should be able to afford first upgrade");

    // Perform Action 2: Upgrade Training Facility (Level 2 -> 3)
    bool success2 = gameState.upgradeTrainingFacility();
    expect(success2, true, reason: "Should be able to afford second upgrade");

    // Verify Order: Index 0 should be the most recent action (Level 3)
    // Index 1 should be the previous action (Level 2)
    // This assumes the getter returns Newest -> Oldest

    expect(gameState.newsItems.length, initialCount + 2);

    // Check most recent news item (Index 0)
    expect(gameState.newsItems[0].title, "Facility Upgraded");
    expect(gameState.newsItems[0].description, contains("Level 3"));

    // Check previous news item (Index 1)
    expect(gameState.newsItems[1].title, "Facility Upgraded");
    expect(gameState.newsItems[1].description, contains("Level 2"));
  });

  test('News items are capped at 100 and maintain order', () async {
     final gameState = GameStateManager();

     // Advance week many times to generate news
     // Each advanceWeek adds at least "Weekly Finances" news
     // Limit is 100. We advance 110 times.
     for (int i = 0; i < 110; i++) {
       gameState.advanceWeek();
     }

     // Verify Cap
     expect(gameState.newsItems.length, lessThanOrEqualTo(100));

     // Verify Order (Newest First)
     // The first item should have a later date than the last item
     final newest = gameState.newsItems.first;
     final oldest = gameState.newsItems.last;

     expect(newest.date.isAfter(oldest.date), true, reason: "First item should be newer than last item");
  });
}
