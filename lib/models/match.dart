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
        return null; // No winner on draw
    }
  }
  // --- END NEW ---


  // Detailed Simulation Logic
  void simulateDetailed(List<Player> homePlayers, List<Player> awayPlayers, {Staff? playerManager}) {
    if (isSimulated) return; // Don't re-simulate

    // --- Store Lineups ---
    homeLineup = homePlayers.map((p) => p.id).toList();
    awayLineup = awayPlayers.map((p) => p.id).toList();
    // --- End Store Lineups ---


    eventLog.clear(); // Clear previous log if any
    homeScore = 0;
    awayScore = 0;

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

    // 6. Determine Match Result
    if (homeScore > awayScore) {
      result = MatchResult.homeWin;
    } else if (awayScore > homeScore) {
      result = MatchResult.awayWin;
    } else {
      result = MatchResult.draw;
    }

    isSimulated = true;
    // print("Match ${id} simulated: $homeTeamId $homeScore - $awayScore $awayTeamId"); // Less verbose
  }

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
    double roll = random.nextDouble() * totalSkill;
    double cumulative = 0;
    for (var player in players) {
      cumulative += player.currentSkill;
      if (roll <= cumulative) {
        return player;
      }
    }
    // Fallback (shouldn't happen with valid totalSkill)
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
