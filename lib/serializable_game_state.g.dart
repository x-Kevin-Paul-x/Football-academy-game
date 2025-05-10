// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializable_game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SerializableGameState _$SerializableGameStateFromJson(
        Map<String, dynamic> json) =>
    SerializableGameState(
      currentDate: DateTime.parse(json['currentDate'] as String),
      academyName: json['academyName'] as String,
      academyPlayers: (json['academyPlayers'] as List<dynamic>)
          .map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList(),
      hiredStaff: (json['hiredStaff'] as List<dynamic>)
          .map((e) => Staff.fromJson(e as Map<String, dynamic>))
          .toList(),
      balance: (json['balance'] as num).toDouble(),
      weeklyIncome: (json['weeklyIncome'] as num).toInt(),
      totalWeeklyWages: (json['totalWeeklyWages'] as num).toInt(),
      activeTournaments: (json['activeTournaments'] as List<dynamic>)
          .map((e) => Tournament.fromJson(e as Map<String, dynamic>))
          .toList(),
      completedTournaments: (json['completedTournaments'] as List<dynamic>)
          .map((e) => Tournament.fromJson(e as Map<String, dynamic>))
          .toList(),
      trainingFacilityLevel: (json['trainingFacilityLevel'] as num).toInt(),
      scoutingFacilityLevel: (json['scoutingFacilityLevel'] as num).toInt(),
      medicalBayLevel: (json['medicalBayLevel'] as num).toInt(),
      merchandiseStoreLevel: (json['merchandiseStoreLevel'] as num?)?.toInt(),
      fans: (json['fans'] as num?)?.toInt(),
      academyReputation: (json['academyReputation'] as num).toInt(),
      newsItems: (json['newsItems'] as List<dynamic>)
          .map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      difficulty: $enumDecode(_$DifficultyEnumMap, json['difficulty']),
      themeMode:
          SerializableGameState._themeModeFromJson(json['themeMode'] as String),
      rivalAcademies: (json['rivalAcademies'] as List<dynamic>)
          .map((e) => RivalAcademy.fromJson(e as Map<String, dynamic>))
          .toList(),
      aiClubs: (json['aiClubs'] as List<dynamic>)
          .map((e) => AIClub.fromJson(e as Map<String, dynamic>))
          .toList(),
      playerAcademyTier: (json['playerAcademyTier'] as num).toInt(),
    );

Map<String, dynamic> _$SerializableGameStateToJson(
        SerializableGameState instance) =>
    <String, dynamic>{
      'currentDate': instance.currentDate.toIso8601String(),
      'academyName': instance.academyName,
      'academyPlayers': instance.academyPlayers.map((e) => e.toJson()).toList(),
      'hiredStaff': instance.hiredStaff.map((e) => e.toJson()).toList(),
      'balance': instance.balance,
      'weeklyIncome': instance.weeklyIncome,
      'totalWeeklyWages': instance.totalWeeklyWages,
      'activeTournaments':
          instance.activeTournaments.map((e) => e.toJson()).toList(),
      'completedTournaments':
          instance.completedTournaments.map((e) => e.toJson()).toList(),
      'trainingFacilityLevel': instance.trainingFacilityLevel,
      'scoutingFacilityLevel': instance.scoutingFacilityLevel,
      'medicalBayLevel': instance.medicalBayLevel,
      'merchandiseStoreLevel': instance.merchandiseStoreLevel,
      'fans': instance.fans,
      'academyReputation': instance.academyReputation,
      'newsItems': instance.newsItems.map((e) => e.toJson()).toList(),
      'difficulty': _$DifficultyEnumMap[instance.difficulty]!,
      'themeMode': SerializableGameState._themeModeToJson(instance.themeMode),
      'rivalAcademies': instance.rivalAcademies.map((e) => e.toJson()).toList(),
      'aiClubs': instance.aiClubs.map((e) => e.toJson()).toList(),
      'playerAcademyTier': instance.playerAcademyTier,
    };

const _$DifficultyEnumMap = {
  Difficulty.Easy: 'Easy',
  Difficulty.Normal: 'Normal',
  Difficulty.Hard: 'Hard',
  Difficulty.Hardcore: 'Hardcore',
};
