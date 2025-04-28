// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Match _$MatchFromJson(Map<String, dynamic> json) => Match(
      id: json['id'] as String,
      tournamentId: json['tournamentId'] as String,
      homeTeamId: json['homeTeamId'] as String,
      awayTeamId: json['awayTeamId'] as String,
      matchDate: DateTime.parse(json['matchDate'] as String),
      homeScore: (json['homeScore'] as num?)?.toInt() ?? 0,
      awayScore: (json['awayScore'] as num?)?.toInt() ?? 0,
      result: $enumDecodeNullable(_$MatchResultEnumMap, json['result']),
      isSimulated: json['isSimulated'] as bool? ?? false,
      homeLineup: (json['homeLineup'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      awayLineup: (json['awayLineup'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      eventLog: (json['eventLog'] as List<dynamic>?)
          ?.map((e) => MatchEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MatchToJson(Match instance) => <String, dynamic>{
      'id': instance.id,
      'tournamentId': instance.tournamentId,
      'homeTeamId': instance.homeTeamId,
      'awayTeamId': instance.awayTeamId,
      'matchDate': instance.matchDate.toIso8601String(),
      'homeScore': instance.homeScore,
      'awayScore': instance.awayScore,
      'result': _$MatchResultEnumMap[instance.result],
      'isSimulated': instance.isSimulated,
      'homeLineup': instance.homeLineup,
      'awayLineup': instance.awayLineup,
      'eventLog': instance.eventLog.map((e) => e.toJson()).toList(),
    };

const _$MatchResultEnumMap = {
  MatchResult.homeWin: 'homeWin',
  MatchResult.awayWin: 'awayWin',
  MatchResult.draw: 'draw',
};
