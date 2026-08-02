import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:football_academy_game/main.dart';
import 'package:football_academy_game/game_state_manager.dart';

void main() {
  testWidgets('Start screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<GameStateManager>(
        create: (_) => GameStateManager(),
        child: const MyApp(),
      ),
    );

    // Verify that the StartScreen is shown with expected title and buttons.
    expect(find.text('FOOTBALL ACADEMY'), findsOneWidget);
    expect(find.text('Start New Career'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
  });
}
