import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'models/tournament.dart';
import 'models/match.dart';
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'models/tournament.dart';
import 'models/match.dart';
import 'models/player.dart'; // Import Player model
import 'models/staff.dart'; // Import Staff model
import 'models/ai_club.dart'; // Import AIClub model
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

    // 5. TODO: Other weekly events (facility effects, news, etc.)

    // 6. Notify Listeners
    notifyListeners(); // Notify listeners about changes (date, scouted players, balance, etc.)
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
          // TODO: Award prizes, update reputation, etc.
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
    // Simple training logic: Iterate through academy players and give them a chance to improve
    // TODO: Enhance this with coach skill, facility levels, player age, potential influence, etc.
    print("--- Handling Player Training ---");
    bool playerImproved = false; // Flag to see if any player improved for logging

    for (var player in _academyPlayers) {
      if (player.currentSkill < player.potentialSkill) {
        // Base chance + bonus from facility level
        // Example: Base 20% + 5% per facility level
        int baseChance = 20;
        int facilityBonus = (_trainingFacilityLevel * 5); // 5% bonus per level
        int totalChance = baseChance + facilityBonus;
        // Ensure chance doesn't exceed a reasonable maximum (e.g., 90%)
        totalChance = min(totalChance, 90);

        if (_random.nextInt(100) < totalChance) {
          player.currentSkill++; // Increase skill by 1
          print("Player ${player.name} improved skill to ${player.currentSkill} (Potential: ${player.potentialSkill}) - Facility Level: $_trainingFacilityLevel, Chance: $totalChance%");
          playerImproved = true;
        }
      }
    }
    if (!playerImproved) {
      print("No players improved this week.");
    }
  }
  // --- End Player Training Logic ---


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

}
