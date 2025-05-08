// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsItem _$NewsItemFromJson(Map<String, dynamic> json) => NewsItem(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecodeNullable(_$NewsItemTypeEnumMap, json['type']) ??
          NewsItemType.Generic,
      isRead: json['isRead'] as bool? ?? false,
    );

Map<String, dynamic> _$NewsItemToJson(NewsItem instance) => <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'title': instance.title,
      'description': instance.description,
      'type': _$NewsItemTypeEnumMap[instance.type]!,
      'isRead': instance.isRead,
    };

const _$NewsItemTypeEnumMap = {
  NewsItemType.MatchResult: 'MatchResult',
  NewsItemType.Scouting: 'Scouting',
  NewsItemType.Training: 'Training',
  NewsItemType.TransferOffer: 'TransferOffer',
  NewsItemType.TransferDecision: 'TransferDecision',
  NewsItemType.StaffChange: 'StaffChange',
  NewsItemType.Finance: 'Finance',
  NewsItemType.Facility: 'Facility',
  NewsItemType.PlayerSigned: 'PlayerSigned',
  NewsItemType.Tournament: 'Tournament',
  NewsItemType.LeagueUpdate: 'LeagueUpdate',
  NewsItemType.Generic: 'Generic',
};
