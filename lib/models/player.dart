import 'dart:math';

enum PlayerPosition { Goalkeeper, Defender, Midfielder, Forward }

class Player {
  final String id;
  String name;
  int age;
  PlayerPosition position;
  int currentSkill; // Made non-final
  final int potentialSkill; // Keep final
  int weeklyWage;
  bool isScouted; // Flag to differentiate between academy players and scouted prospects

  // --- In-Match Stats (can be reset per match) ---
  int matchGoals = 0;
  int matchAssists = 0;
  // Add more stats: shots, tackles, saves (if GK), etc.
  // ---

  Player({
    required this.id,
    required this.name,
    required this.age,
    required this.position,
    required this.currentSkill,
    required this.potentialSkill,
    required this.weeklyWage,
    this.isScouted = false,
  });

  // Factory constructor for generating random scouted players
  factory Player.randomScoutedPlayer(String id) {
    final random = Random();
    List<String> firstNames = ['Alex', 'Ben', 'Chris', 'David', 'Ethan', 'Finn', 'George', 'Harry', 'Ian', 'Jack'];
    List<String> lastNames = ['Smith', 'Jones', 'Williams', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor', 'Anderson'];
    
    String name = '${firstNames[random.nextInt(firstNames.length)]} ${lastNames[random.nextInt(lastNames.length)]}';
    int age = 15 + random.nextInt(4); // Young players: 15-18
    PlayerPosition position = PlayerPosition.values[random.nextInt(PlayerPosition.values.length)];
    int potentialSkill = 50 + random.nextInt(41); // Potential between 50-90
    int currentSkill = 20 + random.nextInt(potentialSkill - 20 + 1); // Current skill lower than potential
    int weeklyWage = 50 + random.nextInt(151); // Wage between 50-200 for prospects

    return Player(
      id: id,
      name: name,
      age: age,
      position: position,
      currentSkill: currentSkill,
      potentialSkill: potentialSkill,
      weeklyWage: weeklyWage,
      isScouted: true, // Mark as scouted initially
    );
  }

  String get positionString {
    switch (position) {
      case PlayerPosition.Goalkeeper:
        return 'GK';
      case PlayerPosition.Defender:
        return 'DEF';
      case PlayerPosition.Midfielder:
        return 'MID';
      case PlayerPosition.Forward:
        return 'FWD';
    }
  }
}
