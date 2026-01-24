import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:football_academy_game/Screens/FacilitiesScreen.dart';
import 'package:football_academy_game/game_state_manager.dart';

void main() {
  testWidgets('FacilitiesScreen shows upgrade buttons and costs', (WidgetTester tester) async {
    // Set a large surface size to ensure all items in the ListView are built
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    final gameStateManager = GameStateManager();

    await tester.pumpWidget(
      ChangeNotifierProvider<GameStateManager>.value(
        value: gameStateManager,
        child: const MaterialApp(
          home: FacilitiesScreen(),
        ),
      ),
    );

    // Verify Title
    expect(find.text('Academy Facilities'), findsOneWidget);

    // Verify Training Facility presence
    expect(find.text('Training Facility'), findsOneWidget);
    // Multiple facilities start at Level 1
    expect(find.text('Level 1'), findsWidgets);

    // Find the Upgrade text (label of the button)
    expect(find.text('Upgrade'), findsWidgets);

    // Find Tooltip widget
    expect(find.byType(Tooltip), findsWidgets);

    // Find cost text.
    // Cost calculation: (pow(1, 1.5) * 5000) + 10000 = 15000
    // Training, Scouting, Medical Bay all have same level 1 cost
    expect(find.textContaining('15,000'), findsWidgets);

    // Reset view size
    addTearDown(tester.view.resetPhysicalSize);
  });
}
