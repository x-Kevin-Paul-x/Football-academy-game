import 'package:json_annotation/json_annotation.dart';
import 'dart:math';
import 'package:uuid/uuid.dart';

part 'staff.g.dart';

enum StaffRole {
  Manager,
  Coach,
  Scout,
  Physio,
}

@JsonSerializable(explicitToJson: true)
class Staff {
  final String id;
  final String name;
  final StaffRole role;
  int skill; // 1-100
  int weeklyWage;
  int loyalty; // 1-100, affects likelihood of leaving/demanding raises
  int potential; // 1-100, max skill they can reach naturally
  // final TacticalStyle preferredTacticalStyle; // Removed
  int age;

  // Coach specific
  List<String> assignedPlayerIds; // IDs of players assigned to this coach
  int maxPlayersTrainable; // How many players this coach can handle

  Staff({
    required this.id,
    required this.name,
    required this.role,
    required this.skill,
    required this.weeklyWage,
    required this.loyalty,
    required this.potential,
    // required this.preferredTacticalStyle, // Removed
    required this.age,
    List<String>? assignedPlayerIds,
    int? maxPlayersTrainable,
  }) : assignedPlayerIds = assignedPlayerIds ?? [],
       maxPlayersTrainable = maxPlayersTrainable ?? 5; // Default max trainable

  // Factory for generating random staff
  factory Staff.randomStaff(String id, StaffRole role) {
    final random = Random();
    int potential = 30 + random.nextInt(61); // 30-90 potential
    int skill = (potential * (0.4 + random.nextDouble() * 0.5)).clamp(10, 95).toInt(); // 40-90% of potential, min 10
    int age = 25 + random.nextInt(36); // 25-60 age
    int wage = 100 + (skill * 5) + (potential * 2) + random.nextInt(100); // Wage based on skill/potential
    int loyalty = 40 + random.nextInt(51); // 40-90 loyalty
    int maxTrainable = 3 + (skill ~/ 20); // Coach specific: 3 base + 1 per 20 skill

    return Staff(
      id: id,
      name: _generateRandomName(random),
      role: role,
      skill: skill,
      weeklyWage: wage,
      loyalty: loyalty,
      potential: potential,
      // preferredTacticalStyle: TacticalStyle.values[random.nextInt(TacticalStyle.values.length)], // Removed
      age: age,
      maxPlayersTrainable: (role == StaffRole.Coach) ? maxTrainable : 0,
    );
  }

  static String _generateRandomName(Random random) {
    const List<String> firstNames = ['Alex', 'Ben', 'Chris', 'David', 'Ethan', 'Frank', 'George', 'Harry', 'Ian', 'Jack', 'Kevin', 'Liam', 'Mike', 'Noah', 'Owen', 'Paul', 'Quinn', 'Ryan', 'Sam', 'Tom', 'Vince', 'Will'];
    const List<String> lastNames = ['Smith', 'Jones', 'Taylor', 'Brown', 'Williams', 'Wilson', 'Evans', 'Thomas', 'Roberts', 'Johnson', 'Lewis', 'Walker', 'Robinson', 'Wood', 'Thompson', 'White', 'Watson', 'Jackson', 'Wright'];
    return '${firstNames[random.nextInt(firstNames.length)]} ${lastNames[random.nextInt(lastNames.length)]}';
  }


  factory Staff.fromJson(Map<String, dynamic> json) => _$StaffFromJson(json);
  Map<String, dynamic> toJson() => _$StaffToJson(this);
}
