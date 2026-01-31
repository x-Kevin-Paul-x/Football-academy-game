// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
      id: json['id'] as String,
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
      naturalPosition:
          $enumDecode(_$PlayerPositionEnumMap, json['naturalPosition']),
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
      preferredPositions: (json['preferredPositions'] as List<dynamic>)
          .map((e) => $enumDecode(_$PlayerPositionEnumMap, e))
          .toList(),
      lastMatchRating: (json['lastMatchRating'] as num?)?.toDouble(),
      aggression: (json['aggression'] as num?)?.toInt() ?? 10,
      composure: (json['composure'] as num?)?.toInt() ?? 10,
      concentration: (json['concentration'] as num?)?.toInt() ?? 10,
      decision: (json['decision'] as num?)?.toInt() ?? 10,
      determination: (json['determination'] as num?)?.toInt() ?? 10,
      flair: (json['flair'] as num?)?.toInt() ?? 10,
      leadership: (json['leadership'] as num?)?.toInt() ?? 10,
      teamwork: (json['teamwork'] as num?)?.toInt() ?? 10,
      vision: (json['vision'] as num?)?.toInt() ?? 10,
      workRate: (json['workRate'] as num?)?.toInt() ?? 10,
      acceleration: (json['acceleration'] as num?)?.toInt() ?? 10,
      agility: (json['agility'] as num?)?.toInt() ?? 10,
      balance: (json['balance'] as num?)?.toInt() ?? 10,
      jumpingReach: (json['jumpingReach'] as num?)?.toInt() ?? 10,
      naturalFitness: (json['naturalFitness'] as num?)?.toInt() ?? 10,
      pace: (json['pace'] as num?)?.toInt() ?? 10,
      strength: (json['strength'] as num?)?.toInt() ?? 10,
      crossing: (json['crossing'] as num?)?.toInt() ?? 10,
      dribbling: (json['dribbling'] as num?)?.toInt() ?? 10,
      finishing: (json['finishing'] as num?)?.toInt() ?? 10,
      firstTouch: (json['firstTouch'] as num?)?.toInt() ?? 10,
      heading: (json['heading'] as num?)?.toInt() ?? 10,
      longShots: (json['longShots'] as num?)?.toInt() ?? 10,
      passing: (json['passing'] as num?)?.toInt() ?? 10,
      penaltyTaking: (json['penaltyTaking'] as num?)?.toInt() ?? 10,
      technique: (json['technique'] as num?)?.toInt() ?? 10,
      marking: (json['marking'] as num?)?.toInt() ?? 10,
      tackling: (json['tackling'] as num?)?.toInt() ?? 10,
      defensivePositioning:
          (json['defensivePositioning'] as num?)?.toInt() ?? 10,
      aerialReach: (json['aerialReach'] as num?)?.toInt() ?? 10,
      commandOfArea: (json['commandOfArea'] as num?)?.toInt() ?? 10,
      communicationGK: (json['communicationGK'] as num?)?.toInt() ?? 10,
      eccentricity: (json['eccentricity'] as num?)?.toInt() ?? 10,
      handling: (json['handling'] as num?)?.toInt() ?? 10,
      kicking: (json['kicking'] as num?)?.toInt() ?? 10,
      oneOnOnes: (json['oneOnOnes'] as num?)?.toInt() ?? 10,
      reflexes: (json['reflexes'] as num?)?.toInt() ?? 10,
      rushingOut: (json['rushingOut'] as num?)?.toInt() ?? 10,
      throwing: (json['throwing'] as num?)?.toInt() ?? 10,
    )..assignedPosition =
        $enumDecode(_$PlayerPositionEnumMap, json['assignedPosition']);

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'age': instance.age,
      'naturalPosition': _$PlayerPositionEnumMap[instance.naturalPosition]!,
      'assignedPosition': _$PlayerPositionEnumMap[instance.assignedPosition]!,
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
      'preferredPositions': instance.preferredPositions
          .map((e) => _$PlayerPositionEnumMap[e]!)
          .toList(),
      'lastMatchRating': instance.lastMatchRating,
      'aggression': instance.aggression,
      'composure': instance.composure,
      'concentration': instance.concentration,
      'decision': instance.decision,
      'determination': instance.determination,
      'flair': instance.flair,
      'leadership': instance.leadership,
      'teamwork': instance.teamwork,
      'vision': instance.vision,
      'workRate': instance.workRate,
      'acceleration': instance.acceleration,
      'agility': instance.agility,
      'balance': instance.balance,
      'jumpingReach': instance.jumpingReach,
      'naturalFitness': instance.naturalFitness,
      'pace': instance.pace,
      'strength': instance.strength,
      'crossing': instance.crossing,
      'dribbling': instance.dribbling,
      'finishing': instance.finishing,
      'firstTouch': instance.firstTouch,
      'heading': instance.heading,
      'longShots': instance.longShots,
      'passing': instance.passing,
      'penaltyTaking': instance.penaltyTaking,
      'technique': instance.technique,
      'marking': instance.marking,
      'tackling': instance.tackling,
      'defensivePositioning': instance.defensivePositioning,
      'aerialReach': instance.aerialReach,
      'commandOfArea': instance.commandOfArea,
      'communicationGK': instance.communicationGK,
      'eccentricity': instance.eccentricity,
      'handling': instance.handling,
      'kicking': instance.kicking,
      'oneOnOnes': instance.oneOnOnes,
      'reflexes': instance.reflexes,
      'rushingOut': instance.rushingOut,
      'throwing': instance.throwing,
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
