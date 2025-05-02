// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Match _$MatchFromJson(Map<String, dynamic> json) => Match(
      id: json['id'] as String,
      tournamentId: json['tournamentId'] as String,
      round: (json['round'] as num).toInt(),
      matchDate: DateTime.parse(json['matchDate'] as String),
      homeTeamId: json['homeTeamId'] as String,
      awayTeamId: json['awayTeamId'] as String,
      isSimulated: json['isSimulated'] as bool? ?? false,
      result: $enumDecodeNullable(_$MatchResultEnumMap, json['result']),
      homeScore: (json['homeScore'] as num?)?.toInt() ?? 0,
      awayScore: (json['awayScore'] as num?)?.toInt() ?? 0,
      eventLog: (json['eventLog'] as List<dynamic>?)
          ?.map((e) => MatchEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      homeLineup: (json['homeLineup'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      awayLineup: (json['awayLineup'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      homePenaltyScore: (json['homePenaltyScore'] as num?)?.toInt(),
      awayPenaltyScore: (json['awayPenaltyScore'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MatchToJson(Match instance) => <String, dynamic>{
      'id': instance.id,
      'tournamentId': instance.tournamentId,
      'round': instance.round,
      'matchDate': instance.matchDate.toIso8601String(),
      'homeTeamId': instance.homeTeamId,
      'awayTeamId': instance.awayTeamId,
      'isSimulated': instance.isSimulated,
      'result': _$MatchResultEnumMap[instance.result],
      'homeScore': instance.homeScore,
      'awayScore': instance.awayScore,
      'eventLog': instance.eventLog.map((e) => e.toJson()).toList(),
      'homeLineup': instance.homeLineup,
      'awayLineup': instance.awayLineup,
      'homePenaltyScore': instance.homePenaltyScore,
      'awayPenaltyScore': instance.awayPenaltyScore,
    };

const _$MatchResultEnumMap = {
  MatchResult.homeWin: 'homeWin',
  MatchResult.awayWin: 'awayWin',
  MatchResult.draw: 'draw',
};
