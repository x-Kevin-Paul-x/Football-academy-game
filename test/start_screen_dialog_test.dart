import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/Screens/StartScreen.dart';
import 'package:football_academy_game/models/difficulty.dart';

void main() {
  testWidgets('StartScreen shows new game dialog and validates input', (WidgetTester tester) async {
    // Build the StartScreen wrapped in the necessary provider
    // Provider must be ABOVE MaterialApp to survive navigation replacement
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => GameStateManager(),
        child: const MaterialApp(
          home: StartScreen(),
        ),
      ),
    );

    // Verify StartScreen is present
    expect(find.text('Welcome!'), findsOneWidget);

    // Tap "New Game"
    await tester.tap(find.text('New Game'));
    await tester.pumpAndSettle(); // Wait for dialog animation

    // Verify Dialog content
    expect(find.text('New Academy'), findsOneWidget);
    expect(find.text('Enter your Academy Name:'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Select Difficulty:'), findsOneWidget);

    // Try submitting empty name (Invalid)
    await tester.tap(find.text('Start Game'));
    await tester.pumpAndSettle();

    // Verify Error Message
    expect(find.text('Invalid name. Use 3-25 alphanumeric chars.'), findsOneWidget);

    // Enter valid name
    await tester.enterText(find.byType(TextField), 'Valid FC');
    await tester.pumpAndSettle();

    // Tap Start Game again
    await tester.tap(find.text('Start Game'));
    await tester.pumpAndSettle(); // Wait for navigation

    // Verify Navigation to Dashboard (Dashboard has 'Overview' or similar,
    // or just check that StartScreen is no longer in tree if replaced,
    // but Dashboard likely has "My Academy" text which is now "Valid FC")

    // Check if we are on Dashboard. Dashboard usually displays the academy name in AppBar or body.
    // Dashboard.dart imports GameStateManager and displays data.
    // Since we are in a test environment, checking for 'Valid FC' finding one widget is a good check.
    expect(find.text('Valid FC'), findsOneWidget);
  });
}
