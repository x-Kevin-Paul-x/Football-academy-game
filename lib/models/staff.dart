import 'package:collection/collection.dart';
import 'package:football_academy_game/models/tournament.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:math';
import 'package:uuid/uuid.dart';
import '../utils/name_generator.dart'; // <-- Import NameGenerator
import 'formation.dart'; // <-- Import FormationType

part 'staff.g.dart';

enum StaffRole {
  Manager,
  Coach,
  Scout,
  Physio,
  MerchandiseManager,
}

enum MerchAssignmentType {
  None,
  StoreManager,
  MatchSales,
}

@JsonSerializable(explicitToJson: true)
class Staff {
  final String id;
  final String name;
  final StaffRole role;
  int skill; // 1-100
  int weeklyWage;
  int loyalty; // 1-100, affects likelihood of leaving/demanding raises
  int potential; // 1-100, max skill they can reach naturally
  // final TacticalStyle preferredTacticalStyle; // Removed
  int age;
  bool isAssigned; // Field to track if staff (especially scouts) are active

  // Coach specific
  List<String> assignedPlayerIds; // IDs of players assigned to this coach
  int maxPlayersTrainable; // How many players this coach can handle

  // Manager specific
  List<FormationType> knownFormations;
  Formation? preferredFormation;

  // MerchandiseManager specific
  MerchAssignmentType merchAssignment;
  // int currentMerchStockValue; // Removed: Stock will be managed centrally in GameStateManager
  double merchProfitMarginEffectiveness; // 0.0 to 1.0, derived from skill, affects buy/sell prices

  Staff({
    required this.id,
    required this.name,
    required this.role,
    required this.skill,
    required this.weeklyWage,
    required this.loyalty,
    required this.potential,
    // required this.preferredTacticalStyle, // Removed
    required this.age,
    List<String>? assignedPlayerIds,
    int? maxPlayersTrainable,
    List<FormationType>? knownFormations,
    this.preferredFormation,
    this.isAssigned = true,
    this.merchAssignment = MerchAssignmentType.None, // Default assignment
    // this.currentMerchStockValue = 0, // Removed
    this.merchProfitMarginEffectiveness = 0.5, // Default effectiveness
  }) : assignedPlayerIds = assignedPlayerIds ?? [],
       maxPlayersTrainable = maxPlayersTrainable ?? 5,
       knownFormations = knownFormations ?? [];

  // Factory for generating random staff
  factory Staff.randomStaff(String id, StaffRole role, {int? academyReputation}) {
    final random = Random();
    const bool defaultIsAssignedForRandomStaff = true;

    // --- Reputation Influence on Potential ---
    // academyReputation typically ranges from 0 to 1000.
    // Let's scale this to influence potential.
    // Base potential range: 20-70. Max bonus from reputation: +30.
    // So, at 0 reputation, potential is 20-70.
    // At 1000 reputation, potential is 50-100.
    int baseMinPotential = 20;
    int baseMaxPotential = 70;
    double reputationFactor = (academyReputation ?? 0) / 1000.0; // Normalize reputation to 0.0 - 1.0
    int reputationBonus = (reputationFactor * 30).toInt(); // Max +30 bonus

    int minPotential = (baseMinPotential + reputationBonus).clamp(10, 90); // Ensure min potential is reasonable
    int maxPotential = (baseMaxPotential + reputationBonus).clamp(minPotential + 10, 100); // Ensure max is above min and capped

    int potential = minPotential + random.nextInt(maxPotential - minPotential + 1);
    potential = potential.clamp(10, 100); // Final clamp for safety
    // --- End Reputation Influence ---

    int skill = (potential * (0.4 + random.nextDouble() * 0.5)).clamp(10, 95).toInt();
    int age = 25 + random.nextInt(36);
    int wage = 100 + (skill * 5) + (potential * 2) + random.nextInt(100);
    int loyalty = 40 + random.nextInt(51);
    int maxTrainable = 3 + (skill ~/ 20);
    List<FormationType> initialKnownFormations = [];
    Formation? initialPreferredFormation;
    double initialMerchProfitMarginEffectiveness = 0.3 + (skill / 200.0); // Base 0.3 + up to 0.5 from skill (total 0.3 to 0.8)
    initialMerchProfitMarginEffectiveness = initialMerchProfitMarginEffectiveness.clamp(0.1, 0.95); // Clamp it

    if (role == StaffRole.Manager) {
      initialKnownFormations = _determineInitialKnownFormations(skill);
      if (initialKnownFormations.isNotEmpty) {
        // Find a preferred FormationType (prefer 11v11 if known)
        FormationType? preferredType = initialKnownFormations.firstWhere(
          (ft) {
            // Find the corresponding Formation object to check its tournamentType
            Formation? f = predefinedFormations.firstWhereOrNull((pf) => pf.type == ft);
            return f?.tournamentType == TournamentType.elevenVeleven;
          },
          orElse: () => initialKnownFormations[random.nextInt(initialKnownFormations.length)], // Fallback to random known type
        );

        // Find the actual Formation object from the predefined list based on the preferredType
        if (preferredType != null) {
           initialPreferredFormation = predefinedFormations.firstWhereOrNull((f) => f.type == preferredType);
        }
        // Fallback if somehow the preferredType didn't yield a formation
        initialPreferredFormation ??= predefinedFormations.firstWhereOrNull((f) => f.type == initialKnownFormations.first);

      }
    }

    return Staff(
      id: id,
      name: NameGenerator.generatePlayerName(), // <-- Use NameGenerator
      role: role,
      skill: skill,
      weeklyWage: wage,
      loyalty: loyalty,
      potential: potential,
      age: age,
      maxPlayersTrainable: (role == StaffRole.Coach) ? maxTrainable : 0,
      knownFormations: initialKnownFormations,
      preferredFormation: initialPreferredFormation,
      isAssigned: defaultIsAssignedForRandomStaff,
      merchAssignment: MerchAssignmentType.None,
      // currentMerchStockValue: 0, // Removed
      merchProfitMarginEffectiveness: (role == StaffRole.MerchandiseManager) ? initialMerchProfitMarginEffectiveness : 0.5,
    );
  }

  // Helper to determine initial known formations based on skill
  static List<FormationType> _determineInitialKnownFormations(int managerSkill) {
    final random = Random();
    // Base number + skill bonus
    int numKnown = 1 + (managerSkill ~/ 25); // 1 base + 1 for every 25 skill (max 5 at skill 100)
    numKnown = numKnown.clamp(1, FormationType.values.length); // Clamp between 1 and total available

    // Get all formation types and shuffle
    List<FormationType> allTypes = List.from(FormationType.values)..shuffle(random);

    // Select the determined number of formations
    return allTypes.sublist(0, numKnown);
  }

  factory Staff.fromJson(Map<String, dynamic> json) => _$StaffFromJson(json);
  Map<String, dynamic> toJson() => _$StaffToJson(this);
}
