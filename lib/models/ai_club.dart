import 'package:flutter/material.dart';
import 'dart:math'; // Import Random
import 'player.dart'; // Import the actual Player model

class AIClub {
  final String id;
  final String name;
  final Color primaryColor; // For visual distinction
  final Color secondaryColor;
  final int skillLevel; // Simple representation of overall strength (e.g., 1-100)
  List<Player> players; // List of players in the AI club

  AIClub({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.skillLevel,
    List<Player>? players, // Optional parameter
    // required this.squad,
  }) : this.players = players ?? _generatePlaceholderPlayers(id, skillLevel); // Initializer list

  // Factory constructor for generating placeholder clubs
  factory AIClub.placeholder(int index) {
    List<String> names = ['Raptors', 'Sharks', 'Eagles', 'Lions', 'Wolves', 'Bears', 'Tigers', 'Cobras'];
    List<Color> colors = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.yellow, Colors.teal, Colors.pink];
    return AIClub(
      id: 'ai_club_$index',
      name: '${names[index % names.length]} FC',
      primaryColor: colors[index % colors.length],
      secondaryColor: colors[(index + 1) % colors.length].withOpacity(0.7),
      skillLevel: 50 + (index * 5) % 50, // Basic skill progression
    );
  }

  // Helper to generate placeholder players for an AI club
  static List<Player> _generatePlaceholderPlayers(String clubId, int averageSkill) {
    final random = Random();
    // Generate enough players for 11v11 + some subs
    return List.generate(15 + random.nextInt(6), (i) {
      // Generate player skill somewhat centered around the club's average skill
      int skillVariance = 15;
      int potentialVariance = 10;
      // Ensure skill is within reasonable bounds (e.g., 10-99)
      int currentSkill = (averageSkill - skillVariance ~/ 2 + random.nextInt(skillVariance)).clamp(10, 99);
      // Ensure potential is >= current skill and within bounds
      int potentialSkill = (currentSkill + random.nextInt(potentialVariance + 5)).clamp(currentSkill, 99);

      // Determine position randomly for now
      PlayerPosition position = PlayerPosition.values[random.nextInt(PlayerPosition.values.length)];

      return Player(
        id: '${clubId}_player_$i',
        name: 'AI Player ${i + 1}', // Simple name
        age: 16 + random.nextInt(10), // Random age
        // nationality: 'AI', // Player model doesn't have nationality yet
        position: position, // Assign position
        currentSkill: currentSkill,
        potentialSkill: potentialSkill,
        weeklyWage: 0, // AI players don't need wages in our current model
        isScouted: false,
      );
    });
  }
}

// Placeholder for AI Player if needed later
// class AIPlayer {
//   final String name;
//   final int overallRating;
//   // Add specific attributes as needed
// }
