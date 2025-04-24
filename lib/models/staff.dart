import 'dart:math';

enum StaffRole { Coach, Scout, Physio, Manager }

class Staff {
  final String id;
  String name;
  StaffRole role;
  int skill; // General skill/effectiveness rating (e.g., scouting radius, coaching bonus)
  int weeklyWage;

  Staff({
    required this.id,
    required this.name,
    required this.role,
    required this.skill,
    required this.weeklyWage,
  });

  // Factory constructor for generating random staff members
  factory Staff.randomStaff(String id, StaffRole role) {
    final random = Random();
    List<String> firstNames = ['Liam', 'Olivia', 'Noah', 'Emma', 'Oliver', 'Ava', 'Elijah', 'Charlotte', 'William', 'Sophia'];
    List<String> lastNames = ['Johnson', 'Martinez', 'Garcia', 'Rodriguez', 'Hernandez', 'Lopez', 'Gonzalez', 'Perez', 'Sanchez', 'Ramirez'];

    String name = '${firstNames[random.nextInt(firstNames.length)]} ${lastNames[random.nextInt(lastNames.length)]}';
    int skill = 40 + random.nextInt(51); // Skill between 40-90
    int weeklyWage = 150 + random.nextInt(351); // Wage between 150-500

    return Staff(
      id: id,
      name: name,
      role: role,
      skill: skill,
      weeklyWage: weeklyWage,
    );
  }

  String get roleString {
     switch (role) {
      case StaffRole.Coach:
        return 'Coach';
      case StaffRole.Scout:
        return 'Scout';
      case StaffRole.Physio:
        return 'Physio';
      case StaffRole.Manager:
        return 'Manager';
    }
  }
}
