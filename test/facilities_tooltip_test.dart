import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:football_academy_game/Screens/FacilitiesScreen.dart';
import 'package:football_academy_game/game_state_manager.dart';

class FakeGameStateManager extends GameStateManager {
  double _testBalance = 0;

  @override
  double get balance => _testBalance;

  void setTestBalance(double amount) {
    _testBalance = amount;
    notifyListeners();
  }
}

void main() {
  testWidgets('FacilitiesScreen shows tooltip with cost when affordable', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    final fakeManager = FakeGameStateManager();
    fakeManager.setTestBalance(20000); // 20k > 15k cost

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<GameStateManager>.value(
          value: fakeManager,
          child: const FacilitiesScreen(),
        ),
      ),
    );

    // Verify tooltips exist
    final tooltipFinder = find.byType(Tooltip);
    expect(tooltipFinder, findsWidgets);

    // Get the first tooltip (Training Facility)
    // The list order is Training, Scouting, Medical, Merchandise.
    final firstTooltip = tester.widget<Tooltip>(tooltipFinder.first);

    // Expect upgrade message
    expect(firstTooltip.message, contains('Upgrade Training Facility'));
    expect(firstTooltip.message, contains('Level 2'));

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets('FacilitiesScreen shows tooltip with missing funds when not affordable', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    final fakeManager = FakeGameStateManager();
    fakeManager.setTestBalance(5000); // 5k < 15k cost. Missing 10k.

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<GameStateManager>.value(
          value: fakeManager,
          child: const FacilitiesScreen(),
        ),
      ),
    );

    // Verify tooltips exist
    final tooltipFinder = find.byType(Tooltip);
    expect(tooltipFinder, findsWidgets);

    // Get the first tooltip (Training Facility)
    final firstTooltip = tester.widget<Tooltip>(tooltipFinder.first);

    // Expect insufficient funds message
    expect(firstTooltip.message, contains('Insufficient funds'));
    expect(firstTooltip.message, contains('10,000'));

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
