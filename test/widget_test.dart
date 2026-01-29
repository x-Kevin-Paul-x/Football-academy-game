import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:football_academy_game/game_state_manager.dart';

import 'package:football_academy_game/main.dart';

void main() {
  testWidgets('Start screen smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Create a GameStateManager
    final gameStateManager = GameStateManager();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider<GameStateManager>.value(
        value: gameStateManager,
        child: const MyApp(),
      ),
    );

    // Verify that the StartScreen is shown.
    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text('New Game'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });
}
