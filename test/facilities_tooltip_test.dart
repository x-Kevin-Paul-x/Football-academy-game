import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:football_academy_game/Screens/FacilitiesScreen.dart';
import 'package:football_academy_game/game_state_manager.dart';

// Test implementation of GameStateManager to force specific conditions
class TestGameStateManager extends GameStateManager {
  @override
  double get balance => 0.0; // Force zero balance

  @override
  int get trainingFacilityLevel => 1;
}

void main() {
  testWidgets('FacilitiesScreen shows helpful tooltip when funds are insufficient', (WidgetTester tester) async {
    // Set screen size to ensure ListView items are rendered
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    // Setup
    final gameStateManager = TestGameStateManager();

    // Pump widget
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<GameStateManager>.value(
          value: gameStateManager,
          child: const FacilitiesScreen(),
        ),
      ),
    );

    // Verify initial state: "Training Facility" card should be present
    expect(find.text('Training Facility'), findsOneWidget);

    // Instead of traversing up from Text, let's find the Tooltip directly based on its message.
    // This is the core verification: does a tooltip exist with the helpful message?

    final helpfulTooltipFinder = find.byWidgetPredicate((widget) {
      return widget is Tooltip &&
             widget.message != null &&
             widget.message!.contains('Short by \$15,000');
    });

    // We expect at least one because multiple facilities might be at level 1 with same cost
    expect(helpfulTooltipFinder, findsAtLeastNWidgets(1));

    // Reset view size
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
