import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'models/tournament.dart';
import 'models/match.dart';
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'models/tournament.dart';
import 'models/match.dart';
import 'models/player.dart'; // Import Player model
import 'models/staff.dart'; // Import Staff model
import 'models/ai_club.dart'; // Import AIClub model
import 'models/match_event.dart'; // Import MatchEventType
import 'dart:math'; // For random simulation

class GameStateManager with ChangeNotifier {
  // Core Game Time & State
  DateTime _currentDate = DateTime(2025, 7, 1); // Starting date of the game
  final Random _random = Random(); // Random number generator

  // Player & Staff State
  List<Player> _academyPlayers = [];
  List<Staff> _hiredStaff = [];
  List<Player> _scoutedPlayers = []; // Players found by scouts this week
  List<Staff> _availableStaff = [];

  // Financial State
  double _balance = 50000.0; // Starting balance
  int _weeklyIncome = 1000; // Base weekly income (can be modified by factors later)
  int _totalWeeklyWages = 0;

  // Tournament State
  List<Tournament> _activeTournaments = []; // Tournaments currently in progress
  final List<Tournament> _completedTournaments = []; // Tournaments that have finished

  // AI Club Data (Centralized)
  final List<AIClub> _allAICLubs = List.generate(16, (index) => AIClub.placeholder(index)); // Generate more AI clubs
  final Map<String, AIClub> _aiClubMap = {}; // Cache AI clubs by ID

  // Facility State (Basic)
  int _trainingFacilityLevel = 1; // Example: Level 1
  int _scoutingFacilityLevel = 1; // Example: Level 1

  // --- Reputation ---
  int _academyReputation = 100; // Starting academy reputation

  // --- Transfer Offers ---
  // Placeholder for transfer offers - needs a dedicated model later
  List<Map<String, dynamic>> _transferOffers = [];

  // --- Getters ---
  DateTime get currentDate => _currentDate;
  List<Player> get academyPlayers => _academyPlayers;
  List<Staff> get hiredStaff => _hiredStaff;
  List<Player> get scoutedPlayers => _scoutedPlayers;
  List<Staff> get availableStaff => _availableStaff;
  double get balance => _balance;
  int get weeklyIncome => _weeklyIncome;
  int get totalWeeklyWages => _totalWeeklyWages;
  List<Tournament> get activeTournaments => _activeTournaments;
  List<Tournament> get completedTournaments => _completedTournaments; // Getter for completed
  Map<String, AIClub> get aiClubMap => _aiClubMap; // Getter for AI Club Map
  int get trainingFacilityLevel => _trainingFacilityLevel; // Getter for facility level
  int get scoutingFacilityLevel => _scoutingFacilityLevel; // Getter for scouting facility level
  int get academyReputation => _academyReputation; // Getter for academy reputation
  List<Map<String, dynamic>> get transferOffers => _transferOffers; // Getter for transfer offers

  GameStateManager() {
    // Initialize game state on creation
    _generateInitialAvailableStaff();
    _populateAIClubMap(); // Populate AI club map
    _calculateWeeklyWages(); // Initial calculation (should be 0)
  }

  // --- Initialization ---
   void _generateInitialAvailableStaff() {
    // Using _random directly as it's now a member variable
    _availableStaff = List.generate(5, (index) {
      StaffRole role = StaffRole.values[_random.nextInt(StaffRole.values.length)];
      if (index < 2 && role != StaffRole.Scout) { // Ensure some scouts
        role = StaffRole.Scout;
      }
      return Staff.randomStaff('staff_${DateTime.now().millisecondsSinceEpoch}_$index', role);
    });
    // No need to notifyListeners here as it's part of initialization
  }

  void _populateAIClubMap() {
    for (var club in _allAICLubs) {
      _aiClubMap[club.id] = club;
    }
    print("Populated AI Club Map with ${_aiClubMap.length} clubs.");
  }

  // --- Weekly Update Logic ---

  // Method to advance the game by one week
  // No longer needs hiredStaff passed in, uses internal state
  void advanceWeek() {
    _currentDate = _currentDate.add(const Duration(days: 7));
    print("Advancing week to: $_currentDate"); // Simple log

    // 1. Update Finances
    _balance += _weeklyIncome;
    _balance -= _totalWeeklyWages; // Wages calculated at end of previous week/when staff/players change

    // 2. Scouting Logic
    _scoutedPlayers.clear(); // Clear previous week's reports
    int totalScoutingSkill = _hiredStaff // Use internal _hiredStaff
        .where((s) => s.role == StaffRole.Scout)
        .fold(0, (sum, scout) => sum + scout.skill);

    // Generate players based on total scouting skill (simple example)
    int playersToFind = (totalScoutingSkill / 50).ceil() + _random.nextInt(2); // More skill = more players
    if (_hiredStaff.where((s) => s.role == StaffRole.Scout).isEmpty) { // Use internal _hiredStaff
      playersToFind = 0; // No scouts, no players found
    }
    print("Scouting found $playersToFind players this week.");

    for (int i = 0; i < playersToFind; i++) {
      _scoutedPlayers.add(Player.randomScoutedPlayer('scouted_${_currentDate.millisecondsSinceEpoch}_$i'));
    }
    // --- End Scouting Logic ---

    // 3. Simulate Tournament Matches for the past week
    _simulateMatchesForWeek();

    // 4. Handle Player Training
    _handlePlayerTraining(); // Call the new training logic

    // 5. Reputation Decay & Transfer Offers
    _updateReputationDecay();
    _generateTransferOffers(); // Generate new offers weekly

    // 6. Staff Market Refresh
    _refreshAvailableStaff();

    // 7. TODO: Other weekly events (facility effects, news, etc.)

    // 8. Notify Listeners
    notifyListeners(); // Notify listeners about changes (date, scouted players, balance, staff, etc.)
  }

  // --- State Modification Methods ---

  void _calculateWeeklyWages() {
    int staffWages = _hiredStaff.fold(0, (sum, staff) => sum + staff.weeklyWage);
    int playerWages = _academyPlayers.fold(0, (sum, player) => sum + player.weeklyWage);
    _totalWeeklyWages = staffWages + playerWages;
    // No need to notify here, as this is usually called before another state change
    // that *will* notify (like hiring/signing). If called independently, add notifyListeners().
    print("Calculated weekly wages: $_totalWeeklyWages");
  }

  void hireStaff(Staff staffToHire) {
    _hiredStaff.add(staffToHire);
    _availableStaff.removeWhere((s) => s.id == staffToHire.id);
    // _balance -= staffToHire.weeklyWage * 4; // Optional: Signing bonus? Let's skip for now.
    _calculateWeeklyWages(); // Recalculate wages
    notifyListeners(); // Notify about changes to staff and potentially wages/balance indirectly
    print("Hired ${staffToHire.name}");
  }

  void signPlayer(Player playerToSign) {
    playerToSign.isScouted = false; // Mark as signed
    _academyPlayers.add(playerToSign);
    _scoutedPlayers.removeWhere((p) => p.id == playerToSign.id); // Remove from scouted list
    _calculateWeeklyWages(); // Recalculate wages
    notifyListeners(); // Notify about changes to players, scouted list, wages
    print("Signed ${playerToSign.name}");
  }

  void rejectPlayer(Player playerToReject) {
    _scoutedPlayers.removeWhere((p) => p.id == playerToReject.id);
    notifyListeners(); // Notify about change to scouted list
    print("Rejected ${playerToReject.name}");
  }

  // Method to add a tournament when the player enters it
  void addActiveTournament(Tournament tournament) {
    if (!_activeTournaments.any((t) => t.id == tournament.id)) {
      _activeTournaments.add(tournament);
      print("Tournament ${tournament.name} added to active tournaments.");
      // No need to notifyListeners here unless something needs to react immediately
      // to the list of active tournaments changing.
    }
  }

  // Internal method to simulate matches scheduled within the week that just passed
  void _simulateMatchesForWeek() {
    DateTime startOfWeek = _currentDate.subtract(const Duration(days: 7));
    DateTime endOfWeek = _currentDate; // Simulate up to (but not including) the new current date

    print("Simulating matches between $startOfWeek and $endOfWeek");

    List<Tournament> completedTournaments = [];

    for (var tournament in _activeTournaments) {
      if (tournament.status == TournamentStatus.InProgress) {
        bool tournamentMatchesRemaining = false;
        for (var match in tournament.matches) {
          // Check if the match falls within the week that just passed AND hasn't been simulated yet
          // Use >= startOfWeek and < endOfWeek for standard weekly range check
          if (!match.isSimulated &&
              !match.matchDate.isBefore(startOfWeek) &&
              match.matchDate.isBefore(endOfWeek)) {

            print("Preparing detailed simulation for match: ${match.id} scheduled for ${match.matchDate}");

            // --- Select Teams ---
            // Need tournament type to select correct number of players
            TournamentType tournamentType = tournament.type; // Get type from the tournament object
            List<Player> homeLineup;
            List<Player> awayLineup;

            const String playerAcademyId = 'player_academy_1'; // Consistent ID

            // Select Home Team
            if (match.homeTeamId == playerAcademyId) {
              homeLineup = selectPlayerTeamForMatch(tournamentType);
            } else {
              AIClub? homeAIClub = _aiClubMap[match.homeTeamId];
              if (homeAIClub != null) {
                homeLineup = selectAITeamForMatch(tournamentType, homeAIClub);
              } else {
                print("Error: Home AI Club ${match.homeTeamId} not found for match ${match.id}. Using empty lineup.");
                homeLineup = []; // Fallback
              }
            }

            // Select Away Team
            if (match.awayTeamId == playerAcademyId) {
              awayLineup = selectPlayerTeamForMatch(tournamentType);
            } else {
              AIClub? awayAIClub = _aiClubMap[match.awayTeamId];
              if (awayAIClub != null) {
                awayLineup = selectAITeamForMatch(tournamentType, awayAIClub);
              } else {
                print("Error: Away AI Club ${match.awayTeamId} not found for match ${match.id}. Using empty lineup.");
                awayLineup = []; // Fallback
              }
            }
            // --- End Select Teams ---

            // Call the detailed simulation method
            match.simulateDetailed(homeLineup, awayLineup);
            // Update reputation immediately after simulation
            _updateReputationAfterMatch(tournament, match);
          }
          // Check if there are any matches left to simulate in the future for this tournament
          if (!match.isSimulated) {
            tournamentMatchesRemaining = true;
          }
        }

        // If no matches remain to be simulated, mark the tournament as completed
        if (!tournamentMatchesRemaining) {
          print("Tournament ${tournament.name} completed.");
          tournament.status = TournamentStatus.Completed;
          completedTournaments.add(tournament);
          // TODO: Award prizes based on final standings
          // Reputation is updated after each match now, not just at the end.
        }
      }
    }

    // Move completed tournaments from the active list to the completed list
    if (completedTournaments.isNotEmpty) {
      _completedTournaments.addAll(completedTournaments); // Add to history
      _activeTournaments.removeWhere((t) => completedTournaments.contains(t)); // Remove from active
      print("Moved ${completedTournaments.length} tournaments to history.");
      // Consider notifying listeners if the UI needs to react to history changes immediately
      // notifyListeners();
    }
  }

  // --- Player Training Logic ---
  void _handlePlayerTraining() {
    print("--- Handling Player Training ---");
    bool anyPlayerImproved = false;

    // Create a map for quick player lookup by ID
    Map<String, Player> playerMap = { for (var p in _academyPlayers) p.id : p };

    // Iterate through hired coaches
    final coaches = _hiredStaff.where((s) => s.role == StaffRole.Coach).toList();

    if (coaches.isEmpty) {
      print("No coaches hired. No specific player training applied this week.");
      // Optional: Apply a very basic, low-chance training for unassigned players?
      // For now, let's stick to coach-led training only.
      return;
    }

    Set<String> trainedPlayerIds = {}; // Keep track of players already trained this week

    for (var coach in coaches) {
      print("Coach ${coach.name} (Skill: ${coach.skill}, Capacity: ${coach.assignedPlayerIds.length}/${coach.maxPlayersTrainable}) is training...");

      // Iterate through players assigned to this coach
      for (var playerId in coach.assignedPlayerIds) {
        // Check if player exists and hasn't been trained by another coach this week
        if (playerMap.containsKey(playerId) && !trainedPlayerIds.contains(playerId)) {
          Player player = playerMap[playerId]!;
          trainedPlayerIds.add(playerId); // Mark as trained for this week

          if (player.currentSkill < player.potentialSkill) {
            // Calculate training chance based on coach skill and facility level
            // Example: Base 5% + Coach Skill / 5 + Facility Level * 3
            int baseChance = 5;
            int coachBonus = (coach.skill / 5).floor(); // Higher skill = higher bonus
            int facilityBonus = (_trainingFacilityLevel * 3); // Facility bonus
            int totalChance = baseChance + coachBonus + facilityBonus;
            // Clamp the chance (e.g., 5% to 95%)
            totalChance = totalChance.clamp(5, 95);

            if (_random.nextInt(100) < totalChance) {
              player.currentSkill++; // Increase skill by 1
              print("  -> Player ${player.name} (under ${coach.name}) improved skill to ${player.currentSkill}. Chance: $totalChance%");
              anyPlayerImproved = true;
            } else {
              // print("  -> Player ${player.name} (under ${coach.name}) did not improve this week. Chance: $totalChance%");
            }
          } else {
             // print("  -> Player ${player.name} (under ${coach.name}) is already at potential skill.");
          }
        } else if (!playerMap.containsKey(playerId)) {
           print("  -> Warning: Player ID $playerId assigned to coach ${coach.name} not found in academy players.");
           // Consider removing invalid ID from coach.assignedPlayerIds here?
        }
      }
    }

    // Check for players NOT assigned to any coach
    int unassignedCount = 0;
    for (var player in _academyPlayers) {
      if (!trainedPlayerIds.contains(player.id)) {
        unassignedCount++;
        // print("Player ${player.name} is not assigned to any coach and did not receive specific training.");
        // Optional: Apply a minimal base training chance here if desired.
      }
    }
     if (unassignedCount > 0) {
        print("$unassignedCount players were not assigned to any coach this week.");
     }

    if (!anyPlayerImproved && coaches.isNotEmpty) {
      print("No players improved under coaching this week.");
    }
  }
  // --- End Player Training Logic ---

  // --- Staff Market Logic ---
  void _refreshAvailableStaff() {
    // 1. Chance to remove existing available staff
    // Example: 20% chance per staff member to leave the market each week
    int removedCount = 0;
    _availableStaff.removeWhere((staff) {
      bool leaving = _random.nextDouble() < 0.20; // 20% chance
      if (leaving) {
        removedCount++;
        print("Staff Market: ${staff.name} (${staff.roleString}) left the market.");
      }
      return leaving;
    });

    // 2. Generate a few new staff members
    // Example: Generate 1-3 new staff members each week
    int newStaffCount = 1 + _random.nextInt(3); // 1, 2, or 3 new staff
    int addedCount = 0;
    for (int i = 0; i < newStaffCount; i++) {
      // Ensure a mix of roles, maybe slightly bias towards coaches/scouts?
      StaffRole role = StaffRole.values[_random.nextInt(StaffRole.values.length)];
      // Simple bias: 50% chance to reroll if it's Physio/Manager
      if ((role == StaffRole.Physio || role == StaffRole.Manager) && _random.nextBool()) {
         role = StaffRole.values[_random.nextInt(StaffRole.values.length)];
      }

      // Avoid adding too many staff if the pool is already large (optional)
      if (_availableStaff.length < 15) { // Example cap
         Staff newStaff = Staff.randomStaff('staff_${_currentDate.millisecondsSinceEpoch}_$i', role);
         _availableStaff.add(newStaff);
         addedCount++;
         print("Staff Market: New ${newStaff.roleString} ${newStaff.name} (Skill: ${newStaff.skill}) added.");
      }
    }
    print("Staff Market Refreshed: $removedCount removed, $addedCount added. Total available: ${_availableStaff.length}");
    // No notifyListeners needed here, advanceWeek handles it at the end.
  }
  // --- End Staff Market Logic ---

  // --- Player-Coach Assignment Logic ---

  // Assigns a player to a specific coach
  bool assignPlayerToCoach(String playerId, String coachId) {
    // Find the coach
    Staff? coach;
    try {
      coach = _hiredStaff.firstWhere((s) => s.id == coachId && s.role == StaffRole.Coach);
    } catch (e) {
      print("Error: Coach with ID $coachId not found or is not a coach.");
      return false;
    }

    // Find the player
    Player? player;
    try {
      player = _academyPlayers.firstWhere((p) => p.id == playerId);
    } catch (e) {
      print("Error: Player with ID $playerId not found in academy.");
      return false;
    }

    // Check if coach is already full
    if (coach.assignedPlayerIds.length >= coach.maxPlayersTrainable) {
      print("Error: Coach ${coach.name} is already at maximum capacity (${coach.maxPlayersTrainable}). Cannot assign ${player.name}.");
      return false;
    }

    // Check if player is already assigned to this coach
    if (coach.assignedPlayerIds.contains(playerId)) {
      print("Info: Player ${player.name} is already assigned to coach ${coach.name}.");
      return true; // No change needed, but not an error
    }

    // Check if player is assigned to ANOTHER coach and unassign first
    unassignPlayerFromAnyCoach(playerId); // Ensure player is free

    // Assign player to the new coach
    coach.assignedPlayerIds.add(playerId);
    print("Assigned player ${player.name} to coach ${coach.name}.");
    notifyListeners(); // Notify UI about staff changes (assigned counts)
    return true;
  }

  // Unassigns a player from a specific coach
  bool unassignPlayerFromCoach(String playerId, String coachId) {
     // Find the coach
    Staff? coach;
    try {
      coach = _hiredStaff.firstWhere((s) => s.id == coachId && s.role == StaffRole.Coach);
    } catch (e) {
      print("Error: Coach with ID $coachId not found or is not a coach.");
      return false;
    }

     // Find the player (optional, but good for logging the name)
    Player? player;
    try {
      player = _academyPlayers.firstWhere((p) => p.id == playerId);
    } catch (e) {
      // Player not found, but we can still try to remove the ID if it exists in the coach's list
      print("Info: Player with ID $playerId not found in academy, attempting removal from coach ${coach.name} anyway.");
    }
    String playerName = player?.name ?? 'ID: $playerId'; // Use ID if player object wasn't found

    bool removed = coach.assignedPlayerIds.remove(playerId);
    if (removed) {
      print("Unassigned player $playerName from coach ${coach.name}.");
      notifyListeners(); // Notify UI about staff changes (assigned counts)
    } else {
       print("Info: Player $playerName was not assigned to coach ${coach.name}.");
    }
    return removed;
  }

  // Unassigns a player from whichever coach they are currently assigned to
  void unassignPlayerFromAnyCoach(String playerId) {
    for (var coach in _hiredStaff.where((s) => s.role == StaffRole.Coach)) {
      if (coach.assignedPlayerIds.contains(playerId)) {
        unassignPlayerFromCoach(playerId, coach.id);
        break; // Player can only be assigned to one coach at a time
      }
    }
  }

  // Helper to get the coach assigned to a player, if any
  Staff? getCoachForPlayer(String playerId) {
     for (var coach in _hiredStaff.where((s) => s.role == StaffRole.Coach)) {
      if (coach.assignedPlayerIds.contains(playerId)) {
        return coach;
      }
    }
    return null; // Not assigned to any coach
  }

  // --- End Player-Coach Assignment Logic ---

  // Calculates the skill level for a given team ID
  int _getTeamSkill(String teamId) {
    const String playerAcademyId = 'player_academy_1'; // Define player academy ID consistently

    if (teamId == playerAcademyId) {
      // Calculate actual academy skill based on average of current players
      if (_academyPlayers.isEmpty) {
        return 10; // Default low skill if no players
      }
      // Simple average for now. Could be weighted or based on best N players later.
      double totalSkill = _academyPlayers.fold(0, (sum, player) => sum + player.currentSkill);
      return (totalSkill / _academyPlayers.length).round();
    } else {
      // Look up AI club skill from the centralized map
      final aiClub = _aiClubMap[teamId];
      if (aiClub != null) {
        return aiClub.skillLevel;
      } else {
        // Fallback if AI club not found (shouldn't happen ideally)
        print("Warning: AI Club with ID '$teamId' not found in _aiClubMap. Returning default skill.");
        return 30; // Default low skill for unknown AI clubs
      }
    }
  }

  // --- Team Selection Logic ---

  // Selects the best N players for the player's academy based on skill
  List<Player> selectPlayerTeamForMatch(TournamentType type, {Staff? manager}) {
    int playersNeeded = _getPlayersNeededForType(type);
    if (_academyPlayers.length < playersNeeded) {
      print("Warning: Not enough players in academy (${_academyPlayers.length}) for a ${type.toString()} match (needs $playersNeeded). Selecting all available.");
      // Return a copy to avoid modifying the original list directly
      return List<Player>.from(_academyPlayers);
    }

    // Sort players by current skill (descending)
    // Create a mutable copy before sorting
    List<Player> sortedPlayers = List<Player>.from(_academyPlayers);
    sortedPlayers.sort((a, b) => b.currentSkill.compareTo(a.currentSkill));

    // TODO: Incorporate manager skill influence later?
    // For now, just take the top N players
    return sortedPlayers.sublist(0, playersNeeded);
  }

  // Selects the best N players for an AI club based on skill
  List<Player> selectAITeamForMatch(TournamentType type, AIClub aiClub) {
     int playersNeeded = _getPlayersNeededForType(type);
     if (aiClub.players.length < playersNeeded) {
       print("Warning: Not enough players in AI club ${aiClub.name} (${aiClub.players.length}) for a ${type.toString()} match (needs $playersNeeded). Selecting all available.");
       // Return a copy
       return List<Player>.from(aiClub.players);
     }

     // Sort players by current skill (descending)
     // Create a mutable copy before sorting
     List<Player> sortedPlayers = List<Player>.from(aiClub.players);
     sortedPlayers.sort((a, b) => b.currentSkill.compareTo(a.currentSkill));

     // Take the top N players
     return sortedPlayers.sublist(0, playersNeeded);
  }

  // Helper to get the number of players required for a tournament type
  int _getPlayersNeededForType(TournamentType type) {
     switch (type) {
      case TournamentType.threeVthree: return 3;
      case TournamentType.fiveVfive: return 5;
      case TournamentType.sevenVseven: return 7;
      case TournamentType.elevenVeleven: return 11;
      default: return 11; // Default to 11v11
    }
  }
  // --- End Team Selection Logic ---

  // --- Reputation Update Logic ---

  void _updateReputationAfterMatch(Tournament tournament, Match match) {
    // This method is now called after *every* simulated match within the week.
    if (!match.isSimulated || match.result == null) return;

    const String playerAcademyId = 'player_academy_1';
    bool playerInvolved = match.homeTeamId == playerAcademyId || match.awayTeamId == playerAcademyId;
    int reputationChange = 0;
    int playerReputationChangeBase = 0;

    // Base reputation change based on result (if player involved)
    if (playerInvolved) {
      bool playerWon = (match.homeTeamId == playerAcademyId && match.result == MatchResult.homeWin) ||
                       (match.awayTeamId == playerAcademyId && match.result == MatchResult.awayWin);
      bool playerDrew = match.result == MatchResult.draw;

      if (playerWon) {
        reputationChange = 5; // Base win
        playerReputationChangeBase = 3;
      } else if (playerDrew) {
        reputationChange = 1; // Base draw
        playerReputationChangeBase = 1;
      } else {
        reputationChange = -3; // Base loss
        playerReputationChangeBase = -1;
      }

      // Modify change based on tournament importance (example)
      // TODO: Add importance/level to Tournament model
      // if (tournament.level > 1) {
      //   reputationChange *= tournament.level;
      //   playerReputationChangeBase *= tournament.level;
      // }

      _academyReputation = max(0, _academyReputation + reputationChange);
      print("Academy reputation changed by $reputationChange to $_academyReputation after match ${match.id}");
    }

    // Update player reputation for goals/assists/playing
    List<Player> participants = [];
    if (match.homeTeamId == playerAcademyId) {
      participants.addAll(_academyPlayers.where((p) => match.homeLineup.contains(p.id)));
    }
    if (match.awayTeamId == playerAcademyId) {
      participants.addAll(_academyPlayers.where((p) => match.awayLineup.contains(p.id)));
    }

    for (var player in participants) {
      int individualChange = playerReputationChangeBase; // Start with base change for playing

      // Find goals for this player in the event log
      int goals = 0;
      for (var event in match.eventLog) {
        if (event.type == MatchEventType.Goal && event.playerId == player.id) {
          goals++;
        }
        // TODO: Add assist check when assists are implemented in MatchEvent
      }

      individualChange += goals * 5; // Bonus for goals

      if (individualChange != 0) {
         player.reputation = max(0, player.reputation + individualChange);
         print("Player ${player.name} reputation changed by $individualChange to ${player.reputation}");
      }
    }
  }

  void _updateReputationDecay() {
    // Simple decay for academy
    _academyReputation = max(0, _academyReputation - 1); // Lose 1 rep per week passively

    // Decay for players who didn't participate significantly (can refine later)
    // This is a placeholder - ideally track if player played in *any* match this week
    for (var player in _academyPlayers) {
       // Simple check: if they weren't in the *last* simulated match's lineup (inaccurate but simple)
       // A better approach needs tracking participation across all matches in the week.
       // For now, let's just apply a small decay universally and rely on match gains.
       player.reputation = max(0, player.reputation - 1); // Small decay
    }
     print("Applied weekly reputation decay. Academy: $_academyReputation");
  }

  // --- End Reputation Update Logic ---

  // --- Transfer Offer Logic (Basic) ---

  void _generateTransferOffers() {
    _transferOffers.clear(); // Clear old offers
    final random = Random();

    // Simple chance for offers based on player reputation and academy reputation
    for (var player in _academyPlayers) {
      // Higher chance for higher rep players and higher academy rep
      double offerChance = (player.reputation / 500.0) + (_academyReputation / 1000.0);
      offerChance = offerChance.clamp(0.0, 0.2); // Max 20% chance per player per week

      if (random.nextDouble() < offerChance) {
        // Generate a placeholder offer
        // TODO: Use AIClub reputation/size later
        String offeringClubName = _allAICLubs[random.nextInt(_allAICLubs.length)].name;
        // Simple fee based on skill and reputation
        int offerAmount = (player.currentSkill * 100) + (player.reputation * 50) + random.nextInt(5000);

        _transferOffers.add({
          'playerId': player.id,
          'playerName': player.name,
          'offeringClubName': offeringClubName,
          'offerAmount': offerAmount,
        });
        print("Generated transfer offer for ${player.name} from $offeringClubName for $offerAmount");
      }
    }
    // No notifyListeners here, UI will pull data when viewed
  }

  void acceptTransferOffer(Map<String, dynamic> offer) {
    String playerId = offer['playerId'];
    int offerAmount = offer['offerAmount'];

    // Find player manually to avoid orElse issue
    Player? player;
    int playerIndex = -1;
    for (int i = 0; i < _academyPlayers.length; i++) {
        if (_academyPlayers[i].id == playerId) {
            player = _academyPlayers[i];
            playerIndex = i;
            break;
        }
    }

    if (player != null && playerIndex != -1) {
      // --- Unassign player from coach BEFORE removing them ---
      unassignPlayerFromAnyCoach(playerId);
      // ---

      _balance += offerAmount;
      _academyPlayers.removeAt(playerIndex); // Remove by index
      // _academyPlayers.remove(player); // removeAt is sufficient
      _transferOffers.removeWhere((o) => o['playerId'] == playerId); // Remove this offer
      _calculateWeeklyWages(); // Recalculate wages
      // TODO: Add reputation boost for successful transfer?
      print("Accepted transfer offer for ${player.name}. Received $offerAmount. Balance: $_balance");
      notifyListeners(); // Update UI (player list, balance)
    }
  }

  void rejectTransferOffer(Map<String, dynamic> offer) {
     _transferOffers.removeWhere((o) => o['playerId'] == offer['playerId']);
     // TODO: Potential small reputation hit for rejecting?
     print("Rejected transfer offer for ${offer['playerName']}");
     notifyListeners(); // Update offer list UI
  }

  // --- End Transfer Offer Logic ---

  // --- Facility Upgrade Logic ---

  // Helper to calculate upgrade cost (example formula)
  int _calculateFacilityUpgradeCost(int currentLevel) {
    // Exponential increase: e.g., 10k, 25k, 50k, 85k, 130k...
    return (pow(currentLevel, 1.5) * 5000).toInt() + 10000;
  }

  // Method to get the cost for the *next* level upgrade
  int getTrainingFacilityUpgradeCost() {
    return _calculateFacilityUpgradeCost(_trainingFacilityLevel);
  }

  int getScoutingFacilityUpgradeCost() {
    return _calculateFacilityUpgradeCost(_scoutingFacilityLevel);
  }

  // Attempt to upgrade the training facility
  bool upgradeTrainingFacility() {
    int cost = getTrainingFacilityUpgradeCost();
    if (_balance >= cost) {
      _balance -= cost;
      _trainingFacilityLevel++;
      print("Upgraded Training Facility to Level $_trainingFacilityLevel. Cost: $cost. Balance: $_balance");
      notifyListeners(); // Update balance and facility level UI
      return true;
    } else {
      print("Cannot upgrade Training Facility. Cost: $cost, Balance: $_balance");
      return false;
    }
  }

  // Attempt to upgrade the scouting facility
  bool upgradeScoutingFacility() {
    int cost = getScoutingFacilityUpgradeCost();
    if (_balance >= cost) {
      _balance -= cost;
      _scoutingFacilityLevel++;
      print("Upgraded Scouting Facility to Level $_scoutingFacilityLevel. Cost: $cost. Balance: $_balance");
      notifyListeners(); // Update balance and facility level UI
      return true;
    } else {
      print("Cannot upgrade Scouting Facility. Cost: $cost, Balance: $_balance");
      return false;
    }
  }

  // --- End Facility Upgrade Logic ---

}
