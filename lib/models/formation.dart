import 'package:json_annotation/json_annotation.dart';
import 'player.dart'; // For PlayerPosition
import 'tournament.dart'; // For TournamentType

part 'formation.g.dart';

// Enum defining specific formation types
enum FormationType {
  // 11v11
  F442,
  F433,
  F352,
  F532,
  F4231,
  F4141,
  // 7v7
  F231,
  F321,
  F132,
  // 5v5
  F121,
  F211,
  F112,
  // 3v3
  F111,
  F21,
  F12
}

@JsonSerializable()
class Formation {
  final String id; // e.g., "f442"
  final String name; // e.g., "4-4-2"
  final FormationType type;
  final TournamentType tournamentType; // Which game size is it for?
  final List<PlayerPosition> positions; // Ordered list of positions

  int get requiredPlayers => positions.length;

  Formation({
    required this.id,
    required this.name,
    required this.type,
    required this.tournamentType,
    required this.positions,
  }) {
    // Basic validation
    int expectedPlayers = _getPlayersForTournamentType(tournamentType);
    if (requiredPlayers != expectedPlayers) {
      throw ArgumentError(
          'Formation $name ($id) requires $requiredPlayers players, but TournamentType $tournamentType expects $expectedPlayers.');
    }
  }

  factory Formation.fromJson(Map<String, dynamic> json) =>
      _$FormationFromJson(json);
  Map<String, dynamic> toJson() => _$FormationToJson(this);

  // Helper to get expected player count for validation
  static int _getPlayersForTournamentType(TournamentType type) {
    switch (type) {
      case TournamentType.elevenVeleven:
        return 11;
      case TournamentType.sevenVseven:
        return 7;
      case TournamentType.fiveVfive:
        return 5;
      case TournamentType.threeVthree:
        return 3;
    }
  }
}

// --- Predefined Formations ---

// You might load this from a config file later, but define statically for now
final List<Formation> predefinedFormations = [
  // --- 11v11 ---
  Formation(
    id: 'f442_11',
    name: '4-4-2',
    type: FormationType.F442,
    tournamentType: TournamentType.elevenVeleven,
    positions: [
      PlayerPosition.Goalkeeper,
      PlayerPosition.Defender,
      PlayerPosition.Defender,
      PlayerPosition.Defender,
      PlayerPosition.Defender,
      PlayerPosition.Midfielder,
      PlayerPosition.Midfielder,
      PlayerPosition.Midfielder,
      PlayerPosition.Midfielder,
      PlayerPosition.Forward,
      PlayerPosition.Forward,
    ],
  ),
  Formation(
    id: 'f433_11',
    name: '4-3-3',
    type: FormationType.F433,
    tournamentType: TournamentType.elevenVeleven,
    positions: [
      PlayerPosition.Goalkeeper,
      PlayerPosition.Defender,
      PlayerPosition.Defender,
      PlayerPosition.Defender,
      PlayerPosition.Defender,
      PlayerPosition.Midfielder,
      PlayerPosition.Midfielder,
      PlayerPosition.Midfielder,
      PlayerPosition.Forward,
      PlayerPosition.Forward,
      PlayerPosition.Forward,
    ],
  ),
  Formation(
    id: 'f352_11',
    name: '3-5-2',
    type: FormationType.F352,
    tournamentType: TournamentType.elevenVeleven,
    positions: [
      PlayerPosition.Goalkeeper,
      PlayerPosition.Defender,
      PlayerPosition.Defender,
      PlayerPosition.Defender,
      PlayerPosition.Midfielder,
      PlayerPosition.Midfielder,
      PlayerPosition.Midfielder,
      PlayerPosition.Midfielder,
      PlayerPosition.Midfielder,
      PlayerPosition.Forward,
      PlayerPosition.Forward,
    ],
  ),
  // --- 7v7 ---
  Formation(
    id: 'f231_7',
    name: '2-3-1',
    type: FormationType.F231,
    tournamentType: TournamentType.sevenVseven,
    positions: [
      PlayerPosition.Goalkeeper, // Assuming GK for 7v7
      PlayerPosition.Defender, PlayerPosition.Defender,
      PlayerPosition.Midfielder, PlayerPosition.Midfielder,
      PlayerPosition.Midfielder,
      PlayerPosition.Forward,
    ],
  ),
  Formation(
    id: 'f321_7',
    name: '3-2-1',
    type: FormationType.F321,
    tournamentType: TournamentType.sevenVseven,
    positions: [
      PlayerPosition.Goalkeeper,
      PlayerPosition.Defender,
      PlayerPosition.Defender,
      PlayerPosition.Defender,
      PlayerPosition.Midfielder,
      PlayerPosition.Midfielder,
      PlayerPosition.Forward,
    ],
  ),
  // --- 5v5 ---
  Formation(
    id: 'f121_5',
    name: '1-2-1',
    type: FormationType.F121,
    tournamentType: TournamentType.fiveVfive,
    positions: [
      PlayerPosition.Goalkeeper, // Assuming GK for 5v5
      PlayerPosition.Defender,
      PlayerPosition.Midfielder, PlayerPosition.Midfielder,
      PlayerPosition.Forward,
    ],
  ),
  Formation(
    id: 'f211_5',
    name: '2-1-1',
    type: FormationType.F211,
    tournamentType: TournamentType.fiveVfive,
    positions: [
      PlayerPosition.Goalkeeper,
      PlayerPosition.Defender,
      PlayerPosition.Defender,
      PlayerPosition.Midfielder,
      PlayerPosition.Forward,
    ],
  ),
  // --- 3v3 ---
  Formation(
    id: 'f111_3',
    name: '1-1-1',
    type: FormationType.F111,
    tournamentType: TournamentType.threeVthree,
    positions: [
      // No dedicated GK usually in 3v3 street style
      PlayerPosition.Defender,
      PlayerPosition.Midfielder,
      PlayerPosition.Forward,
    ],
  ),
  Formation(
    id: 'f12_3',
    name: '1-2',
    type: FormationType.F12,
    tournamentType: TournamentType.threeVthree,
    positions: [
      PlayerPosition.Defender,
      PlayerPosition.Forward, PlayerPosition.Forward, // Or Midfielder/Forward
    ],
  ),
];

// Helper to get formations suitable for a specific tournament type
List<Formation> getFormationsForTournamentType(TournamentType type) {
  return predefinedFormations.where((f) => f.tournamentType == type).toList();
}
