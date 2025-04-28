import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart'; // Added for JSON serialization
// Potentially import Player and AIClub models later
// import 'player.dart';
// import 'ai_club.dart';
import 'match.dart'; // Import Match model

part 'tournament.g.dart'; // Added for generated code

enum TournamentType {
  threeVthree,
  fiveVfive,
  sevenVseven,
  elevenVeleven, // League might be a special type or handled differently
}

enum TournamentStatus { Available, InProgress, Completed }

@JsonSerializable(explicitToJson: true) // Added annotation, explicitToJson needed for List<Match>
class Tournament {
  final String id; // Unique ID for this specific instance of the tournament
  final String? baseId; // Optional: ID of the template tournament this instance came from
  final String name;
  final TournamentType type;
  final int requiredPlayers;
  final List<String> participants; // List of club IDs (Player's academy + AI clubs)
  // final DateTime startDate; // REMOVED - Scheduling is now relative to entry date
  final String prize; // Could be money, reputation, etc.
  final int requiredReputation; // Reputation needed to enter
  // bool isCompleted; // Replaced by status
  String? winner; // Club ID of the winner
  TournamentStatus status;
  List<Match> matches; // List to hold generated matches

  Tournament({
    required this.id,
    required this.name,
    required this.type,
    required this.requiredPlayers,
    required this.participants,
    // required this.startDate, // REMOVED
    required this.prize,
    required this.requiredReputation, // Add to required parameters
    // this.isCompleted = false, // Removed
    this.winner,
    this.status = TournamentStatus.Available, // Default status
    this.matches = const [], // Default empty list
    this.baseId, // Initialize baseId (optional)
  });

  // Helper to get a display name for the type
  // This getter should not be part of JSON
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get typeDisplay {
    switch (type) {
      case TournamentType.threeVthree:
        return '3v3 Tournament';
      case TournamentType.fiveVfive:
        return '5v5 Tournament';
      case TournamentType.sevenVseven:
        return '7v7 Tournament';
      case TournamentType.elevenVeleven:
        return '11v11 League'; // Or just '11v11 Tournament'
      default:
        return 'Unknown Tournament';
    }
  }

  // Added methods for JSON serialization
  factory Tournament.fromJson(Map<String, dynamic> json) => _$TournamentFromJson(json);
  Map<String, dynamic> toJson() => _$TournamentToJson(this);
}
