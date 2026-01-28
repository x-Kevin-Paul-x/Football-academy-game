import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/Screens/PlayerManagementScreen.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/models/player.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:football_academy_game/models/tournament.dart';

void main() {
  testWidgets('Player details dialog shows stats with progress bars', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    final gameStateManager = GameStateManager();

    // Create a dummy player
    final player = Player(
      id: 'test_player_1',
      name: 'Test Player',
      age: 20,
      naturalPosition: PlayerPosition.Forward,
      potentialSkill: 80,
      weeklyWage: 1000,
      stamina: 15, // 15/20
      fatigue: 40.0, // 40%
      preferredPositions: [PlayerPosition.Forward],
      preferredFormat: TournamentType.elevenVeleven,
    );

    // Add player to the game state
    gameStateManager.signPlayer(player);

    // Pump the widget
    await tester.pumpWidget(
      ChangeNotifierProvider<GameStateManager>.value(
        value: gameStateManager,
        child: const MaterialApp( // Added const
          home: PlayerManagementScreen(), // Added const
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify player is shown in list
    expect(find.text('Test Player'), findsOneWidget);

    // Tap the player to open dialog
    await tester.tap(find.text('Test Player'));
    await tester.pumpAndSettle();

    // Verify dialog content exists (checking for labels within AlertDialog)
    expect(find.descendant(of: find.byType(AlertDialog), matching: find.text('Stamina')), findsOneWidget);
    expect(find.descendant(of: find.byType(AlertDialog), matching: find.text('Fatigue')), findsOneWidget);
    expect(find.descendant(of: find.byType(AlertDialog), matching: find.text('Current Skill')), findsOneWidget);

    // Verify values with new format
    expect(find.descendant(of: find.byType(AlertDialog), matching: find.text('15 / 20')), findsOneWidget);
    expect(find.descendant(of: find.byType(AlertDialog), matching: find.text('40.0%')), findsOneWidget);

    // Verify Progress Bars exist (3 of them: Skill, Stamina, Fatigue)
    expect(find.descendant(of: find.byType(AlertDialog), matching: find.byType(LinearProgressIndicator)), findsNWidgets(3));

    // Verify Semantics
    expect(find.bySemanticsLabel('Stamina progress bar'), findsOneWidget);
    expect(find.bySemanticsLabel('Fatigue progress bar'), findsOneWidget);
  });
}
