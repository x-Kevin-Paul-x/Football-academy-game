// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_club.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIClub _$AIClubFromJson(Map<String, dynamic> json) => AIClub(
      id: json['id'] as String,
      name: json['name'] as String,
      primaryColor: _colorFromJson((json['primaryColor'] as num).toInt()),
      secondaryColor: _colorFromJson((json['secondaryColor'] as num).toInt()),
      skillLevel: (json['skillLevel'] as num).toInt(),
      players: (json['players'] as List<dynamic>)
          .map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AIClubToJson(AIClub instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'primaryColor': _colorToJson(instance.primaryColor),
      'secondaryColor': _colorToJson(instance.secondaryColor),
      'skillLevel': instance.skillLevel,
      'players': instance.players.map((e) => e.toJson()).toList(),
    };
