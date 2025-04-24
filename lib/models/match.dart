import 'dart:math'; // Import Random
import 'package:flutter/material.dart';
import 'dart:math'; // Ensure Random is imported
import 'ai_club.dart'; // Assuming AIClub model exists
import 'match_event.dart'; // Import the new MatchEvent model
import 'player.dart'; // *** Ensure Player model is imported ***

enum MatchResult { homeWin, awayWin, draw }

class Match {
  final String id;
  final String tournamentId; // Link back to the tournament
  final String homeTeamId; // Could be player's academy ID or AIClub ID
  final String awayTeamId; // Could be player's academy ID or AIClub ID
  final DateTime matchDate;
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

    // --- Removed old simulation logic block ---

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
      // More sophisticated logic needed here, this is a basic placeholder

      // Calculate chance of *any* significant event happening this minute
      double eventChance = 0.1 + ((avgHomeSkill + avgAwaySkill) / 2000); // Base chance + skill influence
      if (random.nextDouble() < eventChance) {
        // Determine which team is more likely to initiate the event
        double totalSkill = avgHomeSkill + avgAwaySkill;
        double homeInitiativeChance = totalSkill > 0 ? avgHomeSkill / totalSkill : 0.5;
        bool homeInitiates = random.nextDouble() < homeInitiativeChance;
        String initiatingTeamId = homeInitiates ? homeTeamId : awayTeamId;
        List<Player> initiatingLineup = homeInitiates ? homeTeamLineup : awayTeamLineup;
        List<Player> defendingLineup = homeInitiates ? awayTeamLineup : homeTeamLineup;

        // Determine type of event (Goal chance, Foul, etc.)
        double goalAttemptChance = 0.3; // Chance the event is a goal attempt
        // Add chances for other events (fouls, saves, etc.)

        if (random.nextDouble() < goalAttemptChance && initiatingLineup.isNotEmpty) {
          // --- Goal Attempt ---
          // Select attacker (e.g., higher skill = higher chance, or based on position)
          Player attacker = initiatingLineup[random.nextInt(initiatingLineup.length)]; // Simple random attacker

          // Calculate goal probability based on attacker skill vs avg defender skill/GK skill
          // Placeholder: Attacker skill vs average team skill
          double avgDefenderSkill = defendingLineup.isEmpty ? 10 : defendingLineup.fold(0.0, (sum, p) => sum + p.currentSkill) / defendingLineup.length;
          double goalProb = 0.1 + (attacker.currentSkill - avgDefenderSkill) / 200; // Basic skill difference influence
          goalProb = goalProb.clamp(0.05, 0.5); // Clamp probability

          if (random.nextDouble() < goalProb) {
            // --- GOAL ---
            if (homeInitiates) {
              homeScore++;
            } else {
              awayScore++;
            }
            attacker.matchGoals++; // Increment scorer's goal count
            // TODO: Select assisting player?
            eventLog.add(MatchEvent(
              minute: minute,
              type: MatchEventType.Goal,
              teamId: initiatingTeamId,
              playerId: attacker.id,
              description: "GOAL! ${attacker.name} scores for ${initiatingTeamId == homeTeamId ? 'Home' : 'Away'}!",
            ));
          } else {
            // Missed shot / Save - Add event?
            // eventLog.add(MatchEvent(... type: MatchEventType.Save ...));
          }
        } else {
          // Other event types (Foul, Card, etc.) - Placeholder
          // if (random.nextDouble() < 0.1) { // Chance of a foul
          //   eventLog.add(MatchEvent(minute: minute, type: MatchEventType.Foul, ...));
          // }
        }
      }
      // --- End Event Generation Logic ---


      // Add HalfTime event
      if (minute == 45) {
        eventLog.add(MatchEvent(minute: 45, type: MatchEventType.HalfTime, teamId: '', description: "Half Time: $homeTeamId $homeScore - $awayScore $awayTeamId"));
      }
    }

    // --- 3. Finalization ---
    eventLog.add(MatchEvent(minute: 90, type: MatchEventType.FullTime, teamId: '', description: "Full Time: $homeTeamId $homeScore - $awayScore $awayTeamId"));

    // Determine result
    if (homeScore > awayScore) {
      result = MatchResult.homeWin;
    } else if (awayScore > homeScore) {
      result = MatchResult.awayWin;
    } else {
      result = MatchResult.draw;
    }

    isSimulated = true;
    // Removed skill printout as it's not directly used in the final score calculation anymore
    print("Match ${id} detailed simulation complete: ${homeTeamId} ${homeScore} - ${awayScore} ${awayTeamId}");
  }
}

// Placeholder for MatchEvent if needed later
// class MatchEvent {
//   final int minute;
//   final String description;
//   // e.g., Goal scored by Player X, Yellow card for Player Y
// }
