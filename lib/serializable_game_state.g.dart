// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializable_game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SerializableGameState _$SerializableGameStateFromJson(
        Map<String, dynamic> json) =>
    SerializableGameState(
      currentDate: DateTime.parse(json['currentDate'] as String),
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
      academyReputation: (json['academyReputation'] as num).toInt(),
      newsItems: (json['newsItems'] as List<dynamic>)
          .map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      difficulty: $enumDecode(_$DifficultyEnumMap, json['difficulty']),
      themeMode: _themeModeFromJson(json['themeMode'] as String),
    );

Map<String, dynamic> _$SerializableGameStateToJson(
        SerializableGameState instance) =>
    <String, dynamic>{
      'currentDate': instance.currentDate.toIso8601String(),
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
      'academyReputation': instance.academyReputation,
      'newsItems': instance.newsItems.map((e) => e.toJson()).toList(),
      'difficulty': _$DifficultyEnumMap[instance.difficulty]!,
      'themeMode': _themeModeToJson(instance.themeMode),
    };

const _$DifficultyEnumMap = {
  Difficulty.Easy: 'Easy',
  Difficulty.Normal: 'Normal',
  Difficulty.Hard: 'Hard',
};
