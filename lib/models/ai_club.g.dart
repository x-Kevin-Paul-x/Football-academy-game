// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_club.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIClub _$AIClubFromJson(Map<String, dynamic> json) => AIClub(
      id: json['id'] as String,
      name: json['name'] as String,
      reputation: (json['reputation'] as num).toInt(),
      balance: (json['balance'] as num).toDouble(),
      players: (json['players'] as List<dynamic>)
          .map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList(),
      skillLevel: (json['skillLevel'] as num).toInt(),
      tier: (json['tier'] as num).toInt(),
      fanCount: (json['fanCount'] as num).toInt(),
      ticketPrice: (json['ticketPrice'] as num).toDouble(),
    );

Map<String, dynamic> _$AIClubToJson(AIClub instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'reputation': instance.reputation,
      'balance': instance.balance,
      'players': instance.players.map((e) => e.toJson()).toList(),
      'skillLevel': instance.skillLevel,
      'tier': instance.tier,
      'fanCount': instance.fanCount,
      'ticketPrice': instance.ticketPrice,
    };
