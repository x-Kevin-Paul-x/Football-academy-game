import 'package:flutter/material.dart';
import 'dart:math'; // Import Random
import 'package:json_annotation/json_annotation.dart'; // Added for JSON serialization
import 'player.dart'; // Import the actual Player model

part 'ai_club.g.dart'; // Added for generated code

// Helper functions for Color serialization
Color _colorFromJson(int json) => Color(json);
int _colorToJson(Color color) => color.value;

@JsonSerializable(explicitToJson: true) // Added annotation, explicitToJson needed for List<Player>
class AIClub {
  final String id;
  final String name;

  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson) // Added converter for Color
  final Color primaryColor; // For visual distinction

  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson) // Added converter for Color
  final Color secondaryColor;

  final int skillLevel; // Simple representation of overall strength (e.g., 1-100)
  List<Player> players; // List of players in the AI club

  AIClub({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.skillLevel,
    required this.players, // Made required, will be populated by fromJson or placeholder factory
  });

  // Factory constructor for generating placeholder clubs
  factory AIClub.placeholder(int index) {
    List<String> names = ['Raptors', 'Sharks', 'Eagles', 'Lions', 'Wolves', 'Bears', 'Tigers', 'Cobras'];
    List<Color> colors = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.yellow, Colors.teal, Colors.pink];
    int skillLevel = 50 + (index * 5) % 50; // Basic skill progression
    String id = 'ai_club_$index';

    return AIClub(
      id: id,
      name: '${names[index % names.length]} FC',
      primaryColor: colors[index % colors.length],
      secondaryColor: colors[(index + 1) % colors.length].withOpacity(0.7),
      skillLevel: skillLevel,
      players: _generatePlaceholderPlayers(id, skillLevel), // Generate players here
    );
  }

  // Helper to generate placeholder players for an AI club (kept for placeholder factory)
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
        position: position, // Assign position
        currentSkill: currentSkill,
        potentialSkill: potentialSkill,
        weeklyWage: 0, // AI players don't need wages in our current model
        isScouted: false,
      );
    });
  }

  // Added methods for JSON serialization
  factory AIClub.fromJson(Map<String, dynamic> json) => _$AIClubFromJson(json);
  Map<String, dynamic> toJson() => _$AIClubToJson(this);
}
