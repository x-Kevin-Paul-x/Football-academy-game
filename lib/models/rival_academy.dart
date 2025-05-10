import 'package:json_annotation/json_annotation.dart';
import 'player.dart';
import 'tournament.dart'; // Import Tournament for template checking
import 'difficulty.dart'; // Import Difficulty
import 'dart:math';
import 'package:uuid/uuid.dart';

part 'rival_academy.g.dart';

@JsonSerializable(explicitToJson: true)
class RivalAcademy {
  final String id;
  String name;
  int skillLevel; // Overall skill/potential (e.g., 1-100)
  int reputation; // Reputation affects transfers, tournament invites (e.g., 1-1000)
  double balance;
  List<Player> players;
  int trainingFacilityLevel;
  int scoutingFacilityLevel;
  int medicalBayLevel;
  List<String> activeTournamentIds; // IDs of tournaments currently participating in
  int tier; // 0 = Unranked/Not in Pro League, 1 = Tier 1, 2 = Tier 2, 3 = Tier 3

  @JsonKey(ignore: true) // Don't serialize random instance
  final Random _random = Random();

  RivalAcademy({
    required this.id,
    required this.name,
    required this.skillLevel,
    required this.reputation,
    required this.balance,
    required this.players,
    this.trainingFacilityLevel = 1,
    this.scoutingFacilityLevel = 1,
    this.medicalBayLevel = 1,
    List<String>? activeTournamentIds, // Make nullable for constructor
    this.tier = 0, // Default to unranked
  }) : activeTournamentIds = activeTournamentIds ?? []; // Initialize if null

  // Factory for creating initial rivals based on index and difficulty
  factory RivalAcademy.initial(int index, {Difficulty difficulty = Difficulty.Normal}) {
    final random = Random();
    String id = 'rival_${index + 1}';
    String name = 'Academy ${String.fromCharCode(65 + index)}'; // Academy A, B, C...

    // Base values
    int baseSkill = 20 + random.nextInt(41); // 20-60
    int baseReputation; // Will be set based on difficulty
    double baseBalance = 20000.0 + random.nextInt(30001); // 20k-50k

    // Adjust based on difficulty
    switch (difficulty) {
      case Difficulty.Easy:
        baseSkill = (baseSkill * 0.8).round().clamp(10, 90);
        baseReputation = 30;
        baseBalance *= 1.2;
        break;
      case Difficulty.Normal:
        // No change to baseSkill
        baseReputation = 10;
        // No change to baseBalance
        break;
      case Difficulty.Hard:
        baseSkill = (baseSkill * 1.15).round().clamp(10, 90);
        baseReputation = 5;
        baseBalance *= 0.8;
        break;
      case Difficulty.Hardcore:
        baseSkill = (baseSkill * 1.3).round().clamp(10, 90);
        baseReputation = 0;
        baseBalance *= 0.6;
        break;
    }

    return RivalAcademy(
      id: id,
      name: name,
      skillLevel: baseSkill,
      reputation: baseReputation,
      balance: baseBalance,
      players: [], // Players generated later in GameStateManager
      trainingFacilityLevel: 1 + random.nextInt(2), // Start with level 1 or 2
      scoutingFacilityLevel: 1 + random.nextInt(2),
      medicalBayLevel: 1 + random.nextInt(2),
      tier: 0, // Start unranked
    );
  }


  // --- AI Decision Logic ---

  // Decide if the academy should enter a given tournament
  bool shouldEnterTournament(Tournament template, int currentYear, int currentMonth) {
    // Basic checks
    if (reputation < template.requiredReputation) return false;
    if (balance < template.entryFee) return false;
    if (players.length < template.requiredPlayers) return false; // Check player count

    // Avoid joining too many tournaments at once
    if (activeTournamentIds.length >= 2) return false; // Limit to max 2 active tournaments

    // Chance based on reputation, skill, and maybe randomness
    double joinChance = 0.3; // Base chance
    joinChance += (reputation / 1000.0) * 0.2; // Increase chance with higher reputation (max +0.2)
    joinChance += (skillLevel / 100.0) * 0.1; // Slight increase with higher skill (max +0.1)
    joinChance -= (template.entryFee / balance) * 0.1; // Decrease if fee is large portion of balance

    // Consider tournament importance (e.g., higher prize/rep req might be more desirable)
    joinChance += (template.prizeMoneyBase / 50000.0) * 0.1; // Slight increase for higher prize (max +0.1 if prize is 50k)

    return _random.nextDouble() < joinChance.clamp(0.05, 0.8); // Clamp chance between 5% and 80%
  }

  // Decide which facility to upgrade, if any
  String? decideFacilityUpgrade() {
    // Simple logic: Prioritize training, then scouting, then medical
    // Only upgrade if affordable and maybe based on a random chance or need

    int trainingCost = calculateFacilityUpgradeCost(trainingFacilityLevel);
    if (balance > trainingCost * 1.5 && _random.nextDouble() < 0.1) { // 10% chance if 1.5x cost available
      return 'training';
    }

    int scoutingCost = calculateFacilityUpgradeCost(scoutingFacilityLevel);
    if (balance > scoutingCost * 1.5 && _random.nextDouble() < 0.08) { // 8% chance
      return 'scouting';
    }

    int medicalCost = calculateFacilityUpgradeCost(medicalBayLevel);
    if (balance > medicalCost * 1.5 && _random.nextDouble() < 0.06) { // 6% chance
      return 'medical';
    }

    return null; // No upgrade this week
  }

  // Calculate upgrade cost (same logic as player for now)
  int calculateFacilityUpgradeCost(int currentLevel) {
    return (pow(currentLevel, 1.5) * 5000).toInt() + 10000;
  }

  // --- Player Management (Placeholders) ---

  // Decide which scouted players to sign (needs list of available players)
  List<Player> decidePlayersToSign(List<Player> availableScoutedPlayers) {
    // TODO: Implement logic based on academy needs, player potential/skill, cost, balance
    return [];
  }

  // Decide which players to sell/release
  List<Player> decidePlayersToSell() {
    // TODO: Implement logic based on player age, performance, potential vs current skill, wage
    return [];
  }


  factory RivalAcademy.fromJson(Map<String, dynamic> json) => _$RivalAcademyFromJson(json);
  Map<String, dynamic> toJson() => _$RivalAcademyToJson(this);
}
