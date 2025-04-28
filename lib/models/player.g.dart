// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
      id: json['id'] as String,
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
      position: $enumDecode(_$PlayerPositionEnumMap, json['position']),
      currentSkill: (json['currentSkill'] as num).toInt(),
      potentialSkill: (json['potentialSkill'] as num).toInt(),
      weeklyWage: (json['weeklyWage'] as num).toInt(),
      isScouted: json['isScouted'] as bool? ?? false,
      reputation: (json['reputation'] as num?)?.toInt() ?? 0,
      matchesPlayed: (json['matchesPlayed'] as num?)?.toInt() ?? 0,
      goalsScored: (json['goalsScored'] as num?)?.toInt() ?? 0,
      assists: (json['assists'] as num?)?.toInt() ?? 0,
      preferredFormat: $enumDecodeNullable(
              _$TournamentTypeEnumMap, json['preferredFormat']) ??
          TournamentType.elevenVeleven,
      status: $enumDecodeNullable(_$PlayerStatusEnumMap, json['status']) ??
          PlayerStatus.Reserve,
      stamina: (json['stamina'] as num?)?.toInt() ?? 50,
      fatigue: (json['fatigue'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'age': instance.age,
      'position': _$PlayerPositionEnumMap[instance.position]!,
      'currentSkill': instance.currentSkill,
      'potentialSkill': instance.potentialSkill,
      'weeklyWage': instance.weeklyWage,
      'isScouted': instance.isScouted,
      'reputation': instance.reputation,
      'matchesPlayed': instance.matchesPlayed,
      'goalsScored': instance.goalsScored,
      'assists': instance.assists,
      'preferredFormat': _$TournamentTypeEnumMap[instance.preferredFormat]!,
      'status': _$PlayerStatusEnumMap[instance.status]!,
      'stamina': instance.stamina,
      'fatigue': instance.fatigue,
    };

const _$PlayerPositionEnumMap = {
  PlayerPosition.Goalkeeper: 'Goalkeeper',
  PlayerPosition.Defender: 'Defender',
  PlayerPosition.Midfielder: 'Midfielder',
  PlayerPosition.Forward: 'Forward',
};

const _$TournamentTypeEnumMap = {
  TournamentType.threeVthree: 'threeVthree',
  TournamentType.fiveVfive: 'fiveVfive',
  TournamentType.sevenVseven: 'sevenVseven',
  TournamentType.elevenVeleven: 'elevenVeleven',
};

const _$PlayerStatusEnumMap = {
  PlayerStatus.Starter: 'Starter',
  PlayerStatus.Bench: 'Bench',
  PlayerStatus.Reserve: 'Reserve',
  PlayerStatus.Injured: 'Injured',
  PlayerStatus.LoanedOut: 'LoanedOut',
};
