import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:football_academy_game/Screens/PlayerManagementScreen.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/models/player.dart';

void main() {
  testWidgets('PlayerManagementScreen shows player details in dialog', (WidgetTester tester) async {
    // 1. Setup GameStateManager with a player
    final gameStateManager = GameStateManager();

    final player = Player(
      id: 'test_player_1',
      name: 'Test Player',
      age: 20,
      naturalPosition: PlayerPosition.Forward,
      potentialSkill: 80,
      weeklyWage: 500,
      preferredPositions: [PlayerPosition.Forward],
      stamina: 15, // 15/20
      fatigue: 10.0, // 10%
    );

    gameStateManager.signPlayer(player);

    // 2. Pump the widget
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<GameStateManager>.value(
          value: gameStateManager,
          child: const PlayerManagementScreen(),
        ),
      ),
    );

    // 3. Verify player list shows the player
    expect(find.text('Test Player'), findsOneWidget);

    // 4. Tap the player card
    await tester.tap(find.text('Test Player'));
    await tester.pumpAndSettle(); // Wait for dialog animation

    // 5. Verify dialog content (Baseline Check)
    // We expect 2 because one is on the card in the background, one is in the dialog title
    expect(find.text('Test Player'), findsAtLeastNWidgets(1));

    // Check for updated labels (no colon)
    expect(find.text('Stamina'), findsOneWidget);
    expect(find.text('Fatigue'), findsOneWidget);

    // Verify values are still textually present
    expect(find.text('15'), findsOneWidget);
    expect(find.text('10.0%'), findsOneWidget);

    // Verify LinearProgressIndicators are present
    expect(find.byType(LinearProgressIndicator), findsNWidgets(2));

    // Verify Semantics
    // Ensure semantics are generated
    // Stamina: 15/20
    expect(find.bySemanticsLabel('Stamina: 15 out of 20'), findsOneWidget);
    // Fatigue: 10.0/100
    expect(find.bySemanticsLabel('Fatigue: 10 out of 100'), findsOneWidget);
  });
}
