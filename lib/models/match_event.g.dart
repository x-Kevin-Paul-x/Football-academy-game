// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchEvent _$MatchEventFromJson(Map<String, dynamic> json) => MatchEvent(
      minute: (json['minute'] as num).toInt(),
      type: $enumDecode(_$MatchEventTypeEnumMap, json['type']),
      teamId: json['teamId'] as String,
      playerId: json['playerId'] as String?,
      description: json['description'] as String,
    );

Map<String, dynamic> _$MatchEventToJson(MatchEvent instance) =>
    <String, dynamic>{
      'minute': instance.minute,
      'type': _$MatchEventTypeEnumMap[instance.type]!,
      'teamId': instance.teamId,
      'playerId': instance.playerId,
      'description': instance.description,
    };

const _$MatchEventTypeEnumMap = {
  MatchEventType.KickOff: 'KickOff',
  MatchEventType.Goal: 'Goal',
  MatchEventType.Assist: 'Assist',
  MatchEventType.Save: 'Save',
  MatchEventType.Foul: 'Foul',
  MatchEventType.YellowCard: 'YellowCard',
  MatchEventType.RedCard: 'RedCard',
  MatchEventType.Substitution: 'Substitution',
  MatchEventType.HalfTime: 'HalfTime',
  MatchEventType.FullTime: 'FullTime',
};
