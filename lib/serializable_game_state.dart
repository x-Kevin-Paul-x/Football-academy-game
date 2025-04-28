import 'package:json_annotation/json_annotation.dart';
import 'models/player.dart';
import 'models/staff.dart';
import 'models/tournament.dart';
import 'models/news_item.dart'; // Make sure NewsItem is serializable too!
import 'models/difficulty.dart';
import 'package:flutter/material.dart'; // For ThemeMode

part 'serializable_game_state.g.dart';

// Helper functions for ThemeMode serialization
ThemeMode _themeModeFromJson(String themeModeString) {
  return ThemeMode.values.firstWhere(
    (e) => e.toString() == themeModeString,
    orElse: () => ThemeMode.system, // Default if not found
  );
}
String _themeModeToJson(ThemeMode themeMode) => themeMode.toString();


@JsonSerializable(explicitToJson: true)
class SerializableGameState {
  // Core Game Time & State
  final DateTime currentDate;

  // Player & Staff State
  final List<Player> academyPlayers;
  final List<Staff> hiredStaff;
  // Note: _scoutedPlayers and _availableStaff are transient/regenerated, so not saved.

  // Financial State
  final double balance;
  final int weeklyIncome;
  final int totalWeeklyWages; // Can be recalculated, but saving is simpler

  // Tournament State
  final List<Tournament> activeTournaments;
  final List<Tournament> completedTournaments;

  // AI Club Data - Not saving AI clubs themselves, assuming they are static/regenerated.

  // Facility State
  final int trainingFacilityLevel;
  final int scoutingFacilityLevel;

  // Reputation
  final int academyReputation;

  // Transfer Offers - Not saving, assuming transient.

  // News Feed
  final List<NewsItem> newsItems; // Saving news items

  // Settings
  final Difficulty difficulty;

  @JsonKey(fromJson: _themeModeFromJson, toJson: _themeModeToJson) // Use converters for ThemeMode
  final ThemeMode themeMode;

  SerializableGameState({
    required this.currentDate,
    required this.academyPlayers,
    required this.hiredStaff,
    required this.balance,
    required this.weeklyIncome,
    required this.totalWeeklyWages,
    required this.activeTournaments,
    required this.completedTournaments,
    required this.trainingFacilityLevel,
    required this.scoutingFacilityLevel,
    required this.academyReputation,
    required this.newsItems,
    required this.difficulty,
    required this.themeMode,
  });

  factory SerializableGameState.fromJson(Map<String, dynamic> json) => _$SerializableGameStateFromJson(json);
  Map<String, dynamic> toJson() => _$SerializableGameStateToJson(this);
}
