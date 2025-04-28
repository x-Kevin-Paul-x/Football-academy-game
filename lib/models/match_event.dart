import 'package:json_annotation/json_annotation.dart'; // Added for JSON serialization

part 'match_event.g.dart'; // Added for generated code

// Represents a single event occurring during a match simulation.
enum MatchEventType {
  KickOff,
  Goal,
  Assist, // Optional: Could be linked to a Goal event
  Save,   // Optional
  Foul,   // Optional
  YellowCard, // Optional
  RedCard,    // Optional
  Substitution, // Optional
  HalfTime,
  FullTime,
  // Add more specific events like 'ShotOnTarget', 'Tackle', 'Pass', etc. for more detail
}

@JsonSerializable() // Added annotation
class MatchEvent {
  final int minute; // Minute the event occurred (0-90+)
  final MatchEventType type;
  final String teamId; // ID of the team involved (or null if neutral like HalfTime)
  final String? playerId; // ID of the player primarily involved (if applicable)
  final String description; // Text description (e.g., "Goal scored by Player X!")

  MatchEvent({
    required this.minute,
    required this.type,
    required this.teamId,
    this.playerId,
    required this.description,
  });

  @override
  String toString() {
    return "$minute': $description"; // Simple string representation for logging
  }

  // Added methods for JSON serialization
  factory MatchEvent.fromJson(Map<String, dynamic> json) => _$MatchEventFromJson(json);
  Map<String, dynamic> toJson() => _$MatchEventToJson(this);
}
