import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/Screens/PlayerManagementScreen.dart';
import 'package:football_academy_game/models/player.dart';

void main() {
  testWidgets('Player details dialog shows visual stat bars for Stamina and Fatigue', (WidgetTester tester) async {
    // 1. Mock SharedPreferences (required by GameStateManager)
    SharedPreferences.setMockInitialValues({});

    // 2. Initialize GameStateManager
    final gameStateManager = GameStateManager();

    // 3. Create a dummy player with specific stats
    // Stamina: 10 (out of 20, so 50%)
    // Fatigue: 50.0 (out of 100.0, so 50%)
    final player = Player(
      id: 'test_player_ux',
      name: 'Test Player UX',
      age: 18,
      naturalPosition: PlayerPosition.Forward,
      potentialSkill: 80,
      weeklyWage: 500,
      preferredPositions: [PlayerPosition.Forward],
      stamina: 10,
      fatigue: 50.0,
      matchesPlayed: 5,
      goalsScored: 2,
      assists: 1,
    );

    // 4. Inject player into state
    // We use signPlayer which adds to academyPlayers list.
    // It might trigger "Staff Hired" or "Player Assigned" logic but that's fine.
    gameStateManager.signPlayer(player);

    // 5. Pump the PlayerManagementScreen wrapped in Provider
    await tester.pumpWidget(
      ChangeNotifierProvider<GameStateManager>.value(
        value: gameStateManager,
        child: const MaterialApp(
          home: PlayerManagementScreen(),
        ),
      ),
    );

    // Verify player is shown in list
    expect(find.text('Test Player UX'), findsOneWidget);

    // 6. Tap the player card to open dialog
    await tester.tap(find.text('Test Player UX'));
    await tester.pumpAndSettle(); // Wait for dialog animation

    // 7. Verify Dialog Content
    expect(find.text('Test Player UX'), findsAtLeastNWidgets(1)); // Dialog Title (and potentially list item below)

    // Verify Stat Bars are NOT yet present (this test confirms existing behavior first if run before changes,
    // or fails if changes are expected but not there. We expect this to FAIL if we run it now with assertions for LinearProgressIndicator).

    // But since I'm "writing tests to verify changes", I will write the assertions for the NEW behavior.
    // Assert existence of LinearProgressIndicator
    // We expect 2 indicators: One for Stamina, one for Fatigue.
    // Note: There might be other indicators in the app, but in this specific dialog context, there should be 2.
    // Finder scoped to the dialog would be safer, but global finder is okay for this unit test.

    final progressIndicatorFinder = find.byType(LinearProgressIndicator);

    // Verify labels are present
    expect(find.text('Stamina:'), findsOneWidget);
    expect(find.text('Fatigue:'), findsOneWidget);

    // If I run this BEFORE applying changes, I expect 0 progress indicators in the dialog.
    // If I run AFTER, I expect 2.
    // To make this test useful for verification AFTER changes, I assert 2.
    expect(progressIndicatorFinder, findsNWidgets(2));

    // Optional: Verify Semantics
    // expect(find.bySemanticsLabel('Stamina: 10'), findsOneWidget);
    // expect(find.bySemanticsLabel('Fatigue: 50.0%'), findsOneWidget);
  });
}
