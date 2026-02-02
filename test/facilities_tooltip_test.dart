import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:football_academy_game/Screens/FacilitiesScreen.dart';
import 'package:football_academy_game/game_state_manager.dart';

class TestGameStateManager extends GameStateManager {
  double _testBalance = 0.0;

  @override
  double get balance => _testBalance;

  void setBalance(double value) {
    _testBalance = value;
    notifyListeners();
  }
}

void main() {
  testWidgets('FacilitiesScreen shows insufficient funds tooltip when unaffordable', (WidgetTester tester) async {
    // Set a large screen size to ensure all items in ListView are built
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final gameStateManager = TestGameStateManager();
    gameStateManager.setBalance(0);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<GameStateManager>.value(
          value: gameStateManager,
          child: const FacilitiesScreen(),
        ),
      ),
    );

    // Verify Tooltip exists with correct message
    // Cost is 15000 for level 1 -> 2
    expect(find.byTooltip('Insufficient funds (Short by \$15,000)'), findsWidgets);
  });

  testWidgets('FacilitiesScreen shows upgrade tooltip when affordable', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final gameStateManager = TestGameStateManager();
    gameStateManager.setBalance(1000000);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<GameStateManager>.value(
          value: gameStateManager,
          child: const FacilitiesScreen(),
        ),
      ),
    );

    // Expect tooltip "Upgrade for $15,000"
    expect(find.byTooltip('Upgrade for \$15,000'), findsWidgets);
  });
}
