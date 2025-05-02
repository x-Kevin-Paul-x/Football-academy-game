// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeagueStanding _$LeagueStandingFromJson(Map<String, dynamic> json) =>
    LeagueStanding(
      teamId: json['teamId'] as String,
      played: (json['played'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      draws: (json['draws'] as num?)?.toInt() ?? 0,
      losses: (json['losses'] as num?)?.toInt() ?? 0,
      goalsFor: (json['goalsFor'] as num?)?.toInt() ?? 0,
      goalsAgainst: (json['goalsAgainst'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$LeagueStandingToJson(LeagueStanding instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'played': instance.played,
      'wins': instance.wins,
      'draws': instance.draws,
      'losses': instance.losses,
      'goalsFor': instance.goalsFor,
      'goalsAgainst': instance.goalsAgainst,
    };

Tournament _$TournamentFromJson(Map<String, dynamic> json) => Tournament(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$TournamentTypeEnumMap, json['type']),
      format: $enumDecode(_$TournamentFormatEnumMap, json['format']),
      requiredReputation: (json['requiredReputation'] as num).toInt(),
      entryFee: (json['entryFee'] as num).toInt(),
      prizeMoneyBase: (json['prizeMoneyBase'] as num).toInt(),
      numberOfTeams: (json['numberOfTeams'] as num).toInt(),
      rounds: (json['rounds'] as num).toInt(),
      teamIds:
          (json['teamIds'] as List<dynamic>).map((e) => e as String).toList(),
      startDate: DateTime.parse(json['startDate'] as String),
      status: $enumDecodeNullable(_$TournamentStatusEnumMap, json['status']) ??
          TournamentStatus.Scheduled,
      matches: (json['matches'] as List<dynamic>?)
              ?.map((e) => Match.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      winnerId: json['winnerId'] as String?,
      baseId: json['baseId'] as String?,
      currentRound: (json['currentRound'] as num?)?.toInt() ?? 1,
      currentByeTeamId: json['currentByeTeamId'] as String?,
    )
      ..leagueStandings = (json['leagueStandings'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, LeagueStanding.fromJson(e as Map<String, dynamic>)),
      )
      ..roundByes = (json['roundByes'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k),
            (e as List<dynamic>).map((e) => e as String).toList()),
      );

Map<String, dynamic> _$TournamentToJson(Tournament instance) =>
    <String, dynamic>{
      'baseId': instance.baseId,
      'name': instance.name,
      'type': _$TournamentTypeEnumMap[instance.type]!,
      'format': _$TournamentFormatEnumMap[instance.format]!,
      'requiredReputation': instance.requiredReputation,
      'entryFee': instance.entryFee,
      'prizeMoneyBase': instance.prizeMoneyBase,
      'numberOfTeams': instance.numberOfTeams,
      'rounds': instance.rounds,
      'id': instance.id,
      'teamIds': instance.teamIds,
      'startDate': instance.startDate.toIso8601String(),
      'status': _$TournamentStatusEnumMap[instance.status]!,
      'matches': instance.matches.map((e) => e.toJson()).toList(),
      'winnerId': instance.winnerId,
      'currentRound': instance.currentRound,
      'currentByeTeamId': instance.currentByeTeamId,
      'leagueStandings':
          instance.leagueStandings.map((k, e) => MapEntry(k, e.toJson())),
      'roundByes': instance.roundByes.map((k, e) => MapEntry(k.toString(), e)),
    };

const _$TournamentTypeEnumMap = {
  TournamentType.threeVthree: 'threeVthree',
  TournamentType.fiveVfive: 'fiveVfive',
  TournamentType.sevenVseven: 'sevenVseven',
  TournamentType.elevenVeleven: 'elevenVeleven',
};

const _$TournamentFormatEnumMap = {
  TournamentFormat.Knockout: 'Knockout',
  TournamentFormat.League: 'League',
};

const _$TournamentStatusEnumMap = {
  TournamentStatus.Scheduled: 'Scheduled',
  TournamentStatus.InProgress: 'InProgress',
  TournamentStatus.Completed: 'Completed',
  TournamentStatus.Cancelled: 'Cancelled',
};
