import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:football_academy_game/game_state_manager.dart';

import 'package:football_academy_game/main.dart';

void main() {
  testWidgets('Start screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Wrap MyApp in a ChangeNotifierProvider as expected by the app.
    // Note: This uses a real GameStateManager. For more complex tests,
    // a mock would be better, but for a smoke test, this is sufficient.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => GameStateManager(),
        child: const MyApp(),
      ),
    );

    // Verify that the StartScreen is shown.
    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text('New Game'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });
}
