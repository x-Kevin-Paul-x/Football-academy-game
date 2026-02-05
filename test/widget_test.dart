import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for mocking

import 'package:football_academy_game/main.dart';
import 'package:football_academy_game/game_state_manager.dart';

void main() {
  testWidgets('Start screen smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({}); // Initialize with empty values

    // Build our app and trigger a frame.
    // Wrap MyApp in ChangeNotifierProvider as done in main.dart
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => GameStateManager(),
        child: const MyApp(),
      ),
    );

    // Allow time for initialization (if any async stuff happens, though create is sync)
    await tester.pumpAndSettle();

    // Verify that the StartScreen is shown.
    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text('New Game'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });
}
