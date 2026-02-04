import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:football_academy_game/Screens/FacilitiesScreen.dart';
import 'package:football_academy_game/game_state_manager.dart';

// Stub class to avoid full initialization and mock values
class TestGameStateManager extends GameStateManager {
  double _testBalance = 0;
  final int _testTrainingLevel = 1;

  @override
  double get balance => _testBalance;

  @override
  int get trainingFacilityLevel => _testTrainingLevel;

  @override
  int getTrainingFacilityUpgradeCost() => 1000;

  @override
  int get scoutingFacilityLevel => 1;
  @override
  int getScoutingFacilityUpgradeCost() => 1000;

  @override
  int get medicalBayLevel => 1;
  @override
  int getMedicalBayUpgradeCost() => 1000;

  @override
  int get merchandiseStoreLevel => 1;
  @override
  int getMerchandiseStoreUpgradeCost() => 1000;

  @override
  int get maxStoreManagers => 1;

  void setBalance(double value) {
    _testBalance = value;
    notifyListeners();
  }
}

void main() {
  testWidgets('FacilitiesScreen shows disabled button WITH tooltip for insufficient funds', (WidgetTester tester) async {
    final testManager = TestGameStateManager();
    testManager.setBalance(500.0); // Cost is 1000, so short by 500

    await tester.pumpWidget(
      ChangeNotifierProvider<GameStateManager>.value(
        value: testManager,
        child: const MaterialApp(
          home: FacilitiesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Debugging: Check if Screen title exists
    expect(find.text('Academy Facilities'), findsOneWidget);

    // Debugging: Check if ListView exists
    expect(find.byType(ListView), findsOneWidget);

    // Debugging: Check for Card and Text
    expect(find.byType(Card), findsWidgets);
    expect(find.text('Training Facility'), findsWidgets);

    // Verify "Upgrade" text exists, implying buttons are rendered
    expect(find.text('Upgrade'), findsWidgets);

    // Verify Tooltip DOES exist (Verification of fix)
    // We expect multiple widgets (one for each facility card that fits on screen)
    final tooltipFinder = find.byTooltip('Insufficient funds (Short by \$500)');
    expect(tooltipFinder, findsWidgets);
  });

  testWidgets('FacilitiesScreen shows normal tooltip when upgrade is affordable', (WidgetTester tester) async {
    final testManager = TestGameStateManager();
    testManager.setBalance(2000.0); // Cost is 1000, so can afford

    await tester.pumpWidget(
      ChangeNotifierProvider<GameStateManager>.value(
        value: testManager,
        child: const MaterialApp(
          home: FacilitiesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Upgrade button exists
    expect(find.text('Upgrade'), findsWidgets);

    // Verify Tooltip for affordable upgrade
    // "Upgrade to Level 2" (Current level is 1)
    final tooltipFinder = find.byTooltip('Upgrade to Level 2');
    expect(tooltipFinder, findsWidgets);
  });
}
