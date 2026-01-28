import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:football_academy_game/Screens/TransferOffersScreen.dart';
import 'package:football_academy_game/game_state_manager.dart';

void main() {
  testWidgets('TransferOffersScreen displays offers and has tooltips', (WidgetTester tester) async {
    // 1. Setup GameStateManager
    final gameStateManager = GameStateManager();

    // 2. Add a test offer
    // Ensure sellingClubId matches the player's academy ID
    gameStateManager.addTestTransferOffer({
      'playerId': 'test_player_1',
      'playerName': 'Test Player',
      'offeringClubName': 'Test Club',
      'offeringClubId': 'club_1',
      'offerAmount': 100000,
      'sellingClubId': GameStateManager.playerAcademyId,
      'dateEpoch': DateTime.now().millisecondsSinceEpoch,
    });

    // 3. Pump Widget
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<GameStateManager>.value(
          value: gameStateManager,
          child: const TransferOffersScreen(),
        ),
      ),
    );

    // 4. Verify Offer Display
    expect(find.text('Test Player'), findsOneWidget);
    expect(find.text('Offer from: Test Club'), findsOneWidget);
    // Note: Currency formatting might vary, checking simpler parts or using flexible finder if needed.
    // Given the US locale in the app, it should be $100,000.00
    expect(find.textContaining('\$100,000.00'), findsOneWidget);

    // 5. Verify Tooltips
    // This expects the code changes to be applied. Since they are not applied yet, this test should FAIL initially.
    // Or I can write the test to expect them, and then implement.
    expect(find.byTooltip('Reject this transfer offer'), findsOneWidget);
    expect(find.byTooltip('Accept this transfer offer'), findsOneWidget);
  });
}
