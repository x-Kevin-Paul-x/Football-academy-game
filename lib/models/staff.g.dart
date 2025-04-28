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
      maxPlayersTrainable: (json['maxPlayersTrainable'] as num).toInt(),
      assignedPlayerIds: (json['assignedPlayerIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$StaffToJson(Staff instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'role': _$StaffRoleEnumMap[instance.role]!,
      'skill': instance.skill,
      'weeklyWage': instance.weeklyWage,
      'maxPlayersTrainable': instance.maxPlayersTrainable,
      'assignedPlayerIds': instance.assignedPlayerIds,
    };

const _$StaffRoleEnumMap = {
  StaffRole.Coach: 'Coach',
  StaffRole.Scout: 'Scout',
  StaffRole.Physio: 'Physio',
  StaffRole.Manager: 'Manager',
};
