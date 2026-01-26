import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/models/player.dart';
import 'package:football_academy_game/models/staff.dart';

void main() {
  group('Coach Assignment Optimization Tests', () {
    late GameStateManager gameStateManager;

    setUp(() {
      gameStateManager = GameStateManager();
      gameStateManager.resetGame();
    });

    test('assignPlayerToCoach and getCoachForPlayer work correctly', () {
      // 1. Create and Hire a Coach
      final coach = Staff.randomStaff('coach_1', StaffRole.Coach);
      // Ensure we can hire (resetGame sets maxCoaches to 1, currently hired is 0)
      bool hired = gameStateManager.hireStaff(coach);
      expect(hired, isTrue, reason: "Coach should be hired");

      // 2. Create and Sign a Player
      final player = Player.createWithTargetSkill(
          id: 'player_1',
          name: 'Test Player',
          age: 18,
          naturalPosition: PlayerPosition.Forward,
          targetSkill: 50,
          potentialSkill: 80,
          weeklyWage: 100,
          reputation: 10);
      gameStateManager.signPlayer(player);

      // signPlayer might auto-assign if there is capacity. Unassign to be sure.
      gameStateManager.unassignPlayerFromAnyCoach(player.id);
      expect(gameStateManager.getCoachForPlayer(player.id), isNull, reason: "Player should be unassigned");

      // 3. Assign Player to Coach
      bool assigned = gameStateManager.assignPlayerToCoach(player.id, coach.id);
      expect(assigned, isTrue, reason: "Assignment should succeed");

      // 4. Verify getCoachForPlayer returns the correct coach
      final retrievedCoach = gameStateManager.getCoachForPlayer(player.id);
      expect(retrievedCoach, isNotNull);
      expect(retrievedCoach!.id, coach.id);

      // 5. Verify internal state of coach (double check)
      final internalCoach = gameStateManager.hiredStaff.firstWhere((s) => s.id == coach.id);
      expect(internalCoach.assignedPlayerIds, contains(player.id));
    });

    test('unassignPlayerFromCoach updates state correctly', () {
      // Setup
      final coach = Staff.randomStaff('coach_1', StaffRole.Coach);
      gameStateManager.hireStaff(coach);
      final player = Player.createWithTargetSkill(id: 'player_1', name: 'P1', age: 18, naturalPosition: PlayerPosition.Midfielder, targetSkill: 50, potentialSkill: 60, weeklyWage: 100, reputation: 0);
      gameStateManager.signPlayer(player);
      gameStateManager.unassignPlayerFromAnyCoach(player.id);
      gameStateManager.assignPlayerToCoach(player.id, coach.id);

      expect(gameStateManager.getCoachForPlayer(player.id)?.id, coach.id);

      // Action: Unassign
      bool unassigned = gameStateManager.unassignPlayerFromCoach(player.id, coach.id);
      expect(unassigned, isTrue);

      // Verify
      expect(gameStateManager.getCoachForPlayer(player.id), isNull);
      final internalCoach = gameStateManager.hiredStaff.firstWhere((s) => s.id == coach.id);
      expect(internalCoach.assignedPlayerIds, isNot(contains(player.id)));
    });

    test('fireStaff should unassign players', () {
      // Setup
      final coach = Staff.randomStaff('coach_fire', StaffRole.Coach);
      gameStateManager.hireStaff(coach);
      final player = Player.createWithTargetSkill(id: 'player_fire', name: 'P_Fire', age: 18, naturalPosition: PlayerPosition.Midfielder, targetSkill: 50, potentialSkill: 60, weeklyWage: 100, reputation: 0);
      gameStateManager.signPlayer(player);
      gameStateManager.unassignPlayerFromAnyCoach(player.id);
      gameStateManager.assignPlayerToCoach(player.id, coach.id);

      expect(gameStateManager.getCoachForPlayer(player.id)?.id, coach.id);

      // Action: Fire Staff
      gameStateManager.fireStaff(coach);

      // Verify
      expect(gameStateManager.getCoachForPlayer(player.id), isNull);
    });
  });
}
