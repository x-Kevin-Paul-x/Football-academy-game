import 'dart:math';
import 'package:json_annotation/json_annotation.dart'; // Added for JSON serialization
import 'player_status.dart'; // Import PlayerStatus
import 'tournament.dart'; // Import TournamentType

part 'player.g.dart'; // Added for generated code

enum PlayerPosition { Goalkeeper, Defender, Midfielder, Forward }

@JsonSerializable() // Added annotation
class Player {
  final String id;
  String name;
  int age;
  PlayerPosition position;
  int currentSkill; // Made non-final
  final int potentialSkill; // Keep final
  int weeklyWage;
  bool isScouted; // Flag to differentiate between academy players and scouted prospects

  // --- In-Match Stats (can be reset per match) ---
  @JsonKey(includeFromJson: false, includeToJson: false) // Exclude from serialization
  int matchGoals = 0;
  @JsonKey(includeFromJson: false, includeToJson: false) // Exclude from serialization
  int matchAssists = 0;
  // Add more stats: shots, tackles, saves (if GK), etc.
  // ---

  // --- Reputation ---
  int reputation; // Player's reputation score

  // --- New Detailed Attributes ---
  int matchesPlayed;
  int goalsScored; // Cumulative goals
  int assists; // Cumulative assists
  TournamentType preferredFormat; // e.g., 5v5 specialist
  PlayerStatus status; // e.g., Starter, Bench, Injured
  int stamina; // Base stamina attribute (e.g., 1-100)
  double fatigue; // Current fatigue level (e.g., 0.0 to 100.0)
  // --- End New Detailed Attributes ---

  Player({
    required this.id,
    required this.name,
    required this.age,
    required this.position,
    required this.currentSkill,
    required this.potentialSkill,
    required this.weeklyWage,
    this.isScouted = false,
    this.reputation = 0, // Initialize reputation in default constructor
    // Initialize new fields with defaults
    this.matchesPlayed = 0,
    this.goalsScored = 0,
    this.assists = 0,
    this.preferredFormat = TournamentType.elevenVeleven, // Default
    this.status = PlayerStatus.Reserve, // Default
    this.stamina = 50, // Default
    this.fatigue = 0.0, // Default
  });

  // Factory constructor for generating random scouted players
  factory Player.randomScoutedPlayer(String id) {
    final random = Random();
    List<String> firstNames = ['Alex', 'Ben', 'Chris', 'David', 'Ethan', 'Finn', 'George', 'Harry', 'Ian', 'Jack'];
    List<String> lastNames = ['Smith', 'Jones', 'Williams', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor', 'Anderson'];

    String name = '${firstNames[random.nextInt(firstNames.length)]} ${lastNames[random.nextInt(lastNames.length)]}';
    int age = 15 + random.nextInt(4); // Young players: 15-18
    PlayerPosition position = PlayerPosition.values[random.nextInt(PlayerPosition.values.length)];
    int potentialSkill = 50 + random.nextInt(41); // Potential between 50-90
    int currentSkill = 20 + random.nextInt(potentialSkill - 20 + 1); // Current skill lower than potential
    int weeklyWage = 50 + random.nextInt(151); // Wage between 50-200 for prospects

    return Player(
      id: id,
      name: name,
      age: age,
      position: position,
      currentSkill: currentSkill,
      potentialSkill: potentialSkill,
      weeklyWage: weeklyWage,
      isScouted: true, // Mark as scouted initially
      reputation: 10 + random.nextInt(21), // Give scouted players some initial reputation (e.g., 10-30)
      // Add random values for new fields in factory
      stamina: random.nextInt(51) + 35, // Stamina between 35-85
      preferredFormat: TournamentType.values[random.nextInt(TournamentType.values.length)], // Random preferred format
      // Other new fields like matchesPlayed, goals, assists, fatigue, status keep their defaults (0, 0, 0, 0.0, Reserve)
    );
  }

  String get positionString {
    switch (position) {
      case PlayerPosition.Goalkeeper:
        return 'GK';
      case PlayerPosition.Defender:
        return 'DEF';
      case PlayerPosition.Midfielder:
        return 'MID';
      case PlayerPosition.Forward:
        return 'FWD';
    }
  }

  // --- ADDED: Calculate Market Value ---
  int calculateMarketValue() {
    // Base value primarily on current skill
    double baseValue = pow(currentSkill, 2.5) * 10;

    // Age modifier: Higher value for younger players, peaks around 24-27, then declines
    double ageModifier;
    if (age <= 20) {
      ageModifier = 1.5 - (age - 15) * 0.05; // Higher for very young
    } else if (age <= 27) {
      ageModifier = 1.25 - (age - 21) * 0.03; // Peak value range
    } else if (age <= 32) {
      ageModifier = 1.0 - (age - 28) * 0.08; // Gradual decline
    } else {
      ageModifier = 0.6 - (age - 33) * 0.1; // Steeper decline for older players
    }
    ageModifier = ageModifier.clamp(0.1, 1.5); // Ensure modifier stays within bounds

    // Potential modifier: Adds value, especially significant for younger players
    double potentialGap = (potentialSkill - currentSkill).toDouble();
    double potentialModifier = 1.0 + (potentialGap / 100.0) * (30 / max(18, age)); // More impact when young
    potentialModifier = potentialModifier.clamp(1.0, 1.8); // Clamp potential boost

    // Reputation modifier
    double reputationModifier = 1.0 + (reputation / 200.0); // e.g., 100 rep = 1.5x modifier
    reputationModifier = reputationModifier.clamp(1.0, 2.0);

    // Combine modifiers
    double finalValue = baseValue * ageModifier * potentialModifier * reputationModifier;

    // Add a small random factor
    finalValue *= (1.0 + (Random().nextDouble() * 0.1 - 0.05)); // +/- 5% randomness

    // Ensure minimum value
    return max(500, finalValue.toInt()); // Minimum value of 500
  }
  // --- END: Calculate Market Value ---

  // Added methods for JSON serialization
  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}
