import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:football_academy_game/Screens/FacilitiesScreen.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock GameStateManager to control state
class MockGameStateManager extends GameStateManager {
  @override
  double get balance => _balance;
  double _balance = 50000.0;

  void setBalance(double newBalance) {
    _balance = newBalance;
    notifyListeners();
  }

  @override
  int get trainingFacilityLevel => 1;
  @override
  int getTrainingFacilityUpgradeCost() => 15000;
  @override
  int get scoutingFacilityLevel => 1;
  @override
  int getScoutingFacilityUpgradeCost() => 15000;
  @override
  int get medicalBayLevel => 1;
  @override
  int getMedicalBayUpgradeCost() => 15000;
  @override
  int get merchandiseStoreLevel => 1;
  @override
  int getMerchandiseStoreUpgradeCost() => 15000;
  @override
  int get maxStoreManagers => 1;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('FacilitiesScreen upgrade button disabled state test', (WidgetTester tester) async {
    // Ensure large enough screen
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockGameStateManager = MockGameStateManager();

    // Set low balance
    mockGameStateManager.setBalance(0.0);

    await tester.pumpWidget(
      ChangeNotifierProvider<GameStateManager>.value(
        value: mockGameStateManager,
        child: MaterialApp(
          home: const FacilitiesScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify ListView exists
    expect(find.byType(ListView), findsOneWidget);

    // Check if texts are found
    expect(find.text('Training Facility'), findsOneWidget);
    expect(find.text('Upgrade to Level 2'), findsAtLeastNWidgets(1));

    // Verify "Upgrade" label exists
    final upgradeLabelFinder = find.text('Upgrade');
    expect(upgradeLabelFinder, findsAtLeastNWidgets(1));

    // Verify tooltip wraps the button
    final tooltipFinder = find.ancestor(
      of: upgradeLabelFinder.first,
      matching: find.byType(Tooltip),
    );
    expect(tooltipFinder, findsOneWidget);

    final Tooltip tooltip = tester.widget(tooltipFinder);
    expect(tooltip.message, contains('Insufficient funds'));
    expect(tooltip.message, contains('\$15,000.00'));
  });

  testWidgets('FacilitiesScreen upgrade button enabled state test', (WidgetTester tester) async {
    // Ensure large enough screen
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockGameStateManager = MockGameStateManager();

    // Set high balance
    mockGameStateManager.setBalance(100000.0);

    await tester.pumpWidget(
      ChangeNotifierProvider<GameStateManager>.value(
        value: mockGameStateManager,
        child: MaterialApp(
          home: const FacilitiesScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify "Upgrade" label exists
    final upgradeLabelFinder = find.text('Upgrade');
    expect(upgradeLabelFinder, findsAtLeastNWidgets(1));

    // Verify tooltip wraps the button
    final tooltipFinder = find.ancestor(
      of: upgradeLabelFinder.first,
      matching: find.byType(Tooltip),
    );
    expect(tooltipFinder, findsOneWidget);

    final Tooltip tooltip = tester.widget(tooltipFinder);
    expect(tooltip.message, contains('Upgrade Training Facility to Level 2'));
  });
}
