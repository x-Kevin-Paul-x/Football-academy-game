import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:football_academy_game/Screens/ScoutingScreen.dart';
import 'package:football_academy_game/game_state_manager.dart';

void main() {
  testWidgets('ScoutingScreen renders empty state correctly',
      (WidgetTester tester) async {
    // Create a real GameStateManager (default state has empty scoutedPlayers)
    final gameStateManager = GameStateManager();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<GameStateManager>.value(
          value: gameStateManager,
          child: ScoutingScreen(
            signPlayerCallback: (_) {},
            rejectPlayerCallback: (_) {},
          ),
        ),
      ),
    );

    // Verify empty state text
    expect(find.text('No new players found this week.'), findsOneWidget);
    expect(find.byIcon(Icons.search_off), findsOneWidget);
  });
}
