import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('GameStateManager Validation', () {
    late GameStateManager gameStateManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      gameStateManager = GameStateManager();
    });

    test('validateLoadedState truncates long academy name', () {
      final longName = 'A' * 50;
      final input = {'academyName': longName};
      final result = gameStateManager.validateLoadedState(input);
      expect(result['academyName'].length, 25);
      expect(result['academyName'], 'A' * 25);
    });

    test('validateLoadedState resets NaN balance', () {
      final input = {'balance': double.nan};
      final result = gameStateManager.validateLoadedState(input);
      expect(result['balance'], 50000.0);
    });

    test('validateLoadedState resets Infinity balance', () {
      final input = {'balance': double.infinity};
      final result = gameStateManager.validateLoadedState(input);
      expect(result['balance'], 50000.0);
    });

    test('validateLoadedState truncates excessive academy players', () {
      final players = List.generate(250, (index) => {'id': 'p$index'});
      final input = {'academyPlayers': players};
      final result = gameStateManager.validateLoadedState(input);
      expect((result['academyPlayers'] as List).length, 200);
    });

    test('validateLoadedState truncates excessive news items', () {
      final news = List.generate(600, (index) => {'title': 'n$index'});
      final input = {'newsItems': news};
      final result = gameStateManager.validateLoadedState(input);
      expect((result['newsItems'] as List).length, 500);
    });

    test('validateLoadedState keeps valid data intact', () {
      final input = {
        'academyName': 'Valid Name',
        'balance': 1000.0,
        'academyPlayers': [{'id': 'p1'}],
        'newsItems': [{'title': 'n1'}]
      };
      final result = gameStateManager.validateLoadedState(Map.from(input));
      expect(result['academyName'], 'Valid Name');
      expect(result['balance'], 1000.0);
      expect((result['academyPlayers'] as List).length, 1);
      expect((result['newsItems'] as List).length, 1);
    });
  });
}
