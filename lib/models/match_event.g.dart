// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchEvent _$MatchEventFromJson(Map<String, dynamic> json) => MatchEvent(
      playerId: json['playerId'] as String,
      teamId: json['teamId'] as String,
      type: $enumDecode(_$MatchEventTypeEnumMap, json['type']),
      minute: (json['minute'] as num).toInt(),
      description: json['description'] as String,
      assistedByPlayerId: json['assistedByPlayerId'] as String?,
    );

Map<String, dynamic> _$MatchEventToJson(MatchEvent instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'teamId': instance.teamId,
      'type': _$MatchEventTypeEnumMap[instance.type]!,
      'minute': instance.minute,
      'description': instance.description,
      'assistedByPlayerId': instance.assistedByPlayerId,
    };

const _$MatchEventTypeEnumMap = {
  MatchEventType.Goal: 'Goal',
  MatchEventType.Assist: 'Assist',
  MatchEventType.YellowCard: 'YellowCard',
  MatchEventType.RedCard: 'RedCard',
  MatchEventType.Substitution: 'Substitution',
  MatchEventType.Info: 'Info',
};
