import 'package:json_annotation/json_annotation.dart';

part 'match_event.g.dart';

enum MatchEventType {
  Goal,
  Assist,
  YellowCard, // Future use
  RedCard,    // Future use
  Substitution, // Future use
  Info,       // General info (e.g., forfeit)
}

@JsonSerializable()
class MatchEvent {
  final String playerId; // ID of the player involved (can be empty for Info)
  final String teamId;   // ID of the team involved (can be empty for Info)
  final MatchEventType type;
  final int minute;
  final String description;
  final String? assistedByPlayerId; // NEW: ID of the assisting player for goals

  MatchEvent({
    required this.playerId,
    required this.teamId,
    required this.type,
    required this.minute,
    required this.description,
    this.assistedByPlayerId, // Added to constructor
  });

  factory MatchEvent.fromJson(Map<String, dynamic> json) => _$MatchEventFromJson(json);
  Map<String, dynamic> toJson() => _$MatchEventToJson(this);
}
