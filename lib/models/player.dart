import 'dart:math';
import 'package:json_annotation/json_annotation.dart'; // Added for JSON serialization
import 'player_status.dart'; // Import PlayerStatus
import 'tournament.dart'; // Import TournamentType
import '../utils/name_generator.dart'; // <-- Import the name generator

part 'player.g.dart'; // Added for generated code

enum PlayerPosition { Goalkeeper, Defender, Midfielder, Forward }

@JsonSerializable(explicitToJson: true) // Added explicitToJson for the map
class Player {
  final String id;
  String name;
  int age;
  final PlayerPosition naturalPosition; // Player's innate best position
  PlayerPosition assignedPosition; // Position assigned by manager/coaching staff
  // int currentSkill; // REMOVED - Will be a getter that derives from positionalAffinity and assignedPosition
  final int potentialSkill; // Overall potential cap for any position's affinity
  int weeklyWage;
  bool isScouted; // Flag to differentiate between academy players and scouted prospects

  // --- Positional Affinity ---
  // Stores the player's calculated skill (1-100) for each general position type.
  // This map is the source for the currentSkill getter based on assignedPosition.
  late Map<PlayerPosition, int> positionalAffinity;

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
  List<PlayerPosition> preferredPositions; // New: List of preferred positions
  double? lastMatchRating; // New: Rating from the last match played (0.0-10.0)

  // --- Mental Attributes ---
  int aggression;
  int composure;
  int concentration;
  int decision;
  int determination;
  int flair;
  int leadership;
  int teamwork;
  int vision;
  int workRate;

  // --- Physical Attributes ---
  int acceleration;
  int agility;
  int balance;
  int jumpingReach;
  int naturalFitness;
  int pace;
  int strength;
  // Stamina is already present

  // --- Attacking Stats ---
  int crossing;
  int dribbling;
  int finishing;
  int firstTouch;
  int heading;
  int longShots;
  int passing;
  int penaltyTaking;
  int technique;

  // --- Defending Stats ---
  int marking;
  int tackling;
  int defensivePositioning; // Renamed from "Positioning (Defensive)"

  // --- Goalkeeping Stats ---
  int aerialReach; // GK
  int commandOfArea; // GK
  int communicationGK; // GK, suffixed to avoid conflict if a general communication stat is added later
  int eccentricity; // GK
  int handling; // GK
  int kicking; // GK
  int oneOnOnes; // GK
  int reflexes; // GK
  int rushingOut; // GK
  int throwing; // GK
  // --- End New Detailed Attributes ---

  Player({
    required this.id,
    required this.name,
    required this.age,
    required this.naturalPosition, // Changed from position
    // required this.currentSkill, // Removed
    required this.potentialSkill,
    required this.weeklyWage,
    this.isScouted = false,
    this.reputation = 0,
    this.matchesPlayed = 0,
    this.goalsScored = 0,
    this.assists = 0,
    this.preferredFormat = TournamentType.elevenVeleven,
    this.status = PlayerStatus.Reserve,
    this.stamina = 50,
    this.fatigue = 0.0,
    required this.preferredPositions,
    this.lastMatchRating,
    this.aggression = 10,
    this.composure = 10,
    this.concentration = 10,
    this.decision = 10,
    this.determination = 10,
    this.flair = 10,
    this.leadership = 10,
    this.teamwork = 10,
    this.vision = 10,
    this.workRate = 10,
    this.acceleration = 10,
    this.agility = 10,
    this.balance = 10,
    this.jumpingReach = 10,
    this.naturalFitness = 10,
    this.pace = 10,
    this.strength = 10,
    this.crossing = 10,
    this.dribbling = 10,
    this.finishing = 10,
    this.firstTouch = 10,
    this.heading = 10,
    this.longShots = 10,
    this.passing = 10,
    this.penaltyTaking = 10,
    this.technique = 10,
    this.marking = 10,
    this.tackling = 10,
    this.defensivePositioning = 10,
    this.aerialReach = 10,
    this.commandOfArea = 10,
    this.communicationGK = 10,
    this.eccentricity = 10,
    this.handling = 10,
    this.kicking = 10,
    this.oneOnOnes = 10,
    this.reflexes = 10,
    this.rushingOut = 10,
    this.throwing = 10,
  }) : assignedPosition = naturalPosition { // Initialize assignedPosition
    // Initialize positionalAffinity and calculate initial values
    positionalAffinity = {}; // Initialize the map
    _calculatePositionalAffinities(); // Calculate affinities based on initial stats
  }

  // Factory constructor for generating random scouted players
  factory Player.randomScoutedPlayer(String id) {
    final random = Random();
    int randomStat() => 5 + random.nextInt(11); // Generates a stat between 5-15

    String name = NameGenerator.generatePlayerName(); // <-- Use NameGenerator
    int age = 15 + random.nextInt(4); // Young players: 15-18
    PlayerPosition position = PlayerPosition.values[random.nextInt(PlayerPosition.values.length)];
    int potentialSkill = 50 + random.nextInt(41); // Potential between 50-90
    int currentSkill = 20 + random.nextInt(potentialSkill - 20 + 1); // Current skill lower than potential
    int weeklyWage = 50 + random.nextInt(151); // Wage between 50-200 for prospects

    PlayerPosition naturalPositionValue = PlayerPosition.values[random.nextInt(PlayerPosition.values.length)]; // Renamed from 'position' for clarity
    // int potentialSkill = 50 + random.nextInt(41); // Potential between 50-90 // Already defined above
    // int currentSkill = 20 + random.nextInt(potentialSkill - 20 + 1); // Current skill lower than potential // No longer needed here
    // int weeklyWage = 50 + random.nextInt(151); // Wage between 50-200 for prospects // Already defined above

    // Determine preferred positions
    List<PlayerPosition> preferred = [naturalPositionValue]; // Always prefer natural position
    if (random.nextDouble() < 0.3) { // 30% chance to have a secondary preference
      PlayerPosition secondary;
      do {
        secondary = PlayerPosition.values[random.nextInt(PlayerPosition.values.length)];
      } while (secondary == naturalPositionValue); // Ensure it's different
      preferred.add(secondary);
    }

    return Player(
      id: id,
      name: name,
      age: age,
      naturalPosition: naturalPositionValue, // Use the new field name
      // currentSkill: currentSkill, // Removed
      potentialSkill: potentialSkill,
      weeklyWage: weeklyWage,
      isScouted: true, // Mark as scouted initially
      reputation: random.nextInt(6),
      stamina: random.nextInt(51) + 35,
      preferredFormat: TournamentType.values[random.nextInt(TournamentType.values.length)],
      preferredPositions: preferred,
      aggression: randomStat(),
      composure: randomStat(),
      concentration: randomStat(),
      decision: randomStat(),
      determination: randomStat(),
      flair: randomStat(),
      leadership: randomStat(),
      teamwork: randomStat(),
      vision: randomStat(),
      workRate: randomStat(),
      // Physical
      acceleration: randomStat(),
      agility: randomStat(),
      balance: randomStat(),
      jumpingReach: randomStat(),
      naturalFitness: randomStat(),
      pace: randomStat(),
      strength: randomStat(),
      // Attacking
      crossing: randomStat(),
      dribbling: randomStat(),
      finishing: randomStat(),
      firstTouch: randomStat(),
      heading: randomStat(),
      longShots: randomStat(),
      passing: randomStat(),
      penaltyTaking: randomStat(),
      technique: randomStat(),
      // Defending
      marking: randomStat(),
      tackling: randomStat(),
      defensivePositioning: randomStat(),
      // Goalkeeping - potentially make these higher if GK, lower otherwise
      aerialReach: naturalPositionValue == PlayerPosition.Goalkeeper ? randomStat() + 5 : randomStat() -2,
      commandOfArea: naturalPositionValue == PlayerPosition.Goalkeeper ? randomStat() + 5 : randomStat() -2,
      communicationGK: naturalPositionValue == PlayerPosition.Goalkeeper ? randomStat() + 5 : randomStat() -2,
      eccentricity: naturalPositionValue == PlayerPosition.Goalkeeper ? randomStat() + 5 : randomStat() -2,
      handling: naturalPositionValue == PlayerPosition.Goalkeeper ? randomStat() + 5 : randomStat() -2,
      kicking: naturalPositionValue == PlayerPosition.Goalkeeper ? randomStat() + 5 : randomStat() -2,
      oneOnOnes: naturalPositionValue == PlayerPosition.Goalkeeper ? randomStat() + 5 : randomStat() -2,
      reflexes: naturalPositionValue == PlayerPosition.Goalkeeper ? randomStat() + 5 : randomStat() -2,
      rushingOut: naturalPositionValue == PlayerPosition.Goalkeeper ? randomStat() + 5 : randomStat() -2,
      throwing: naturalPositionValue == PlayerPosition.Goalkeeper ? randomStat() + 5 : randomStat() -2,
      // lastMatchRating defaults to null
      // Other new fields like matchesPlayed, goals, assists, fatigue, status keep their defaults (0, 0, 0, 0.0, Reserve)
    );
  }

  // --- Current Skill Getter ---
  // Returns the player's skill in their currently assigned position.
  int get currentSkill {
    // Ensure positionalAffinity is initialized and contains the assignedPosition.
    // If not, it might indicate an issue with initialization or an invalid assignedPosition.
    // Fallback to a low value or throw an error if necessary.
    return positionalAffinity[assignedPosition] ?? 10; // Fallback to 10 if not found
  }

  // --- Method to Recalculate Positional Affinities ---
  // This should be called after any underlying detailed stats change (e.g., through training).
  void updatePositionalAffinities() {
    _calculatePositionalAffinities();
  }

  // --- Private method to calculate affinities for all positions ---
  void _calculatePositionalAffinities() {
    positionalAffinity[PlayerPosition.Goalkeeper] = _calculateGKRating();
    positionalAffinity[PlayerPosition.Defender] = _calculateDefRating();
    positionalAffinity[PlayerPosition.Midfielder] = _calculateMidRating();
    positionalAffinity[PlayerPosition.Forward] = _calculateFwdRating();
  }

  // Helper to scale and clamp raw scores to 1-100 range, respecting potentialSkill
  int _scaleAndClamp(double rawScore, {int minSkill = 15, int maxSkill = 99}) {
    // Assuming raw scores are roughly in a 0-20 or 0-100 range from attribute averages
    // This scaling might need adjustment based on how raw scores are derived.
    // For now, let's assume attributes are 1-20, so an average is also 1-20.
    // We want to map this to a 1-100 (effectively minSkill to potentialSkill) range.
    // A simple scaling: (rawScore / 20) * 100.
    // More robust: map from [avg_min_attr, avg_max_attr] to [minSkill, potentialSkill]
    // For now, let's use a direct scaling assuming attributes are 1-20.
    // A player with all 1s should be low, all 20s should be high.
    // Let's say average of 10 maps to ~50. Average of 20 maps to ~90-99. Average of 1 maps to ~10-20.

    // Simplified scaling: (average_attribute / 20) * 90 + 10
    // This gives a range of 10 (all 0s, though attributes are 1-20) to 100 (all 20s)
    // Let's adjust to use the 1-20 attribute range more directly.
    // Max possible sum of 10 attributes (if each is 20) = 200. Min sum (if each is 1) = 10.
    // Let's use a simpler approach: average the key stats (which are 1-20), then scale that average.
    // If average is X (1-20), then skill = (X-1 * (99-15)/19) + 15. This maps 1->15, 20->99.

    double scaled = ((rawScore - 1) / 19.0) * (maxSkill - minSkill) + minSkill;
    return scaled.round().clamp(minSkill, potentialSkill); // Clamp by overall potential
  }


  // --- Individual Position Rating Calculations ---
  // These are examples and can be heavily customized.
  // Weights should sum to 1.0 for a direct weighted average.
  // Or, can be simpler averages of key stats.

  int _calculateGKRating() {
    // Key GK stats: Handling, Reflexes, Aerial Reach, Command of Area, One on Ones, Communication
    // Physical: Agility, Jumping Reach
    // Mental: Composure, Concentration, Decision
    double rawScore = (
      (handling * 3) + (reflexes * 3) + (aerialReach * 2) + (commandOfArea * 2) + (oneOnOnes * 2) + (communicationGK * 2) + // GK specific
      (agility * 1) + (jumpingReach * 1) + // Physical
      (composure * 1) + (concentration * 2) + (decision * 1) // Mental
    ) / 20.0; // Sum of weights = 20
    return _scaleAndClamp(rawScore);
  }

  int _calculateDefRating() {
    // Key Def stats: Tackling, Marking, Defensive Positioning, Heading
    // Physical: Strength, Pace, Acceleration, Jumping Reach, Stamina
    // Mental: Aggression, Composure, Concentration, Decision, Work Rate
    double rawScore = (
      (tackling * 3) + (marking * 3) + (defensivePositioning * 3) + (heading * 2) + // Defensive
      (strength * 2) + (pace * 1) + (acceleration * 1) + (jumpingReach * 1) + (stamina * 1) + // Physical
      (aggression * 1) + (composure * 1) + (concentration * 2) + (decision * 1) + (workRate * 1) // Mental
    ) / 23.0; // Sum of weights = 23
    return _scaleAndClamp(rawScore);
  }

  int _calculateMidRating() {
    // Key Mid stats: Passing, First Touch, Technique, Vision, Dribbling
    // Physical: Stamina, Pace, Agility, Balance
    // Mental: Decision, Teamwork, Work Rate, Composure, Flair
    // Attacking/Defending mix: Long Shots, Tackling
    double rawScore = (
      (passing * 3) + (firstTouch * 2) + (technique * 2) + (vision * 3) + (dribbling * 2) + // Core Mid
      (stamina * 2) + (pace * 1) + (agility * 1) + (balance * 1) + // Physical
      (decision * 2) + (teamwork * 2) + (workRate * 2) + (composure * 1) + (flair * 1) + // Mental
      (longShots * 1) + (tackling * 1) // Hybrid
    ) / 27.0; // Sum of weights = 27
    return _scaleAndClamp(rawScore);
  }

   int _calculateFwdRating() {
    // Key Fwd stats: Finishing, Dribbling, Heading, Long Shots, First Touch
    // Physical: Pace, Acceleration, Agility, Strength
    // Mental: Composure, Flair, Decision, Work Rate
    double rawScore = (
      (finishing * 3) + (dribbling * 2) + (heading * 2) + (longShots * 2) + (firstTouch * 2) + // Attacking
      (pace * 2) + (acceleration * 2) + (agility * 1) + (strength * 1) + // Physical
      (composure * 2) + (flair * 2) + (decision * 1) + (workRate * 1) // Mental
    ) / 23.0; // Sum of weights = 23
    return _scaleAndClamp(rawScore);
  }


  String get positionString {
    switch (assignedPosition) { // Changed from position to assignedPosition
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
    double baseValue = pow(currentSkill, 2) * 10;

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
    ageModifier = ageModifier.clamp(0.1, 1.3); // Ensure modifier stays within bounds

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

  // --- Training Logic ---
  static const int maxAttributeValue = 20; // Define max for individual attributes

  // Helper to get a list of key attributes for a position
  static final Map<PlayerPosition, List<String>> _positionKeyAttributes = {
    PlayerPosition.Goalkeeper: ['handling', 'reflexes', 'aerialReach', 'commandOfArea', 'oneOnOnes', 'communicationGK', 'kicking', 'concentration', 'decision', 'positioning'], // Added positioning as a general term, maps to defensivePositioning for GKs too
    PlayerPosition.Defender: ['tackling', 'marking', 'defensivePositioning', 'heading', 'strength', 'aggression', 'concentration', 'decision', 'workRate', 'stamina'],
    PlayerPosition.Midfielder: ['passing', 'firstTouch', 'technique', 'vision', 'dribbling', 'teamwork', 'decision', 'workRate', 'stamina', 'longShots', 'tackling', 'finishing'],
    PlayerPosition.Forward: ['finishing', 'dribbling', 'longShots', 'firstTouch', 'pace', 'acceleration', 'flair', 'composure', 'heading', 'technique'],
  };

  // Method to improve a specific attribute by name
  bool _improveSpecificAttribute(String attributeName, int amount) {
    bool improved = false;
    int currentValue = 0;

    // Helper lambda to update and clamp
    int update(int current, int amt) => (current + amt).clamp(0, maxAttributeValue);

    switch (attributeName) {
      case 'aggression': currentValue = aggression; aggression = update(aggression, amount); improved = aggression > currentValue; break;
      case 'composure': currentValue = composure; composure = update(composure, amount); improved = composure > currentValue; break;
      case 'concentration': currentValue = concentration; concentration = update(concentration, amount); improved = concentration > currentValue; break;
      case 'decision': currentValue = decision; decision = update(decision, amount); improved = decision > currentValue; break;
      case 'determination': currentValue = determination; determination = update(determination, amount); improved = determination > currentValue; break;
      case 'flair': currentValue = flair; flair = update(flair, amount); improved = flair > currentValue; break;
      case 'leadership': currentValue = leadership; leadership = update(leadership, amount); improved = leadership > currentValue; break;
      case 'teamwork': currentValue = teamwork; teamwork = update(teamwork, amount); improved = teamwork > currentValue; break;
      case 'vision': currentValue = vision; vision = update(vision, amount); improved = vision > currentValue; break;
      case 'workRate': currentValue = workRate; workRate = update(workRate, amount); improved = workRate > currentValue; break;
      case 'acceleration': currentValue = acceleration; acceleration = update(acceleration, amount); improved = acceleration > currentValue; break;
      case 'agility': currentValue = agility; agility = update(agility, amount); improved = agility > currentValue; break;
      case 'balance': currentValue = balance; balance = update(balance, amount); improved = balance > currentValue; break;
      case 'jumpingReach': currentValue = jumpingReach; jumpingReach = update(jumpingReach, amount); improved = jumpingReach > currentValue; break;
      case 'naturalFitness': currentValue = naturalFitness; naturalFitness = update(naturalFitness, amount); improved = naturalFitness > currentValue; break;
      case 'pace': currentValue = pace; pace = update(pace, amount); improved = pace > currentValue; break;
      case 'strength': currentValue = strength; strength = update(strength, amount); improved = strength > currentValue; break;
      case 'stamina': currentValue = stamina; stamina = update(stamina, amount); improved = stamina > currentValue; break;
      case 'crossing': currentValue = crossing; crossing = update(crossing, amount); improved = crossing > currentValue; break;
      case 'dribbling': currentValue = dribbling; dribbling = update(dribbling, amount); improved = dribbling > currentValue; break;
      case 'finishing': currentValue = finishing; finishing = update(finishing, amount); improved = finishing > currentValue; break;
      case 'firstTouch': currentValue = firstTouch; firstTouch = update(firstTouch, amount); improved = firstTouch > currentValue; break;
      case 'heading': currentValue = heading; heading = update(heading, amount); improved = heading > currentValue; break;
      case 'longShots': currentValue = longShots; longShots = update(longShots, amount); improved = longShots > currentValue; break;
      case 'passing': currentValue = passing; passing = update(passing, amount); improved = passing > currentValue; break;
      case 'penaltyTaking': currentValue = penaltyTaking; penaltyTaking = update(penaltyTaking, amount); improved = penaltyTaking > currentValue; break;
      case 'technique': currentValue = technique; technique = update(technique, amount); improved = technique > currentValue; break;
      case 'marking': currentValue = marking; marking = update(marking, amount); improved = marking > currentValue; break;
      case 'tackling': currentValue = tackling; tackling = update(tackling, amount); improved = tackling > currentValue; break;
      case 'defensivePositioning': currentValue = defensivePositioning; defensivePositioning = update(defensivePositioning, amount); improved = defensivePositioning > currentValue; break;
      case 'positioning': // General positioning, map to defensivePositioning for now
        currentValue = defensivePositioning; defensivePositioning = update(defensivePositioning, amount); improved = defensivePositioning > currentValue; break;
      case 'aerialReach': currentValue = aerialReach; aerialReach = update(aerialReach, amount); improved = aerialReach > currentValue; break;
      case 'commandOfArea': currentValue = commandOfArea; commandOfArea = update(commandOfArea, amount); improved = commandOfArea > currentValue; break;
      case 'communicationGK': currentValue = communicationGK; communicationGK = update(communicationGK, amount); improved = communicationGK > currentValue; break;
      case 'eccentricity': currentValue = eccentricity; eccentricity = update(eccentricity, amount); improved = eccentricity > currentValue; break;
      case 'handling': currentValue = handling; handling = update(handling, amount); improved = handling > currentValue; break;
      case 'kicking': currentValue = kicking; kicking = update(kicking, amount); improved = kicking > currentValue; break;
      case 'oneOnOnes': currentValue = oneOnOnes; oneOnOnes = update(oneOnOnes, amount); improved = oneOnOnes > currentValue; break;
      case 'reflexes': currentValue = reflexes; reflexes = update(reflexes, amount); improved = reflexes > currentValue; break;
      case 'rushingOut': currentValue = rushingOut; rushingOut = update(rushingOut, amount); improved = rushingOut > currentValue; break;
      case 'throwing': currentValue = throwing; throwing = update(throwing, amount); improved = throwing > currentValue; break;
      default:
        // print("Warning: Unknown attribute '$attributeName' for improvement."); // Less verbose
        return false;
    }
    return improved && currentValue < maxAttributeValue; // Ensure it actually improved and wasn't already maxed
  }

  // Training method: Returns true if any attribute was successfully improved.
  bool train({PlayerPosition? focusPosition, int improvementAmount = 1}) {
    PlayerPosition positionToTrain = focusPosition ?? assignedPosition;
    List<String>? attributesToTrain = _positionKeyAttributes[positionToTrain];

    if (attributesToTrain == null || attributesToTrain.isEmpty) {
      // print("Warning: No key attributes defined for position $positionToTrain"); // Less verbose
      return false;
    }

    // Try to improve one random attribute from the list for the given position
    List<String> shuffledAttributes = List.from(attributesToTrain)..shuffle(Random());
    bool improvementMade = false;
    for (String attrName in shuffledAttributes) {
      if (_improveSpecificAttribute(attrName, improvementAmount)) {
        improvementMade = true;
        break; // Improve one attribute per training call
      }
    }

    if (improvementMade) {
      updatePositionalAffinities(); // Recalculate overall skills
    }
    return improvementMade;
  }
  // --- End Training Logic ---
}
