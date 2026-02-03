import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:football_academy_game/Screens/PlayerManagementScreen.dart';
import 'package:football_academy_game/game_state_manager.dart';

void main() {
  testWidgets('PlayerManagementScreen renders empty state correctly', (WidgetTester tester) async {
    // Create a real GameStateManager (default state has empty academyPlayers)
    final gameStateManager = GameStateManager();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<GameStateManager>.value(
          value: gameStateManager,
          child: const PlayerManagementScreen(),
        ),
      ),
    );

    // Verify empty state text
    expect(find.text('No players in the academy yet.'), findsOneWidget);
    expect(find.text('Scout and sign players to build your team!'), findsOneWidget);
    expect(find.byIcon(Icons.person_search), findsOneWidget);
  });
}
