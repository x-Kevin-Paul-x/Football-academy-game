import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'player.dart';
import 'staff.dart'; // Import Staff
import 'match_event.dart'; // Import MatchEvent
import 'formation.dart'; // <-- Import Formation

part 'match.g.dart';

enum MatchResult { homeWin, awayWin, draw }

@JsonSerializable(explicitToJson: true)
class Match {
  final String id;
  final String tournamentId;
  final int round; // Round number within the tournament
  final DateTime matchDate;
  final String homeTeamId;
  final String awayTeamId;

  // Result fields (populated after simulation)
  bool isSimulated;
  MatchResult? result;
  int homeScore;
  int awayScore;
  List<MatchEvent> eventLog; // Log of goals, assists, etc.

  // --- NEW: Store lineups used in simulation ---
  List<String> homeLineup; // List of player IDs (Starters)
  List<String> awayLineup; // List of player IDs (Starters)

  // --- NEW: Penalty Shootout Scores ---
  int? homePenaltyScore;
  int? awayPenaltyScore;

  // --- NEW: Formation and Bench ---
  Formation? homeFormation; // Store the actual Formation object used
  Formation? awayFormation; // Store the actual Formation object used
  List<String> homeBench; // List of player IDs on the bench
  List<String> awayBench; // List of player IDs on the bench

  Match({
    required this.id,
    required this.tournamentId,
    required this.round,
    required this.matchDate,
    required this.homeTeamId,
    required this.awayTeamId,
    this.isSimulated = false,
    this.result,
    this.homeScore = 0,
    this.awayScore = 0,
    List<MatchEvent>? eventLog,
    List<String>? homeLineup, // Starters
    List<String>? awayLineup, // Starters
    this.homePenaltyScore,
    this.awayPenaltyScore,
    this.homeFormation, // Pass Formation object
    this.awayFormation, // Pass Formation object
    List<String>? homeBench,
    List<String>? awayBench,
  }) : eventLog = eventLog ?? [],
       homeLineup = homeLineup ?? [], // Initialize starters
       awayLineup = awayLineup ?? [], // Initialize starters
       homeBench = homeBench ?? [], // Initialize bench
       awayBench = awayBench ?? []; // Initialize bench

  // --- NEW: Winner ID Getter ---
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get winnerId {
    if (!isSimulated || result == null) return null;
    switch (result!) {
      case MatchResult.homeWin:
        return homeTeamId;
      case MatchResult.awayWin:
        return awayTeamId;
      case MatchResult.draw:
        // If a shootout occurred, determine winner from that
        if (homePenaltyScore != null && awayPenaltyScore != null) {
          if (homePenaltyScore! > awayPenaltyScore!) return homeTeamId;
          if (awayPenaltyScore! > homePenaltyScore!) return awayTeamId;
        }
        // Otherwise (non-knockout draw or error), return null
        return null;
    }
  }
  // --- END NEW ---

  // Detailed Simulation Logic
  // TODO: Update this method to accept selected formations and benches
  // Added isKnockout parameter
  void simulateDetailed(List<Player> homeStarters, List<Player> awayStarters, {required bool isKnockout, Staff? playerManager, Formation? homeFormationUsed, Formation? awayFormationUsed, List<Player>? homeBenchPlayers, List<Player>? awayBenchPlayers}) {
    if (isSimulated) return; // Don't re-simulate

    // --- Store Lineups, Bench, and Formation ---
    homeLineup = homeStarters.map((p) => p.id).toList();
    awayLineup = awayStarters.map((p) => p.id).toList();
    homeBench = homeBenchPlayers?.map((p) => p.id).toList() ?? [];
    awayBench = awayBenchPlayers?.map((p) => p.id).toList() ?? [];
    homeFormation = homeFormationUsed;
    awayFormation = awayFormationUsed;
    // --- End Store ---

    eventLog.clear(); // Clear previous log if any
    homeScore = 0;
    awayScore = 0;
    homePenaltyScore = null; // Reset penalty scores
    awayPenaltyScore = null;

    if (homeStarters.isEmpty || awayStarters.isEmpty) {
      print("Warning: Cannot simulate match ${id} due to empty starting lineup(s).");
      // Assign forfeit?
      if (homeStarters.isEmpty && awayStarters.isNotEmpty) {
        awayScore = 3; // Away wins by forfeit
        result = MatchResult.awayWin;
        eventLog.add(MatchEvent(playerId: '', teamId: awayTeamId, type: MatchEventType.Info, minute: 0, description: "Home team forfeited."));
      } else if (awayStarters.isEmpty && homeStarters.isNotEmpty) {
        homeScore = 3; // Home wins by forfeit
        result = MatchResult.homeWin;
         eventLog.add(MatchEvent(playerId: '', teamId: homeTeamId, type: MatchEventType.Info, minute: 0, description: "Away team forfeited."));
      } else {
        // Both empty? Draw 0-0 or cancel? Let's call it a 0-0 draw.
        result = MatchResult.draw;
         eventLog.add(MatchEvent(playerId: '', teamId: '', type: MatchEventType.Info, minute: 0, description: "Both teams forfeited. Match drawn 0-0."));
      }
      isSimulated = true;
      return;
    }

    // TODO: Implement Halftime Substitutions here
    // - Check fatigue of starters around halftime (minute 45)
    // - Identify 1-2 most fatigued players
    // - Select best available replacements from the bench (consider position, skill, fatigue)
    // - Update homeStarters/awayStarters lists (or create copies for second half)
    // - Log substitution events

    // 1. Calculate Effective Team Skills (considering fatigue, manager, formation bonus?)
    // TODO: Potentially add formation bonus/penalty based on player fit
    int homeSkill = _calculateEffectiveTeamSkill(homeStarters, playerManager: homeTeamId == GameStateManager.playerAcademyId ? playerManager : null);
    int awaySkill = _calculateEffectiveTeamSkill(awayStarters, playerManager: awayTeamId == GameStateManager.playerAcademyId ? playerManager : null);

    // 2. Determine Base Goal Expectancy
    double skillDiff = (homeSkill - awaySkill).toDouble();
    double homeAdvantage = 0.2;
    double baseGoalsHome = 1.2 + (skillDiff / 50.0) + homeAdvantage;
    double baseGoalsAway = 1.2 - (skillDiff / 50.0);
    baseGoalsHome = max(0.1, baseGoalsHome);
    baseGoalsAway = max(0.1, baseGoalsAway);

    // 3. Simulate Goals using Poisson distribution
    final random = Random();
    homeScore = _getPoisson(baseGoalsHome, random);
    awayScore = _getPoisson(baseGoalsAway, random);

    // 4. Simulate Goal Events (Assign scorers/assisters)
    // TODO: Update to consider players involved in the *entire* match (including subs) if needed for stats?
    // For now, using starters for simplicity, but this needs refinement post-substitution logic.
    _simulateGoalEvents(homeScore, homeStarters, homeTeamId, random);
    _simulateGoalEvents(awayScore, awayStarters, awayTeamId, random);

    // 5. Sort Event Log by Minute
    eventLog.sort((a, b) => a.minute.compareTo(b.minute));

    // --- 6. Knockout Draw Resolution ---
    String? shootoutWinnerId;
    if (isKnockout && homeScore == awayScore) {
      print("Knockout match ${id} ended in a draw ($homeScore-$awayScore). Proceeding to penalty shootout...");
      // Simulate shootout (using final players on pitch if subs implemented, else starters)
      shootoutWinnerId = _simulatePenaltyShootout(homeStarters, awayStarters, random);

      String winnerName = shootoutWinnerId == homeTeamId ? "Home" : "Away";
      String eventDescription = "$winnerName team wins penalty shootout ($homePenaltyScore - $awayPenaltyScore).";
      eventLog.add(MatchEvent(playerId: '', teamId: shootoutWinnerId, type: MatchEventType.Info, minute: 91, description: eventDescription));
      print(" -> Penalty shootout completed. Winner: $shootoutWinnerId ($homePenaltyScore - $awayPenaltyScore)");
    }
    // --- End Knockout Draw Resolution ---

    // 7. Determine Final Match Result
    if (homeScore > awayScore) {
      result = MatchResult.homeWin;
    } else if (awayScore > homeScore) {
      result = MatchResult.awayWin;
    } else {
      // Draw occurred
      if (isKnockout && shootoutWinnerId != null) {
        result = (shootoutWinnerId == homeTeamId) ? MatchResult.homeWin : MatchResult.awayWin;
      } else {
        result = MatchResult.draw;
      }
    }

    isSimulated = true;
  }

  // --- NEW: Penalty Shootout Simulation ---
  String _simulatePenaltyShootout(List<Player> homePlayersOnPitch, List<Player> awayPlayersOnPitch, Random random) {
    homePenaltyScore = 0;
    awayPenaltyScore = 0;
    int round = 1;
    int homeTaken = 0;
    int awayTaken = 0;

    List<Player> homeTakers = List.from(homePlayersOnPitch);
    List<Player> awayTakers = List.from(awayPlayersOnPitch);
    homeTakers.shuffle(random);
    awayTakers.shuffle(random);

    while (true) {
      bool homeScores = false;
      bool awayScores = false;

      if (homeTaken < homeTakers.length) {
        Player taker = homeTakers[homeTaken];
        double chance = (0.7 + (taker.currentSkill / 400.0) - (taker.fatigue / 500.0)).clamp(0.5, 0.95);
        homeScores = random.nextDouble() < chance;
        if (homeScores) homePenaltyScore = (homePenaltyScore ?? 0) + 1;
        eventLog.add(MatchEvent(playerId: taker.id, teamId: homeTeamId, type: MatchEventType.PenaltyShootout, minute: 90 + round, description: "Penalty ${homeScores ? 'scored' : 'missed'} by ${taker.name} ($homePenaltyScore-$awayPenaltyScore)"));
        homeTaken++;
      } else if (round > 5) {
          print("Warning: Ran out of home penalty takers in shootout for match $id");
      }

      if (round >= 3) {
         int homeRemaining = (round <= 5 ? 5 : round) - homeTaken;
         int awayRemaining = (round <= 5 ? 5 : round) - awayTaken;
         if ((homePenaltyScore ?? 0) > (awayPenaltyScore ?? 0) + awayRemaining) return homeTeamId;
         if ((awayPenaltyScore ?? 0) > (homePenaltyScore ?? 0) + homeRemaining) return awayTeamId;
      }

      if (awayTaken < awayTakers.length) {
        Player taker = awayTakers[awayTaken];
        double chance = (0.7 + (taker.currentSkill / 400.0) - (taker.fatigue / 500.0)).clamp(0.5, 0.95);
        awayScores = random.nextDouble() < chance;
        if (awayScores) awayPenaltyScore = (awayPenaltyScore ?? 0) + 1;
        eventLog.add(MatchEvent(playerId: taker.id, teamId: awayTeamId, type: MatchEventType.PenaltyShootout, minute: 90 + round, description: "Penalty ${awayScores ? 'scored' : 'missed'} by ${taker.name} ($homePenaltyScore-$awayPenaltyScore)"));
        awayTaken++;
      } else if (round > 5) {
          print("Warning: Ran out of away penalty takers in shootout for match $id");
      }

      if (round >= 5) {
        if (homeTaken == awayTaken && (homePenaltyScore ?? 0) != (awayPenaltyScore ?? 0)) {
          return (homePenaltyScore ?? 0) > (awayPenaltyScore ?? 0) ? homeTeamId : awayTeamId;
        }
      }
      if (round >= 3) {
         int homeRemaining = (round <= 5 ? 5 : round) - homeTaken;
         int awayRemaining = (round <= 5 ? 5 : round) - awayTaken;
         if ((awayPenaltyScore ?? 0) > (homePenaltyScore ?? 0) + homeRemaining) return awayTeamId;
      }

      if (round > 5 && homeTaken >= homeTakers.length && awayTaken >= awayTakers.length) {
          homeTaken = 0;
          awayTaken = 0;
          homeTakers.shuffle(random);
          awayTakers.shuffle(random);
      }

      round++;
    }
  }
  // --- End Penalty Shootout Simulation ---

  // Helper for Poisson calculation
  int _getPoisson(double lambda, Random random) {
    double l = exp(-lambda);
    int k = 0;
    double p = 1.0;
    do {
      k++;
      p *= random.nextDouble();
    } while (p > l);
    return k - 1;
  }

  // Helper to calculate effective skill considering fatigue
  int _calculateEffectiveTeamSkill(List<Player> players, {Staff? playerManager}) {
    if (players.isEmpty) return 10;
    double totalEffectiveSkill = 0;
    for (var player in players) {
      double fatigueModifier = 1.0 - (player.fatigue / 150.0);
      fatigueModifier = fatigueModifier.clamp(0.1, 1.0);
      totalEffectiveSkill += player.currentSkill * fatigueModifier;
    }
    int averageSkill = (totalEffectiveSkill / players.length).round();

    if (playerManager != null) {
        int managerBonus = (playerManager.skill / 15).floor();
        averageSkill += managerBonus;
    }

    return averageSkill.clamp(1, 100);
  }

  // Helper to simulate individual goal events
  void _simulateGoalEvents(int goals, List<Player> teamPlayers, String teamId, Random random) {
    if (goals <= 0 || teamPlayers.isEmpty) return;

    double totalSkill = teamPlayers.fold(0, (sum, p) => sum + p.currentSkill.toDouble());
    if (totalSkill <= 0) totalSkill = 1;

    List<Player> potentialAssisters = List.from(teamPlayers);

    for (int i = 0; i < goals; i++) {
      int minute = 1 + random.nextInt(90);

      Player scorer = _selectPlayerWeighted(teamPlayers, totalSkill, random);

      Player? assister;
      List<Player> eligibleAssisters = potentialAssisters.where((p) => p.id != scorer.id).toList();
      if (eligibleAssisters.isNotEmpty) {
        double assistTotalSkill = eligibleAssisters.fold(0, (sum, p) => sum + p.currentSkill.toDouble());
        if (assistTotalSkill <= 0) assistTotalSkill = 1;
        if (random.nextDouble() < 0.7) {
           assister = _selectPlayerWeighted(eligibleAssisters, assistTotalSkill, random);
        }
      }

      eventLog.add(MatchEvent(
        playerId: scorer.id,
        teamId: teamId,
        type: MatchEventType.Goal,
        minute: minute,
        description: "Goal by ${scorer.name}",
        assistedByPlayerId: assister?.id,
      ));

      if (assister != null) {
        eventLog.add(MatchEvent(
          playerId: assister.id,
          teamId: teamId,
          type: MatchEventType.Assist,
          minute: minute,
          description: "Assist by ${assister.name}",
        ));
      }
    }
  }

  // Helper to select player based on weighted skill
  Player _selectPlayerWeighted(List<Player> players, double totalSkill, Random random) {
    if (players.isEmpty) throw Exception("Cannot select player from empty list");
    if (totalSkill <= 0) totalSkill = players.length.toDouble();

    double roll = random.nextDouble() * totalSkill;
    double cumulative = 0;
    for (var player in players) {
      double weight = max(1.0, player.currentSkill.toDouble());
      cumulative += weight;
      if (roll <= cumulative) {
        return player;
      }
    }
    return players.last;
  }

  factory Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);
  Map<String, dynamic> toJson() => _$MatchToJson(this);
}

// --- Dummy GameStateManager for playerAcademyId ---
class GameStateManager {
  static const String playerAcademyId = 'player_academy_1';
}
