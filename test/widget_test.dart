import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:football_academy_game/game_state_manager.dart'; // Import GSM

import 'package:football_academy_game/main.dart';

void main() {
  testWidgets('Start screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Wrap MyApp in ChangeNotifierProvider as required by Consumer in MyApp
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GameStateManager(),
        child: const MyApp(),
      ),
    );

    // Verify that the StartScreen is shown.
    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text('New Game'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });
}
