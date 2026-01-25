import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/widgets/empty_state.dart';
import 'package:football_academy_game/Screens/PlayerManagementScreen.dart';
import 'package:football_academy_game/Screens/StaffManagementScreen.dart';
import 'package:football_academy_game/Screens/TournamentsScreen.dart';

void main() {
  group('Empty State Integration Tests', () {
    late GameStateManager gameStateManager;

    setUp(() {
      gameStateManager = GameStateManager();
    });

    Widget createTestWidget(Widget child) {
      return ChangeNotifierProvider<GameStateManager>.value(
        value: gameStateManager,
        child: MaterialApp(
          home: child,
        ),
      );
    }

    testWidgets('PlayerManagementScreen shows EmptyState when no players', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PlayerManagementScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyState), findsOneWidget);
    });

    testWidgets('StaffManagementScreen shows EmptyState for empty lists', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const StaffManagementScreen()));
      await tester.pumpAndSettle();

      // Should find at least one EmptyState (likely for Hired Staff tab which is default)
      expect(find.byType(EmptyState), findsAtLeastNWidgets(1));
    });

    testWidgets('TournamentsScreen shows EmptyState when no tournaments in History', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const TournamentsScreen()));
      await tester.pumpAndSettle();

      // Initially on "Available" tab, which has templates, so NO EmptyState
      expect(find.byType(EmptyState), findsNothing);

      // Tap on "History" tab
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      // Now we should see EmptyState because completedTournaments is empty
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No completed tournaments.'), findsOneWidget);
    });
  });
}
