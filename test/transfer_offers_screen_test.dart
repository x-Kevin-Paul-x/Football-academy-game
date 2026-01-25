import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:football_academy_game/Screens/TransferOffersScreen.dart';
import 'package:football_academy_game/game_state_manager.dart';

void main() {
  testWidgets('TransferOffersScreen renders offers and buttons correctly', (WidgetTester tester) async {
    // 1. Setup GameStateManager
    final gameStateManager = GameStateManager();

    // 2. Add a test transfer offer
    // Note: 'sellingClubId' must match playerAcademyId for it to show up.
    gameStateManager.addTestTransferOffer({
      'playerId': 'test_player_1',
      'playerName': 'Test Player',
      'offeringClubName': 'Test Club FC',
      'offeringClubId': 'test_club_1',
      'offerAmount': 50000,
      'sellingClubId': GameStateManager.playerAcademyId,
      'isAIClubOffer': true,
      'dateEpoch': DateTime.now().millisecondsSinceEpoch,
    });

    // 3. Pump the widget
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<GameStateManager>.value(
          value: gameStateManager,
          child: const TransferOffersScreen(),
        ),
      ),
    );

    // 4. Verify the offer is displayed
    expect(find.text('Test Player'), findsOneWidget);
    expect(find.text('Offer from: Test Club FC'), findsOneWidget);

    // 5. Verify Buttons are present
    expect(find.text('Accept'), findsOneWidget);
    expect(find.text('Reject'), findsOneWidget);

    // Verify button types are present
    expect(find.text('Accept'), findsOneWidget);
    expect(find.text('Reject'), findsOneWidget);

    // 6. Verify Tooltips are present
    expect(find.byType(Tooltip), findsNWidgets(2));
    expect(find.byTooltip('Accept offer and sell player'), findsOneWidget);
    expect(find.byTooltip('Reject this offer'), findsOneWidget);
  });

  testWidgets('TransferOffersScreen renders empty state correctly', (WidgetTester tester) async {
      final gameStateManager = GameStateManager();
      // No offers added

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<GameStateManager>.value(
            value: gameStateManager,
            child: const TransferOffersScreen(),
          ),
        ),
      );

      expect(find.text('No transfer offers.'), findsOneWidget);
      expect(find.byIcon(Icons.move_to_inbox), findsOneWidget);
  });
}
