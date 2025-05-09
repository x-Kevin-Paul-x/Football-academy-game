// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Staff _$StaffFromJson(Map<String, dynamic> json) => Staff(
      id: json['id'] as String,
      name: json['name'] as String,
      role: $enumDecode(_$StaffRoleEnumMap, json['role']),
      skill: (json['skill'] as num).toInt(),
      weeklyWage: (json['weeklyWage'] as num).toInt(),
      loyalty: (json['loyalty'] as num).toInt(),
      potential: (json['potential'] as num).toInt(),
      age: (json['age'] as num).toInt(),
      assignedPlayerIds: (json['assignedPlayerIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      maxPlayersTrainable: (json['maxPlayersTrainable'] as num?)?.toInt(),
      knownFormations: (json['knownFormations'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$FormationTypeEnumMap, e))
          .toList(),
      preferredFormation: json['preferredFormation'] == null
          ? null
          : Formation.fromJson(
              json['preferredFormation'] as Map<String, dynamic>),
      isAssigned: json['isAssigned'] as bool? ?? true,
    );

Map<String, dynamic> _$StaffToJson(Staff instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'role': _$StaffRoleEnumMap[instance.role]!,
      'skill': instance.skill,
      'weeklyWage': instance.weeklyWage,
      'loyalty': instance.loyalty,
      'potential': instance.potential,
      'age': instance.age,
      'isAssigned': instance.isAssigned,
      'assignedPlayerIds': instance.assignedPlayerIds,
      'maxPlayersTrainable': instance.maxPlayersTrainable,
      'knownFormations': instance.knownFormations
          .map((e) => _$FormationTypeEnumMap[e]!)
          .toList(),
      'preferredFormation': instance.preferredFormation?.toJson(),
    };

const _$StaffRoleEnumMap = {
  StaffRole.Manager: 'Manager',
  StaffRole.Coach: 'Coach',
  StaffRole.Scout: 'Scout',
  StaffRole.Physio: 'Physio',
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
