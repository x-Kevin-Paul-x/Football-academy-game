// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rival_academy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RivalAcademy _$RivalAcademyFromJson(Map<String, dynamic> json) => RivalAcademy(
      id: json['id'] as String,
      name: json['name'] as String,
      skillLevel: (json['skillLevel'] as num).toInt(),
      reputation: (json['reputation'] as num).toInt(),
      balance: (json['balance'] as num).toDouble(),
      players: (json['players'] as List<dynamic>)
          .map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList(),
      trainingFacilityLevel:
          (json['trainingFacilityLevel'] as num?)?.toInt() ?? 1,
      scoutingFacilityLevel:
          (json['scoutingFacilityLevel'] as num?)?.toInt() ?? 1,
      medicalBayLevel: (json['medicalBayLevel'] as num?)?.toInt() ?? 1,
      activeTournamentIds: (json['activeTournamentIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      tier: (json['tier'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$RivalAcademyToJson(RivalAcademy instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'skillLevel': instance.skillLevel,
      'reputation': instance.reputation,
      'balance': instance.balance,
      'players': instance.players.map((e) => e.toJson()).toList(),
      'trainingFacilityLevel': instance.trainingFacilityLevel,
      'scoutingFacilityLevel': instance.scoutingFacilityLevel,
      'medicalBayLevel': instance.medicalBayLevel,
      'activeTournamentIds': instance.activeTournamentIds,
      'tier': instance.tier,
    };
