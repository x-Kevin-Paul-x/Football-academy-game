import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:football_academy_game/main.dart';
import 'package:football_academy_game/game_state_manager.dart';

void main() {
  testWidgets('Start screen smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences as GameStateManager might use it (though constructor doesn't seems to)
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    // Wrap MyApp in ChangeNotifierProvider as expected by Consumer in MyApp
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => GameStateManager(),
        child: const MyApp(),
      ),
    );

    // Verify that the StartScreen is shown.
    // Note: If StartScreen takes time to load or has animations, we might need pumpAndSettle
    await tester.pumpAndSettle();

    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text('New Game'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });
}
