import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:football_academy_game/Screens/PlayerManagementScreen.dart';
import 'package:football_academy_game/Screens/TournamentHistoryScreen.dart';
import 'package:football_academy_game/widgets/empty_state.dart';
import 'package:football_academy_game/game_state_manager.dart';

void main() {
  testWidgets('Screens display correct empty states', (WidgetTester tester) async {
    // 1. Setup GameStateManager with empty data
    final gameStateManager = GameStateManager();
    // Ensure lists are empty (default behavior, but being explicit doesn't hurt)
    // gameStateManager.academyPlayers is empty by default
    // gameStateManager.completedTournaments is empty by default

    // 2. Verify PlayerManagementScreen empty state
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<GameStateManager>.value(
          value: gameStateManager,
          child: const PlayerManagementScreen(),
        ),
      ),
    );

    // Verify EmptyState widget is used and text is present
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('No players in the academy yet.'), findsOneWidget);

    // 3. Verify TournamentHistoryScreen empty state
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<GameStateManager>.value(
          value: gameStateManager,
          child: const TournamentHistoryScreen(),
        ),
      ),
    );

    // Verify EmptyState widget is used and text is present
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('No tournaments completed yet.'), findsOneWidget);
  });
}
