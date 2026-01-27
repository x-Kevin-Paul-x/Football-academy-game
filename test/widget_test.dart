import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/main.dart';

void main() {
  testWidgets('Start screen new game flow test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Set a large surface size to prevent overflow errors
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

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

    // Tap "New Game" to open the dialog
    await tester.tap(find.text('New Game'));
    await tester.pumpAndSettle(); // Wait for dialog animation

    // Verify dialog contents
    expect(find.text('Name Your Academy'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);

    // Enter a valid academy name
    await tester.enterText(find.byType(TextFormField), 'Rising Stars FC');
    await tester.pump();

    // Tap "Start Game" button inside the dialog
    await tester.tap(find.text('Start Game'));
    await tester.pumpAndSettle(); // Wait for navigation and dashboard build

    // Verify that we have navigated to the Dashboard
    expect(find.text('Academy Dashboard'), findsOneWidget);

    // Clean up view configuration
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
