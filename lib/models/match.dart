import 'dart:math'; // Import Random
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart'; // Added for JSON serialization
import 'ai_club.dart'; // Assuming AIClub model exists
import 'match_event.dart'; // Import the new MatchEvent model
import 'player.dart'; // *** Ensure Player model is imported ***

part 'match.g.dart'; // Added for generated code

enum MatchResult { homeWin, awayWin, draw }

@JsonSerializable(explicitToJson: true) // Added annotation, explicitToJson needed for List<MatchEvent>
class Match {
  final String id;
  final String tournamentId; // Link back to the tournament
  final String homeTeamId; // Could be player's academy ID or AIClub ID
  final String awayTeamId; // Could be player's academy ID or AIClub ID
  final DateTime matchDate; // Needs standard format for JSON
  int homeScore;
  int awayScore;
  MatchResult? result;
  bool isSimulated;

  // --- Detailed Simulation Fields ---
  List<String> homeLineup = []; // List of player IDs
  List<String> awayLineup = []; // List of player IDs
  List<MatchEvent> eventLog = []; // Log of significant events
  // TODO: Add detailed stats maps (goals, assists, etc.) per player?
  // ---

  Match({
    required this.id,
    required this.tournamentId,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.matchDate,
    this.homeScore = 0,
    this.awayScore = 0,
    this.result,
    this.isSimulated = false,
    // Initialize new fields, defaulting to empty lists
    List<String>? homeLineup,
    List<String>? awayLineup,
    List<MatchEvent>? eventLog,
  }) : this.homeLineup = homeLineup ?? [],
       this.awayLineup = awayLineup ?? [],
       this.eventLog = eventLog ?? [];

  // Method for detailed minute-by-minute simulation
  // This method should NOT be part of the JSON serialization
  @JsonKey(includeFromJson: false, includeToJson: false)
  void simulateDetailed(List<Player> homeTeamLineup, List<Player> awayTeamLineup) {
    if (isSimulated) return; // Don't re-simulate

    print("Starting detailed simulation for Match ${id}...");

    // --- 1. Preparation ---
    this.homeLineup = homeTeamLineup.map((p) => p.id).toList(); // Store IDs
    this.awayLineup = awayTeamLineup.map((p) => p.id).toList(); // Store IDs
    eventLog.clear(); // Clear previous log if any
    homeScore = 0;
    awayScore = 0;
    // Reset player match stats for players involved in this match
    for (var player in homeTeamLineup) {
      player.matchGoals = 0;
      player.matchAssists = 0;
      // Reset other stats if added
    }
     for (var player in awayTeamLineup) {
      player.matchGoals = 0;
      player.matchAssists = 0;
      // Reset other stats if added
    }

    final random = Random(); // Keep random generator

    const int matchDuration = 90; // Minutes
    const double homeAdvantageFactor = 1.05; // Define ONCE for detailed sim

    // Calculate average team skills from lineups
    double avgHomeSkill = homeTeamLineup.isEmpty ? 10 : homeTeamLineup.fold(0.0, (sum, p) => sum + p.currentSkill) / homeTeamLineup.length;
    double avgAwaySkill = awayTeamLineup.isEmpty ? 10 : awayTeamLineup.fold(0.0, (sum, p) => sum + p.currentSkill) / awayTeamLineup.length;

    avgHomeSkill *= homeAdvantageFactor; // Apply home advantage

    // --- 2. Simulation Loop ---
    eventLog.add(MatchEvent(minute: 0, type: MatchEventType.KickOff, teamId: homeTeamId, description: "Match Kicks Off!"));

    for (int minute = 1; minute <= matchDuration; minute++) {
      // --- Event Generation Logic ---
      double eventChance = 0.1 + ((avgHomeSkill + avgAwaySkill) / 2000); // Base chance + skill influence
      if (random.nextDouble() < eventChance) {
        double totalSkill = avgHomeSkill + avgAwaySkill;
        double homeInitiativeChance = totalSkill > 0 ? avgHomeSkill / totalSkill : 0.5;
        bool homeInitiates = random.nextDouble() < homeInitiativeChance;
        String initiatingTeamId = homeInitiates ? homeTeamId : awayTeamId;
        List<Player> initiatingLineup = homeInitiates ? homeTeamLineup : awayTeamLineup;
        List<Player> defendingLineup = homeInitiates ? awayTeamLineup : homeTeamLineup;

        double goalAttemptChance = 0.3; // Chance the event is a goal attempt

        if (random.nextDouble() < goalAttemptChance && initiatingLineup.isNotEmpty) {
          Player attacker = initiatingLineup[random.nextInt(initiatingLineup.length)]; // Simple random attacker
          double avgDefenderSkill = defendingLineup.isEmpty ? 10 : defendingLineup.fold(0.0, (sum, p) => sum + p.currentSkill) / defendingLineup.length;
          double goalProb = 0.1 + (attacker.currentSkill - avgDefenderSkill) / 200; // Basic skill difference influence
          goalProb = goalProb.clamp(0.05, 0.5); // Clamp probability

          if (random.nextDouble() < goalProb) {
            if (homeInitiates) {
              homeScore++;
            } else {
              awayScore++;
            }
            attacker.matchGoals++; // Increment scorer's goal count
            eventLog.add(MatchEvent(
              minute: minute,
              type: MatchEventType.Goal,
              teamId: initiatingTeamId,
              playerId: attacker.id,
              description: "GOAL! ${attacker.name} scores for ${initiatingTeamId == homeTeamId ? 'Home' : 'Away'}!",
            ));
          }
        }
      }
      // --- End Event Generation Logic ---

      if (minute == 45) {
        eventLog.add(MatchEvent(minute: 45, type: MatchEventType.HalfTime, teamId: '', description: "Half Time: $homeTeamId $homeScore - $awayScore $awayTeamId"));
      }
    }

    // --- 3. Finalization ---
    eventLog.add(MatchEvent(minute: 90, type: MatchEventType.FullTime, teamId: '', description: "Full Time: $homeTeamId $homeScore - $awayScore $awayTeamId"));

    if (homeScore > awayScore) {
      result = MatchResult.homeWin;
    } else if (awayScore > homeScore) {
      result = MatchResult.awayWin;
    } else {
      result = MatchResult.draw;
    }

    isSimulated = true;
    print("Match ${id} detailed simulation complete: ${homeTeamId} ${homeScore} - ${awayScore} ${awayTeamId}");
  }

  // Added methods for JSON serialization
  factory Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);
  Map<String, dynamic> toJson() => _$MatchToJson(this);
}
