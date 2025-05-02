import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'player.dart';
import 'staff.dart'; // Import Staff
import 'match_event.dart'; // Import MatchEvent

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
  List<String> homeLineup; // List of player IDs
  List<String> awayLineup; // List of player IDs

  // --- NEW: Penalty Shootout Scores ---
  int? homePenaltyScore;
  int? awayPenaltyScore;

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
    List<String>? homeLineup, // Added to constructor
    List<String>? awayLineup, // Added to constructor
    this.homePenaltyScore, // Added to constructor
    this.awayPenaltyScore, // Added to constructor
  }) : eventLog = eventLog ?? [],
       homeLineup = homeLineup ?? [], // Initialize
       awayLineup = awayLineup ?? []; // Initialize

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
  // Added isKnockout parameter
  void simulateDetailed(List<Player> homePlayers, List<Player> awayPlayers, {required bool isKnockout, Staff? playerManager}) {
    if (isSimulated) return; // Don't re-simulate

    // --- Store Lineups ---
    homeLineup = homePlayers.map((p) => p.id).toList();
    awayLineup = awayPlayers.map((p) => p.id).toList();
    // --- End Store Lineups ---

    eventLog.clear(); // Clear previous log if any
    homeScore = 0;
    awayScore = 0;
    homePenaltyScore = null; // Reset penalty scores
    awayPenaltyScore = null;

    if (homePlayers.isEmpty || awayPlayers.isEmpty) {
      print("Warning: Cannot simulate match ${id} due to empty lineup(s).");
      // Assign forfeit?
      if (homePlayers.isEmpty && awayPlayers.isNotEmpty) {
        awayScore = 3; // Away wins by forfeit
        result = MatchResult.awayWin;
        eventLog.add(MatchEvent(playerId: '', teamId: awayTeamId, type: MatchEventType.Info, minute: 0, description: "Home team forfeited."));
      } else if (awayPlayers.isEmpty && homePlayers.isNotEmpty) {
        homeScore = 3; // Home wins by forfeit
        result = MatchResult.homeWin;
         eventLog.add(MatchEvent(playerId: '', teamId: homeTeamId, type: MatchEventType.Info, minute: 0, description: "Away team forfeited."));
      } else {
        // Both empty? Draw 0-0 or cancel? Let's call it a 0-0 draw.
        // If knockout, this scenario should ideally be prevented earlier.
        // But if it happens, force a winner randomly? Or stick to draw? Let's stick to draw for now.
        result = MatchResult.draw;
         eventLog.add(MatchEvent(playerId: '', teamId: '', type: MatchEventType.Info, minute: 0, description: "Both teams forfeited. Match drawn 0-0."));
      }
      isSimulated = true;
      return;
    }

    // 1. Calculate Effective Team Skills (considering fatigue, manager)
    int homeSkill = _calculateEffectiveTeamSkill(homePlayers, playerManager: homeTeamId == GameStateManager.playerAcademyId ? playerManager : null);
    int awaySkill = _calculateEffectiveTeamSkill(awayPlayers, playerManager: awayTeamId == GameStateManager.playerAcademyId ? playerManager : null);

    // 2. Determine Base Goal Expectancy (more sophisticated)
    double skillDiff = (homeSkill - awaySkill).toDouble();
    double homeAdvantage = 0.2; // Base home advantage
    double baseGoalsHome = 1.2 + (skillDiff / 50.0) + homeAdvantage; // Base expectancy around 1.2 goals, modified by skill diff and home advantage
    double baseGoalsAway = 1.2 - (skillDiff / 50.0);
    baseGoalsHome = max(0.1, baseGoalsHome); // Ensure minimum expectancy
    baseGoalsAway = max(0.1, baseGoalsAway);

    // 3. Simulate Goals using Poisson distribution (more realistic scoring)
    final random = Random();
    homeScore = _getPoisson(baseGoalsHome, random);
    awayScore = _getPoisson(baseGoalsAway, random);

    // 4. Simulate Goal Events (Assign scorers/assisters)
    _simulateGoalEvents(homeScore, homePlayers, homeTeamId, random);
    _simulateGoalEvents(awayScore, awayPlayers, awayTeamId, random);

    // 5. Sort Event Log by Minute
    eventLog.sort((a, b) => a.minute.compareTo(b.minute));

    // --- 6. Knockout Draw Resolution ---
    String? shootoutWinnerId;
    if (isKnockout && homeScore == awayScore) {
      print("Knockout match ${id} ended in a draw ($homeScore-$awayScore). Proceeding to penalty shootout...");
      // Simulate shootout
      shootoutWinnerId = _simulatePenaltyShootout(homePlayers, awayPlayers, random);

      String winnerName = shootoutWinnerId == homeTeamId ? "Home" : "Away";
      String eventDescription = "$winnerName team wins penalty shootout ($homePenaltyScore - $awayPenaltyScore).";
      eventLog.add(MatchEvent(playerId: '', teamId: shootoutWinnerId, type: MatchEventType.Info, minute: 91, description: eventDescription)); // Minute 91 indicates shootout result
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
        // If knockout draw resolved by shootout, set winner based on shootout
        result = (shootoutWinnerId == homeTeamId) ? MatchResult.homeWin : MatchResult.awayWin;
        // Note: We keep the original homeScore/awayScore from regular time,
        // but the 'result' and 'winnerId' getter reflect the shootout outcome.
      } else {
        // Regular draw (non-knockout or shootout failed somehow)
        result = MatchResult.draw;
      }
    }

    isSimulated = true;
    // print("Match ${id} simulated: $homeTeamId $homeScore - $awayScore $awayTeamId"); // Less verbose
  }

  // --- NEW: Penalty Shootout Simulation ---
  String _simulatePenaltyShootout(List<Player> homePlayers, List<Player> awayPlayers, Random random) {
    homePenaltyScore = 0;
    awayPenaltyScore = 0;
    int round = 1;
    int homeTaken = 0;
    int awayTaken = 0;

    // Use copies of player lists to track who has taken a penalty
    List<Player> homeTakers = List.from(homePlayers);
    List<Player> awayTakers = List.from(awayPlayers);
    homeTakers.shuffle(random); // Shuffle to vary order
    awayTakers.shuffle(random);

    while (true) {
      bool homeScores = false;
      bool awayScores = false;

      // Home team takes penalty (if available)
      if (homeTaken < homeTakers.length) {
        Player taker = homeTakers[homeTaken];
        double chance = (0.7 + (taker.currentSkill / 400.0) - (taker.fatigue / 500.0)).clamp(0.5, 0.95); // Base 70%, skill up, fatigue down
        homeScores = random.nextDouble() < chance;
        if (homeScores) homePenaltyScore = (homePenaltyScore ?? 0) + 1;
        eventLog.add(MatchEvent(playerId: taker.id, teamId: homeTeamId, type: MatchEventType.PenaltyShootout, minute: 90 + round, description: "Penalty ${homeScores ? 'scored' : 'missed'} by ${taker.name} ($homePenaltyScore-$awayPenaltyScore)"));
        homeTaken++;
      } else if (round > 5) {
          // Ran out of unique takers in sudden death? Should be rare. Award loss? Let's assume enough players.
          print("Warning: Ran out of home penalty takers in shootout for match $id");
      }


      // Check for early win condition after home takes (only after round 3)
      if (round >= 3) {
         int homeRemaining = (round <= 5 ? 5 : round) - homeTaken;
         int awayRemaining = (round <= 5 ? 5 : round) - awayTaken;
         if ((homePenaltyScore ?? 0) > (awayPenaltyScore ?? 0) + awayRemaining) return homeTeamId; // Home wins
         if ((awayPenaltyScore ?? 0) > (homePenaltyScore ?? 0) + homeRemaining) return awayTeamId; // Away wins (checked after away takes)
      }

      // Away team takes penalty (if available)
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

      // Check win condition after both have taken (or should have taken)
      if (round >= 5) {
        if (homeTaken == awayTaken && (homePenaltyScore ?? 0) != (awayPenaltyScore ?? 0)) {
          // End of standard 5 rounds or sudden death round with different scores
          return (homePenaltyScore ?? 0) > (awayPenaltyScore ?? 0) ? homeTeamId : awayTeamId;
        }
      }
       // Check for early win condition after away takes (only after round 3)
      if (round >= 3) {
         int homeRemaining = (round <= 5 ? 5 : round) - homeTaken;
         int awayRemaining = (round <= 5 ? 5 : round) - awayTaken;
         if ((awayPenaltyScore ?? 0) > (homePenaltyScore ?? 0) + homeRemaining) return awayTeamId; // Away wins
      }


      // Reset takers list if everyone has taken once in sudden death
      if (round > 5 && homeTaken >= homeTakers.length && awayTaken >= awayTakers.length) {
          homeTaken = 0;
          awayTaken = 0;
          homeTakers.shuffle(random); // Reshuffle for next cycle
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
      double fatigueModifier = 1.0 - (player.fatigue / 150.0); // Fatigue penalty (up to 66% reduction at 100 fatigue)
      fatigueModifier = fatigueModifier.clamp(0.1, 1.0); // Ensure minimum effectiveness
      totalEffectiveSkill += player.currentSkill * fatigueModifier;
    }
    int averageSkill = (totalEffectiveSkill / players.length).round();

    // Apply manager bonus if applicable
    if (playerManager != null) {
        int managerBonus = (playerManager.skill / 15).floor(); // Slightly higher impact
        averageSkill += managerBonus;
    }

    return averageSkill.clamp(1, 100);
  }

  // Helper to simulate individual goal events
  void _simulateGoalEvents(int goals, List<Player> teamPlayers, String teamId, Random random) {
    if (goals <= 0 || teamPlayers.isEmpty) return;

    // Calculate total skill for weighting scorer/assist chances
    double totalSkill = teamPlayers.fold(0, (sum, p) => sum + p.currentSkill.toDouble());
    if (totalSkill <= 0) totalSkill = 1; // Avoid division by zero

    List<Player> potentialAssisters = List.from(teamPlayers);

    for (int i = 0; i < goals; i++) {
      int minute = 1 + random.nextInt(90);

      // Select Scorer (weighted by skill)
      Player scorer = _selectPlayerWeighted(teamPlayers, totalSkill, random);

      // Select Assister (weighted by skill, cannot be the scorer)
      Player? assister;
      List<Player> eligibleAssisters = potentialAssisters.where((p) => p.id != scorer.id).toList();
      if (eligibleAssisters.isNotEmpty) {
        double assistTotalSkill = eligibleAssisters.fold(0, (sum, p) => sum + p.currentSkill.toDouble());
        if (assistTotalSkill <= 0) assistTotalSkill = 1;
        // 70% chance of an assist occurring for a goal
        if (random.nextDouble() < 0.7) {
           assister = _selectPlayerWeighted(eligibleAssisters, assistTotalSkill, random);
        }
      }

      // Add Goal Event
      eventLog.add(MatchEvent(
        playerId: scorer.id,
        teamId: teamId,
        type: MatchEventType.Goal,
        minute: minute,
        description: "Goal by ${scorer.name}",
        assistedByPlayerId: assister?.id,
      ));

      // Add Assist Event if applicable
      if (assister != null) {
        eventLog.add(MatchEvent(
          playerId: assister.id,
          teamId: teamId,
          type: MatchEventType.Assist,
          minute: minute, // Same minute as goal
          description: "Assist by ${assister.name}",
        ));
      }
    }
  }

  // Helper to select player based on weighted skill
  Player _selectPlayerWeighted(List<Player> players, double totalSkill, Random random) {
    if (players.isEmpty) throw Exception("Cannot select player from empty list"); // Added safety check
    if (totalSkill <= 0) totalSkill = players.length.toDouble(); // Fallback if total skill is 0

    double roll = random.nextDouble() * totalSkill;
    double cumulative = 0;
    for (var player in players) {
      // Use currentSkill, ensure it's at least a small positive value for weighting
      double weight = max(1.0, player.currentSkill.toDouble());
      cumulative += weight;
      if (roll <= cumulative) {
        return player;
      }
    }
    // Fallback (should only happen with rounding errors or zero totalSkill)
    return players.last;
  }


  factory Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);
  Map<String, dynamic> toJson() => _$MatchToJson(this);
}

// --- Dummy GameStateManager for playerAcademyId ---
// This is a workaround to access the constant without a direct dependency.
// Consider passing playerAcademyId into the simulation if needed elsewhere.
class GameStateManager {
  static const String playerAcademyId = 'player_academy_1';
}
