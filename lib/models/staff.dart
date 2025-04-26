import 'dart:math';

enum StaffRole { Coach, Scout, Physio, Manager }

class Staff {
  final String id;
  String name;
  StaffRole role;
  int skill; // General skill/effectiveness rating (e.g., scouting radius, coaching bonus)
  int weeklyWage;

  // Coach specific properties (only relevant if role is Coach)
  int maxPlayersTrainable;
  List<String> assignedPlayerIds;

  Staff({
    required this.id,
    required this.name,
    required this.role,
    required this.skill,
    required this.weeklyWage,
    // Initialize coach properties - make them required for now
    required this.maxPlayersTrainable,
    required this.assignedPlayerIds,
  });

  // Factory constructor for generating random staff members
  factory Staff.randomStaff(String id, StaffRole role) {
    final random = Random();
    List<String> firstNames = ['Liam', 'Olivia', 'Noah', 'Emma', 'Oliver', 'Ava', 'Elijah', 'Charlotte', 'William', 'Sophia'];
    List<String> lastNames = ['Johnson', 'Martinez', 'Garcia', 'Rodriguez', 'Hernandez', 'Lopez', 'Gonzalez', 'Perez', 'Sanchez', 'Ramirez'];

    String name = '${firstNames[random.nextInt(firstNames.length)]} ${lastNames[random.nextInt(lastNames.length)]}';
    int skill = 40 + random.nextInt(51); // Skill between 40-90
    int weeklyWage = 150 + random.nextInt(351); // Wage between 150-500

    // --- Coach Specific Initialization ---
    // Base capacity + bonus based on skill (e.g., 1 extra player per 15 skill points over 50)
    int maxPlayersTrainable = 3 + max(0, ((skill - 50) / 15).floor());
    List<String> assignedPlayerIds = []; // Start with no assigned players

    // Only apply coach properties if the role is actually Coach
    if (role != StaffRole.Coach) {
      maxPlayersTrainable = 0; // Non-coaches can't train
    }
    // --- End Coach Specific Initialization ---

    return Staff(
      id: id,
      name: name,
      role: role,
      skill: skill,
      weeklyWage: weeklyWage,
      maxPlayersTrainable: maxPlayersTrainable, // Pass value
      assignedPlayerIds: assignedPlayerIds,   // Pass empty list
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
