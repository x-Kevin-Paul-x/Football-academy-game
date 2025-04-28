// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tournament _$TournamentFromJson(Map<String, dynamic> json) => Tournament(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$TournamentTypeEnumMap, json['type']),
      requiredPlayers: (json['requiredPlayers'] as num).toInt(),
      participants: (json['participants'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      prize: json['prize'] as String,
      requiredReputation: (json['requiredReputation'] as num).toInt(),
      winner: json['winner'] as String?,
      status: $enumDecodeNullable(_$TournamentStatusEnumMap, json['status']) ??
          TournamentStatus.Available,
      matches: (json['matches'] as List<dynamic>?)
              ?.map((e) => Match.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      baseId: json['baseId'] as String?,
    );

Map<String, dynamic> _$TournamentToJson(Tournament instance) =>
    <String, dynamic>{
      'id': instance.id,
      'baseId': instance.baseId,
      'name': instance.name,
      'type': _$TournamentTypeEnumMap[instance.type]!,
      'requiredPlayers': instance.requiredPlayers,
      'participants': instance.participants,
      'prize': instance.prize,
      'requiredReputation': instance.requiredReputation,
      'winner': instance.winner,
      'status': _$TournamentStatusEnumMap[instance.status]!,
      'matches': instance.matches.map((e) => e.toJson()).toList(),
    };

const _$TournamentTypeEnumMap = {
  TournamentType.threeVthree: 'threeVthree',
  TournamentType.fiveVfive: 'fiveVfive',
  TournamentType.sevenVseven: 'sevenVseven',
  TournamentType.elevenVeleven: 'elevenVeleven',
};

const _$TournamentStatusEnumMap = {
  TournamentStatus.Available: 'Available',
  TournamentStatus.InProgress: 'InProgress',
  TournamentStatus.Completed: 'Completed',
};
