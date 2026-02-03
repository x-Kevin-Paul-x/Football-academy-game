import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/Screens/PlayerManagementScreen.dart';

void main() {
  testWidgets('PlayerManagementScreen shows actionable empty state when no players', (WidgetTester tester) async {
    // 1. Setup GameStateManager with NO players
    final gameStateManager = GameStateManager();

    // Track if callback is called
    bool scoutingCallbackCalled = false;

    await tester.pumpWidget(
      ChangeNotifierProvider<GameStateManager>.value(
        value: gameStateManager,
        child: MaterialApp(
          home: Scaffold(
            body: PlayerManagementScreen(
              onGoToScouting: () {
                scoutingCallbackCalled = true;
              },
            ),
          ),
        ),
      ),
    );

    // 2. Verify "No players..." text is present
    expect(find.text('No players in the academy yet.'), findsOneWidget);

    // 3. Verify the "Go to Scouting" button IS present
    expect(find.text('Go to Scouting'), findsOneWidget);

    // 4. Tap the button
    await tester.tap(find.text('Go to Scouting'));
    await tester.pump();

    // 5. Verify callback was triggered
    expect(scoutingCallbackCalled, isTrue);
  });
}
