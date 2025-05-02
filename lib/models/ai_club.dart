import 'package:json_annotation/json_annotation.dart';
import 'player.dart';
import 'dart:math';

part 'ai_club.g.dart'; // Generated file

@JsonSerializable(explicitToJson: true) // Enable explicitToJson for nested Player list
class AIClub {
  final String id;
  String name;
  int reputation;
  double balance;
  List<Player> players;
  int skillLevel; // Average skill of the team, recalculated periodically
  int tier; // League tier (e.g., 1 = top, 2 = middle, 3 = bottom)
  int fanCount;
  double ticketPrice;

  AIClub({
    required this.id,
    required this.name,
    required this.reputation,
    required this.balance,
    required this.players,
    required this.skillLevel,
    required this.tier,
    required this.fanCount,
    required this.ticketPrice,
  });

  // Factory constructor for JSON deserialization
  factory AIClub.fromJson(Map<String, dynamic> json) => _$AIClubFromJson(json);

  // Method for JSON serialization
  Map<String, dynamic> toJson() => _$AIClubToJson(this);

  // Initial generation logic (Improved)
  factory AIClub.initial(int index, {int initialTier = 3}) {
    final random = Random();
    String generatedName = _generateClubName(index, random);
    // Tier influences initial stats significantly
    int baseReputation = 50 + (3 - initialTier) * 50 + random.nextInt(51); // Tier 1: 150-200, Tier 2: 100-150, Tier 3: 50-100
    double initialBalance = 100000.0 + (3 - initialTier) * 200000.0 + random.nextDouble() * 100000.0; // Tier 1: 300k-400k, Tier 2: 200k-300k, Tier 3: 100k-200k
    int initialSkill = 30 + (3 - initialTier) * 20 + random.nextInt(21); // Tier 1: 70-90, Tier 2: 50-70, Tier 3: 30-50
    int initialFanCount = 1000 + (3 - initialTier) * 5000 + random.nextInt(2001); // Tier 1: 11k-13k, Tier 2: 6k-8k, Tier 3: 1k-3k
    double initialTicketPrice = 10.0 + (3 - initialTier) * 15.0 + random.nextDouble() * 5.0; // Tier 1: 40-45, Tier 2: 25-30, Tier 3: 10-15

    return AIClub(
      id: 'ai_club_$index',
      name: generatedName,
      reputation: baseReputation.clamp(10, 250), // Clamp reputation
      balance: initialBalance,
      players: [], // Players will be added separately by GameStateManager
      skillLevel: initialSkill.clamp(10, 95), // Clamp skill
      tier: initialTier,
      fanCount: initialFanCount.clamp(500, 50000), // Clamp fan count
      ticketPrice: initialTicketPrice.clamp(5.0, 100.0), // Clamp ticket price
    );
  }

  // Helper to generate somewhat realistic names
  static String _generateClubName(int index, Random random) {
    List<String> prefixes = ["Real", "Athletic", "United", "City", "Wanderers", "Rovers", "County", "Town", "FC", "Sporting", "Olympic"];
    List<String> locations = ["Northwood", "Southport", "Easton", "Westfield", "Riverdale", "Hillcrest", "Oakridge", "Maple Creek", "Bridgewater", "Stonebridge", "Ashford", "Glenwood", "Lakeside", "Pinehurst", "Fairview", "Milltown", "Bayview", "Summit"];
    List<String> suffixes = ["FC", "United", "City", "Town", "Rovers", "Athletic", "SC", ""]; // Added SC, empty suffix

    String prefix = prefixes[random.nextInt(prefixes.length)];
    String location = locations[random.nextInt(locations.length)];
    String suffix = suffixes[random.nextInt(suffixes.length)];

    // Avoid duplicates like "City City" or "United United"
    if (prefix == location || prefix == suffix || (location == suffix && suffix.isNotEmpty)) {
      // Simple fallback: just use location + FC or location + SC
      return "$location ${random.nextBool() ? 'FC' : 'SC'}";
    }

    // Construct the name, ensuring spacing and avoiding double suffixes
    String name = "";
    if (prefix == "FC" || prefix == "SC" || prefix == "Sporting" || prefix == "Olympic") { // Prefixes that usually come after
        name = "$location $prefix";
    } else {
        name = "$prefix $location";
    }

    if (suffix.isNotEmpty && suffix != prefix && suffix != location) {
        // Avoid adding suffix if it's already implied (e.g., "Northwood City City")
        if (!name.endsWith(suffix)) {
             name = "$name $suffix";
        }
    }

    // Ensure name isn't too generic like just "FC" or "United" if suffix was empty
    if (name.split(" ").length < 2) {
        // Try location + different suffix/prefix
        String backupSuffix = suffixes[random.nextInt(suffixes.length)];
        if (backupSuffix.isNotEmpty && backupSuffix != location) {
            name = "$location $backupSuffix";
        } else {
            name = "${prefixes[random.nextInt(prefixes.length)]} $location"; // Add a random prefix
        }
    }

    return name.replaceAll("  ", " ").trim(); // Clean up potential double spaces
  }

  // Method to recalculate the club's overall skill level based on players
  void updateSkillLevel() {
    if (players.isEmpty) {
      // Keep existing skill level or set a default low? Let's keep it for now.
      // skillLevel = 20;
      return;
    }
    // Simple average for now, could be weighted by position or top N players later
    double totalSkill = players.fold(0, (sum, player) => sum + player.currentSkill);
    skillLevel = (totalSkill / players.length).round().clamp(1, 100);
  }
}
