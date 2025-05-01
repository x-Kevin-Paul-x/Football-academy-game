import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart'; // Import for ThemeMode
import 'models/player.dart';
import 'models/staff.dart';
import 'models/tournament.dart';
import 'models/news_item.dart';
import 'models/difficulty.dart';
import 'models/rival_academy.dart'; // <-- ADDED Import

part 'serializable_game_state.g.dart'; // Link to the generated file

@JsonSerializable(explicitToJson: true) // Important for nested objects
class SerializableGameState {
  final DateTime currentDate;
  final String academyName; // Moved up for consistency
  final List<Player> academyPlayers;
  final List<Staff> hiredStaff;
  final double balance;
  final int weeklyIncome;
  final int totalWeeklyWages;
  final List<Tournament> activeTournaments;
  final List<Tournament> completedTournaments;
  final int trainingFacilityLevel;
  final int scoutingFacilityLevel;
  final int medicalBayLevel;
  final int academyReputation;
  final List<NewsItem> newsItems;
  final Difficulty difficulty;
  @JsonKey(toJson: _themeModeToJson, fromJson: _themeModeFromJson) // Custom converter for ThemeMode
  final ThemeMode themeMode;
  final List<RivalAcademy> rivalAcademies; // <-- ADDED Field

  SerializableGameState({
    required this.currentDate,
    required this.academyName, // Moved up
    required this.academyPlayers,
    required this.hiredStaff,
    required this.balance,
    required this.weeklyIncome,
    required this.totalWeeklyWages,
    required this.activeTournaments,
    required this.completedTournaments,
    required this.trainingFacilityLevel,
    required this.scoutingFacilityLevel,
    required this.medicalBayLevel,
    required this.academyReputation,
    required this.newsItems,
    required this.difficulty,
    required this.themeMode,
    required this.rivalAcademies, // <-- ADDED to constructor
  });

  // Connect to the generated functions
  factory SerializableGameState.fromJson(Map<String, dynamic> json) => _$SerializableGameStateFromJson(json);
  Map<String, dynamic> toJson() => _$SerializableGameStateToJson(this);

  // Custom JSON converters for ThemeMode
  static String _themeModeToJson(ThemeMode mode) => mode.toString().split('.').last;
  static ThemeMode _themeModeFromJson(String jsonValue) {
    return ThemeMode.values.firstWhere(
      (e) => e.toString().split('.').last == jsonValue,
      orElse: () => ThemeMode.system, // Default if parsing fails
    );
  }
}
