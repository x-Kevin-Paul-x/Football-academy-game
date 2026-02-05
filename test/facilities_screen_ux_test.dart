import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/Screens/FacilitiesScreen.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Create a subclass to override the balance
class TestGameStateManager extends GameStateManager {
  @override
  double get balance => 0.0; // Simulate being broke
}

void main() {
  testWidgets('FacilitiesScreen shows tooltip on disabled upgrade button', (WidgetTester tester) async {
    // Setup Mock SharedPreferences for GameStateManager initialization
    SharedPreferences.setMockInitialValues({});

    // Create the test manager
    final testManager = TestGameStateManager();

    // Pump the widget wrapped in Provider and MaterialApp
    await tester.pumpWidget(
      ChangeNotifierProvider<GameStateManager>.value(
        value: testManager,
        child: const MaterialApp(
          home: FacilitiesScreen(),
        ),
      ),
    );

    // Wait for any animations
    await tester.pumpAndSettle();

    // Debug: Check for any Card
    expect(find.byType(Card), findsWidgets, reason: "No Cards found");

    // Find "Upgrade" text.
    final upgradeTextFinder = find.text('Upgrade');
    expect(upgradeTextFinder, findsWidgets, reason: "No 'Upgrade' text found");

    // Take the first one
    final firstUpgradeText = upgradeTextFinder.first;

    // Find the Tooltip wrapping the button (ancestor of the text)
    final tooltipFinder = find.ancestor(
      of: firstUpgradeText,
      matching: find.byType(Tooltip),
    );
    expect(tooltipFinder, findsOneWidget, reason: "Tooltip not found around Upgrade button");

    // Verify the tooltip message
    final tooltipWidget = tester.widget<Tooltip>(tooltipFinder);
    expect(tooltipWidget.message, contains("Insufficient funds"));
    expect(tooltipWidget.message, contains("Short by"));

    // Verify the child (Button) is disabled
    final buttonChild = tooltipWidget.child;
    expect(buttonChild, isA<ElevatedButton>(), reason: "Child of Tooltip should be ElevatedButton");

    final elevatedButton = buttonChild as ElevatedButton;
    expect(elevatedButton.onPressed, isNull, reason: "Button should be disabled");
  });
}
