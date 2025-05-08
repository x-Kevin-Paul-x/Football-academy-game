// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'formation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Formation _$FormationFromJson(Map<String, dynamic> json) => Formation(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$FormationTypeEnumMap, json['type']),
      tournamentType:
          $enumDecode(_$TournamentTypeEnumMap, json['tournamentType']),
      positions: (json['positions'] as List<dynamic>)
          .map((e) => $enumDecode(_$PlayerPositionEnumMap, e))
          .toList(),
    );

Map<String, dynamic> _$FormationToJson(Formation instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$FormationTypeEnumMap[instance.type]!,
      'tournamentType': _$TournamentTypeEnumMap[instance.tournamentType]!,
      'positions':
          instance.positions.map((e) => _$PlayerPositionEnumMap[e]!).toList(),
    };

const _$FormationTypeEnumMap = {
  FormationType.F442: 'F442',
  FormationType.F433: 'F433',
  FormationType.F352: 'F352',
  FormationType.F532: 'F532',
  FormationType.F4231: 'F4231',
  FormationType.F4141: 'F4141',
  FormationType.F231: 'F231',
  FormationType.F321: 'F321',
  FormationType.F132: 'F132',
  FormationType.F121: 'F121',
  FormationType.F211: 'F211',
  FormationType.F112: 'F112',
  FormationType.F111: 'F111',
  FormationType.F21: 'F21',
  FormationType.F12: 'F12',
};

const _$TournamentTypeEnumMap = {
  TournamentType.threeVthree: 'threeVthree',
  TournamentType.fiveVfive: 'fiveVfive',
  TournamentType.sevenVseven: 'sevenVseven',
  TournamentType.elevenVeleven: 'elevenVeleven',
};

const _$PlayerPositionEnumMap = {
  PlayerPosition.Goalkeeper: 'Goalkeeper',
  PlayerPosition.Defender: 'Defender',
  PlayerPosition.Midfielder: 'Midfielder',
  PlayerPosition.Forward: 'Forward',
};
