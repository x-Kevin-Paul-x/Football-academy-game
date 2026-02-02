import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:football_academy_game/Screens/FacilitiesScreen.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/models/difficulty.dart';

void main() {
  testWidgets('FacilitiesScreen upgrade buttons have tooltips', (WidgetTester tester) async {
    // 1. Setup GameStateManager with insufficient funds
    final gameStateManager = GameStateManager();
    gameStateManager.setDifficulty(Difficulty.Hardcore);
    // Balance 10,000. Upgrade cost 15,000 (Level 1 -> 2).

    // 2. Pump the widget
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<GameStateManager>.value(
          value: gameStateManager,
          child: const FacilitiesScreen(),
        ),
      ),
    );

    // 3. Verify Tooltip presence by message
    // Upgrade cost calculation: (1^1.5 * 5000) + 10000 = 15000.
    const tooltipMessage = 'Insufficient funds (Need \$15000)';
    final tooltipFinder = find.byTooltip(tooltipMessage);

    // There are multiple facilities (Training, Scouting, Medical), all at Level 1, all too expensive.
    // So we expect to find at least one.
    expect(tooltipFinder, findsWidgets);
  });
}
