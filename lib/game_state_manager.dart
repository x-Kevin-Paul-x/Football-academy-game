import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'models/tournament.dart';
import 'models/match.dart';
import 'models/player.dart'; // Import Player model
import 'models/staff.dart'; // Import Staff model
import 'models/ai_club.dart'; // Import AIClub model
import 'models/match_event.dart'; // Import MatchEventType
import 'models/news_item.dart';
import 'models/difficulty.dart'; // Import Difficulty enum
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart'; // Import for ThemeMode

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
  List<Map<String, dynamic>> _transferOffers = [];

  // --- News Feed ---
  final List<NewsItem> _newsItems = [];

  // --- Settings ---
  Difficulty _difficulty = Difficulty.Normal; // Default difficulty
  ThemeMode _themeMode = ThemeMode.system; // Default theme

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
  List<NewsItem> get newsItems => List.unmodifiable(_newsItems.reversed);
  Difficulty get difficulty => _difficulty; // Getter for difficulty
  ThemeMode get themeMode => _themeMode; // Getter for theme mode

  GameStateManager() {
    // Initialize game state on creation - Apply initial difficulty settings
    _applyDifficultySettings(); // Apply settings like starting balance
    _generateInitialAvailableStaff();
    _populateAIClubMap();
    _calculateWeeklyWages();
  }

  // --- Initialization & Reset ---
  // REMOVED: Temporary player generation method
  // void _generateInitialAcademyPlayers() {
  //   // Add 8 random players for testing purposes
  //   for (int i = 0; i < 8; i++) {
  //     _academyPlayers.add(Player.randomScoutedPlayer('initial_player_$i')..isScouted = false); // Mark as not scouted
  //   }
  //   print("Generated ${_academyPlayers.length} initial academy players for testing.");
  // }

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

  // Method to apply settings based on current difficulty
  void _applyDifficultySettings() {
     switch (_difficulty) {
       case Difficulty.Easy:
         _balance = 75000.0; // Higher starting balance
         _weeklyIncome = 1200;
         break;
       case Difficulty.Normal:
         _balance = 50000.0;
         _weeklyIncome = 1000;
         break;
       case Difficulty.Hard:
         _balance = 30000.0; // Lower starting balance
         _weeklyIncome = 800;
         break;
     }
     // Note: Other difficulty effects are applied where relevant (AI skill, training, etc.)
  }

  // Method to reset the entire game state
  void resetGame() {
    print("--- RESETTING GAME STATE ---");
    // Reset core state
    _currentDate = DateTime(2025, 7, 1);
    _difficulty = Difficulty.Normal; // Reset difficulty to default
    _themeMode = ThemeMode.system; // Reset theme to default

    // Reset player/staff state
    _academyPlayers.clear();
    _hiredStaff.clear();
    _scoutedPlayers.clear();
    _availableStaff.clear();

    // Reset financial state (apply difficulty defaults)
    _applyDifficultySettings(); // This resets balance and income
    _totalWeeklyWages = 0;

    // Reset tournament state
    _activeTournaments.clear();
    _completedTournaments.clear();

    // AI Clubs are usually static, but regenerate if needed (or just repopulate map)
    // _allAICLubs = List.generate(16, (index) => AIClub.placeholder(index)); // If regeneration needed
    _aiClubMap.clear();
    _populateAIClubMap(); // Repopulate map

    // Reset facility state
    _trainingFacilityLevel = 1;
    _scoutingFacilityLevel = 1;

    // Reset reputation
    _academyReputation = 100;

    // Reset transfers & news
    _transferOffers.clear();
    _newsItems.clear();

    // Re-initialize necessary parts
    _generateInitialAvailableStaff();
    _calculateWeeklyWages(); // Recalculate (should be 0)

    notifyListeners(); // Notify UI about the reset
    print("--- GAME STATE RESET COMPLETE ---");
  }

  // --- Weekly Update Logic ---

  // Method to advance the game by one week
  void advanceWeek() {
    _currentDate = _currentDate.add(const Duration(days: 7));
    print("Advancing week to: $_currentDate"); // Simple log

    // 1. Update Finances
    _balance += _weeklyIncome;
    _balance -= _totalWeeklyWages; // Wages calculated at end of previous week/when staff/players change

    // 2. Scouting Logic
    _scoutedPlayers.clear(); // Clear previous week's reports
    int totalScoutingSkill = _hiredStaff
        .where((s) => s.role == StaffRole.Scout)
        .fold(0, (sum, scout) => sum + scout.skill);

    // Generate players based on total scouting skill (simple example)
    int playersToFind = (totalScoutingSkill / 50).ceil() + _random.nextInt(2); // More skill = more players
    if (_hiredStaff.where((s) => s.role == StaffRole.Scout).isEmpty) {
      playersToFind = 0; // No scouts, no players found
    }
    print("Scouting found $playersToFind players this week.");

    for (int i = 0; i < playersToFind; i++) {
      _scoutedPlayers.add(Player.randomScoutedPlayer('scouted_${_currentDate.millisecondsSinceEpoch}_$i'));
    }
    // --- Add Scouting News ---
    if (playersToFind > 0) {
       _addNewsItem(NewsItem.create(
         title: "Scouting Report",
         description: "Our scouts have identified $playersToFind potential new players this week.",
         type: NewsItemType.Scouting,
         date: _currentDate,
       ));
    } else if (_hiredStaff.any((s) => s.role == StaffRole.Scout)) {
       _addNewsItem(NewsItem.create(
         title: "Scouting Report",
         description: "Scouts found no notable players this week.",
         type: NewsItemType.Scouting,
         date: _currentDate,
       ));
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
    print("Calculated weekly wages: $_totalWeeklyWages");
  }

  void hireStaff(Staff staffToHire) {
    _hiredStaff.add(staffToHire);
    _availableStaff.removeWhere((s) => s.id == staffToHire.id);
    _calculateWeeklyWages(); // Recalculate wages
    // --- Add Staff Change News ---
    _addNewsItem(NewsItem.create(
      title: "Staff Hired",
      description: "We have hired ${staffToHire.name} as our new ${staffToHire.role.toString().split('.').last}.",
      type: NewsItemType.StaffChange,
      date: _currentDate,
    ));
    // --- End Staff Change News ---
    notifyListeners();
    print("Hired ${staffToHire.name}");
  }

  void signPlayer(Player playerToSign) {
    playerToSign.isScouted = false; // Mark as signed
    _academyPlayers.add(playerToSign);
    _scoutedPlayers.removeWhere((p) => p.id == playerToSign.id);
    _calculateWeeklyWages(); // Recalculate wages
    // --- Add Player Signed News ---
    _addNewsItem(NewsItem.create(
      title: "Player Signed",
      description: "We have signed the promising young player ${playerToSign.name} to the academy.",
      type: NewsItemType.PlayerSigned,
      date: _currentDate,
    ));
    // --- End Player Signed News ---
    notifyListeners();
    print("Signed ${playerToSign.name}");
  }

  void rejectPlayer(Player playerToReject) {
    _scoutedPlayers.removeWhere((p) => p.id == playerToReject.id);
    notifyListeners();
    print("Rejected ${playerToReject.name}");
  }

  void addActiveTournament(Tournament tournament) {
    if (!_activeTournaments.any((t) => t.id == tournament.id)) {
      _activeTournaments.add(tournament);
      print("Tournament ${tournament.name} added to active tournaments.");
    }
  }

  // Internal method to simulate matches scheduled within the week that just passed
  void _simulateMatchesForWeek() {
    DateTime startOfWeek = _currentDate.subtract(const Duration(days: 7));
    DateTime endOfWeek = _currentDate;

    print("Simulating matches between $startOfWeek and $endOfWeek");

    List<Tournament> completedTournaments = [];

    for (var tournament in _activeTournaments) {
      if (tournament.status == TournamentStatus.InProgress) {
        bool tournamentMatchesRemaining = false;
        for (var match in tournament.matches) {
          if (!match.isSimulated &&
              !match.matchDate.isBefore(startOfWeek) &&
              match.matchDate.isBefore(endOfWeek)) {

            print("Preparing detailed simulation for match: ${match.id} scheduled for ${match.matchDate}");

            TournamentType tournamentType = tournament.type;
            List<Player> homeLineup;
            List<Player> awayLineup;
            const String playerAcademyId = 'player_academy_1';

            // Select Home Team
            if (match.homeTeamId == playerAcademyId) {
              homeLineup = selectPlayerTeamForMatch(tournamentType);
            } else {
              AIClub? homeAIClub = _aiClubMap[match.homeTeamId];
              homeLineup = (homeAIClub != null)
                  ? selectAITeamForMatch(tournamentType, homeAIClub)
                  : [];
              if (homeAIClub == null) print("Error: Home AI Club ${match.homeTeamId} not found for match ${match.id}. Using empty lineup.");
            }

            // Select Away Team
            if (match.awayTeamId == playerAcademyId) {
              awayLineup = selectPlayerTeamForMatch(tournamentType);
            } else {
              AIClub? awayAIClub = _aiClubMap[match.awayTeamId];
              awayLineup = (awayAIClub != null)
                  ? selectAITeamForMatch(tournamentType, awayAIClub)
                  : [];
               if (awayAIClub == null) print("Error: Away AI Club ${match.awayTeamId} not found for match ${match.id}. Using empty lineup.");
            }

            // Call the detailed simulation method
            match.simulateDetailed(homeLineup, awayLineup);

            // --- Update Player Stats & Fatigue AFTER simulation ---
            _updatePlayerStatsAndFatigue(match, homeLineup, awayLineup);
            // ---

            // Update reputation immediately after simulation
            _updateReputationAfterMatch(tournament, match);

            // --- Add Match Result News ---
            if (match.isSimulated && match.result != null) {
              const String playerAcademyId = 'player_academy_1'; // Define here or ensure it's accessible
              String homeTeamName = match.homeTeamId == playerAcademyId ? "Academy" : (_aiClubMap[match.homeTeamId]?.name ?? match.homeTeamId);
              String awayTeamName = match.awayTeamId == playerAcademyId ? "Academy" : (_aiClubMap[match.awayTeamId]?.name ?? match.awayTeamId);
              String resultString;
              switch (match.result!) {
                case MatchResult.homeWin: resultString = "won against"; break;
                case MatchResult.awayWin: resultString = "lost to"; break;
                case MatchResult.draw: resultString = "drew with"; break;
              }
              if (match.awayTeamId == playerAcademyId) { // Flip perspective if player is away
                 switch (match.result!) {
                   case MatchResult.homeWin: resultString = "lost to"; break;
                   case MatchResult.awayWin: resultString = "won against"; break;
                   case MatchResult.draw: resultString = "drew with"; break;
                 }
              }
              String score = "${match.homeScore} - ${match.awayScore}";
              String opponentName = match.homeTeamId == playerAcademyId ? awayTeamName : homeTeamName;

              _addNewsItem(NewsItem.create(
                title: "Match Result (${tournament.name})",
                description: "Academy $resultString $opponentName $score.",
                type: NewsItemType.MatchResult,
                date: match.matchDate, // Use match date for the news item
              ));
            }
            // --- End Match Result News ---
          }
          if (!match.isSimulated) {
            tournamentMatchesRemaining = true;
          }
        }

        if (!tournamentMatchesRemaining) {
          print("Tournament ${tournament.name} completed.");
          tournament.status = TournamentStatus.Completed;
          completedTournaments.add(tournament);
        }
      }
    }

    if (completedTournaments.isNotEmpty) {
      _completedTournaments.addAll(completedTournaments);
      _activeTournaments.removeWhere((t) => completedTournaments.contains(t));
      print("Moved ${completedTournaments.length} tournaments to history.");
    }

    // --- Weekly Fatigue Recovery ---
    _applyWeeklyFatigueRecovery();
    // ---
  }

  // --- Player Stats & Fatigue Update Logic ---
  void _updatePlayerStatsAndFatigue(Match match, List<Player> homeLineup, List<Player> awayLineup) {
    if (!match.isSimulated) return;

    Set<String> academyPlayersInMatch = {}; // Track who played

    // Combine lineups for easier iteration
    List<Player> allPlayersInMatch = [...homeLineup, ...awayLineup];

    // Find academy players involved and update matches played + fatigue increase
     for (var lineupPlayer in allPlayersInMatch) {
       // Check if this player is from the academy using firstWhereOrNull
       Player? academyPlayer = _academyPlayers.firstWhereOrNull((p) => p.id == lineupPlayer.id);

       if (academyPlayer != null) {
         academyPlayersInMatch.add(academyPlayer.id); // Mark as played
         academyPlayer.matchesPlayed++;

         // Fatigue increase - higher for lower stamina
         double fatigueIncrease = 15.0 + ( (100 - academyPlayer.stamina) / 10.0 ); // Base 15, +0 for 100 stamina, +10 for 0 stamina
         academyPlayer.fatigue = (academyPlayer.fatigue + fatigueIncrease).clamp(0.0, 100.0);

         print("Player ${academyPlayer.name} played match ${match.id}. Matches: ${academyPlayer.matchesPlayed}, Fatigue: ${academyPlayer.fatigue.toStringAsFixed(1)}%");
       }
    }

    // Update goals and assists from event log
    for (var event in match.eventLog) {
       // Check if this player is from the academy using firstWhereOrNull
       Player? academyPlayer = _academyPlayers.firstWhereOrNull((p) => p.id == event.playerId);
       if (academyPlayer != null) {
         if (event.type == MatchEventType.Goal) {
           academyPlayer.goalsScored++;
           print("Player ${academyPlayer.name} scored! Total goals: ${academyPlayer.goalsScored}");
         } else if (event.type == MatchEventType.Assist) { // Assuming Assist type exists
           academyPlayer.assists++;
            print("Player ${academyPlayer.name} assisted! Total assists: ${academyPlayer.assists}");
         }
       }
    }
  }

  void _applyWeeklyFatigueRecovery() {
     print("--- Applying Weekly Fatigue Recovery ---");
     for (var player in _academyPlayers) {
        // Base recovery - higher for higher stamina
        double recoveryAmount = 5.0 + (player.stamina / 10.0); // Base 5, +0 for 0 stamina, +10 for 100 stamina
        player.fatigue = (player.fatigue - recoveryAmount).clamp(0.0, 100.0);
     }
  }
  // --- End Player Stats & Fatigue Update Logic ---

  // --- Player Training Logic ---
  void _handlePlayerTraining() {
    print("--- Handling Player Training ---");
    bool anyPlayerImproved = false;
    Map<String, Player> playerMap = { for (var p in _academyPlayers) p.id : p };
    final coaches = _hiredStaff.where((s) => s.role == StaffRole.Coach).toList();

    if (coaches.isEmpty) {
      print("No coaches hired. No specific player training applied this week.");
      return;
    }

    Set<String> trainedPlayerIds = {};

    for (var coach in coaches) {
      print("Coach ${coach.name} (Skill: ${coach.skill}, Capacity: ${coach.assignedPlayerIds.length}/${coach.maxPlayersTrainable}) is training...");
      for (var playerId in coach.assignedPlayerIds) {
        if (playerMap.containsKey(playerId) && !trainedPlayerIds.contains(playerId)) {
          Player player = playerMap[playerId]!;
          trainedPlayerIds.add(playerId);

          if (player.currentSkill < player.potentialSkill) {
            int baseChance = 5; // Base chance to improve
            int coachBonus = (coach.skill / 5).floor(); // Bonus from coach skill
            int facilityBonus = (_trainingFacilityLevel * 3); // Bonus from facility level
            int difficultyModifier = 0; // Modifier based on difficulty

            switch (_difficulty) {
              case Difficulty.Easy: difficultyModifier = 5; break; // Easier to improve
              case Difficulty.Normal: difficultyModifier = 0; break;
              case Difficulty.Hard: difficultyModifier = -5; break; // Harder to improve
            }

            int totalChance = (baseChance + coachBonus + facilityBonus + difficultyModifier).clamp(1, 99); // Apply difficulty

            if (_random.nextInt(100) < totalChance) {
              int oldSkill = player.currentSkill;
              player.currentSkill++;
              print("  -> Player ${player.name} (under ${coach.name}) improved skill to ${player.currentSkill}. Chance: $totalChance%");
              anyPlayerImproved = true;
              // --- Add Training News ---
              _addNewsItem(NewsItem.create(
                title: "Player Improved",
                description: "${player.name} improved their skill from $oldSkill to ${player.currentSkill} under Coach ${coach.name}.",
                type: NewsItemType.Training,
                date: _currentDate,
              ));
              // --- End Training News ---
            }
          }
        } else if (!playerMap.containsKey(playerId)) {
           print("  -> Warning: Player ID $playerId assigned to coach ${coach.name} not found in academy players.");
        }
      }
    }

    int unassignedCount = _academyPlayers.where((p) => !trainedPlayerIds.contains(p.id)).length;
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
    int removedCount = 0;
    _availableStaff.removeWhere((staff) {
      bool leaving = _random.nextDouble() < 0.20;
      if (leaving) removedCount++;
      return leaving;
    });

    int newStaffCount = 1 + _random.nextInt(3);
    int addedCount = 0;
    for (int i = 0; i < newStaffCount; i++) {
      StaffRole role = StaffRole.values[_random.nextInt(StaffRole.values.length)];
      if ((role == StaffRole.Physio || role == StaffRole.Manager) && _random.nextBool()) {
         role = StaffRole.values[_random.nextInt(StaffRole.values.length)];
      }
      if (_availableStaff.length < 15) {
         Staff newStaff = Staff.randomStaff('staff_${_currentDate.millisecondsSinceEpoch}_$i', role);
         _availableStaff.add(newStaff);
         addedCount++;
      }
    }
    print("Staff Market Refreshed: $removedCount removed, $addedCount added. Total available: ${_availableStaff.length}");
  }
  // --- End Staff Market Logic ---

  // --- Player-Coach Assignment Logic ---
  bool assignPlayerToCoach(String playerId, String coachId) {
    Staff? coach = _hiredStaff.firstWhereOrNull((s) => s.id == coachId && s.role == StaffRole.Coach);
    if (coach == null) {
      print("Error: Coach with ID $coachId not found or is not a coach.");
      return false;
    }
    Player? player = _academyPlayers.firstWhereOrNull((p) => p.id == playerId);
    if (player == null) {
      print("Error: Player with ID $playerId not found in academy.");
      return false;
    }
    if (coach.assignedPlayerIds.length >= coach.maxPlayersTrainable) {
      print("Error: Coach ${coach.name} is already at maximum capacity (${coach.maxPlayersTrainable}). Cannot assign ${player.name}.");
      return false;
    }
    if (coach.assignedPlayerIds.contains(playerId)) {
      print("Info: Player ${player.name} is already assigned to coach ${coach.name}.");
      return true;
    }
    unassignPlayerFromAnyCoach(playerId);
    coach.assignedPlayerIds.add(playerId);
    print("Assigned player ${player.name} to coach ${coach.name}.");
    notifyListeners();
    return true;
  }

  bool unassignPlayerFromCoach(String playerId, String coachId) {
    Staff? coach = _hiredStaff.firstWhereOrNull((s) => s.id == coachId && s.role == StaffRole.Coach);
    if (coach == null) {
      print("Error: Coach with ID $coachId not found or is not a coach.");
      return false;
    }
    Player? player = _academyPlayers.firstWhereOrNull((p) => p.id == playerId);
    String playerName = player?.name ?? 'ID: $playerId';

    bool removed = coach.assignedPlayerIds.remove(playerId);
    if (removed) {
      print("Unassigned player $playerName from coach ${coach.name}.");
      notifyListeners();
    } else {
       print("Info: Player $playerName was not assigned to coach ${coach.name}.");
    }
    return removed;
  }

  void unassignPlayerFromAnyCoach(String playerId) {
    for (var coach in _hiredStaff.where((s) => s.role == StaffRole.Coach)) {
      if (coach.assignedPlayerIds.contains(playerId)) {
        unassignPlayerFromCoach(playerId, coach.id);
        break;
      }
    }
  }

  Staff? getCoachForPlayer(String playerId) {
     return _hiredStaff.firstWhereOrNull((s) => s.role == StaffRole.Coach && s.assignedPlayerIds.contains(playerId));
  }
  // --- End Player-Coach Assignment Logic ---

  // Calculates the effective skill level for a given team ID, considering fatigue
  int _getTeamSkill(String teamId, List<Player> selectedLineup) {
    const String playerAcademyId = 'player_academy_1';

    if (selectedLineup.isEmpty) {
       return 10; // Default low skill if no players in lineup
    }

    // Calculate average effective skill of the selected lineup
    double totalEffectiveSkill = 0;
    for (var player in selectedLineup) {
       // Apply fatigue penalty: 0% penalty at 0 fatigue, up to 50% penalty at 100 fatigue
       double fatigueModifier = 1.0 - (player.fatigue / 200.0);
       totalEffectiveSkill += player.currentSkill * fatigueModifier;
    }

    int averageEffectiveSkill = (totalEffectiveSkill / selectedLineup.length).round();

    // If it's an AI team, use their base skill as a floor/influence?
    if (teamId != playerAcademyId) {
       int baseAISkill = _getBaseAIClubSkill(teamId);
       // Example: Blend AI base skill and lineup effective skill
       averageEffectiveSkill = ((averageEffectiveSkill * 0.7) + (baseAISkill * 0.3)).round();
    }

    return averageEffectiveSkill.clamp(1, 100); // Ensure skill stays within bounds
  }

  // --- AI Club Skill Lookup (Modified by Difficulty) ---
  int _getBaseAIClubSkill(String teamId) {
     final aiClub = _aiClubMap[teamId];
     if (aiClub != null) {
       int baseSkill = aiClub.skillLevel;
       // Apply difficulty modifier
       switch (_difficulty) {
         case Difficulty.Easy: baseSkill = (baseSkill * 0.85).round().clamp(1, 100); break; // Lower AI skill
         case Difficulty.Normal: break; // No change
         case Difficulty.Hard: baseSkill = (baseSkill * 1.15).round().clamp(1, 100); break; // Higher AI skill
       }
       return baseSkill;
     } else {
       print("Warning: AI Club with ID '$teamId' not found in _aiClubMap. Returning default skill.");
       return 30;
     }
  }
  // --- End AI Club Skill Lookup ---

  // --- Team Selection Logic ---
  List<Player> selectPlayerTeamForMatch(TournamentType type, {Staff? manager}) {
    int playersNeeded = _getPlayersNeededForType(type);
    if (_academyPlayers.length < playersNeeded) {
      print("Warning: Not enough players in academy (${_academyPlayers.length}) for a ${type.toString()} match (needs $playersNeeded). Selecting all available.");
      return List<Player>.from(_academyPlayers);
    }

    // Sort players primarily by skill, but consider fatigue
    List<Player> availablePlayers = List<Player>.from(_academyPlayers);
    availablePlayers.sort((a, b) {
      double fatiguePenaltyA = a.fatigue > 75 ? 50 : (a.fatigue / 2);
      double fatiguePenaltyB = b.fatigue > 75 ? 50 : (b.fatigue / 2);
      double effectiveScoreA = a.currentSkill - fatiguePenaltyA;
      double effectiveScoreB = b.currentSkill - fatiguePenaltyB;
      return effectiveScoreB.compareTo(effectiveScoreA); // Descending by effective score
    });

    return availablePlayers.sublist(0, playersNeeded);
  }

  List<Player> selectAITeamForMatch(TournamentType type, AIClub aiClub) {
     int playersNeeded = _getPlayersNeededForType(type);
     if (aiClub.players.length < playersNeeded) {
       print("Warning: Not enough players in AI club ${aiClub.name} (${aiClub.players.length}) for a ${type.toString()} match (needs $playersNeeded). Selecting all available.");
       return List<Player>.from(aiClub.players);
     }

     // Sort AI players similarly (considering fatigue for their selection too)
     List<Player> availablePlayers = List<Player>.from(aiClub.players);
     availablePlayers.sort((a, b) {
        double fatiguePenaltyA = a.fatigue > 75 ? 50 : (a.fatigue / 2); // AI also suffers fatigue
        double fatiguePenaltyB = b.fatigue > 75 ? 50 : (b.fatigue / 2);
        double effectiveScoreA = a.currentSkill - fatiguePenaltyA;
        double effectiveScoreB = b.currentSkill - fatiguePenaltyB;
        return effectiveScoreB.compareTo(effectiveScoreA);
     });

     return availablePlayers.sublist(0, playersNeeded);
  }

  int _getPlayersNeededForType(TournamentType type) {
     switch (type) {
      case TournamentType.threeVthree: return 3;
      case TournamentType.fiveVfive: return 5;
      case TournamentType.sevenVseven: return 7;
      case TournamentType.elevenVeleven: return 11;
      default: return 11;
    }
  }
  // --- End Team Selection Logic ---

  // --- Reputation Update Logic ---
  void _updateReputationAfterMatch(Tournament tournament, Match match) {
    if (!match.isSimulated || match.result == null) return;

    const String playerAcademyId = 'player_academy_1';
    bool playerInvolved = match.homeTeamId == playerAcademyId || match.awayTeamId == playerAcademyId;
    int reputationChange = 0;
    int playerReputationChangeBase = 0;

    if (playerInvolved) {
      bool playerWon = (match.homeTeamId == playerAcademyId && match.result == MatchResult.homeWin) ||
                       (match.awayTeamId == playerAcademyId && match.result == MatchResult.awayWin);
      bool playerDrew = match.result == MatchResult.draw;

      if (playerWon) {
        reputationChange = 5; playerReputationChangeBase = 3;
      } else if (playerDrew) {
        reputationChange = 1; playerReputationChangeBase = 1;
      } else {
        reputationChange = -3; playerReputationChangeBase = -1;
      }
      _academyReputation = max(0, _academyReputation + reputationChange);
      print("Academy reputation changed by $reputationChange to $_academyReputation after match ${match.id}");
    }

    // Update player reputation for goals/assists/playing
    // Get IDs of academy players who participated
    Set<String> participatingPlayerIds = {};
    if (match.homeTeamId == playerAcademyId) {
        participatingPlayerIds.addAll(match.homeLineup); // homeLineup is already List<String>
    }
    if (match.awayTeamId == playerAcademyId) {
        participatingPlayerIds.addAll(match.awayLineup); // awayLineup is already List<String>
    }

    // Iterate through academy players who actually played
    for (String playerId in participatingPlayerIds) {
        Player? player = _academyPlayers.firstWhereOrNull((p) => p.id == playerId);
        if (player == null) continue; // Should not happen if lineup IDs are correct

        int individualChange = playerReputationChangeBase; // Start with base change for playing

        // Find goals/assists for this player in the event log
        int goals = 0;
        int assists = 0;
        for (var event in match.eventLog) {
            if (event.playerId == player.id) {
                if (event.type == MatchEventType.Goal) goals++;
                if (event.type == MatchEventType.Assist) assists++;
            }
        }

        individualChange += goals * 5; // Bonus for goals
        individualChange += assists * 3; // Bonus for assists

        if (individualChange != 0) {
            player.reputation = max(0, player.reputation + individualChange);
            print("Player ${player.name} reputation changed by $individualChange to ${player.reputation}");
        }
    }
  }

  void _updateReputationDecay() {
    _academyReputation = max(0, _academyReputation - 1);
    for (var player in _academyPlayers) {
       player.reputation = max(0, player.reputation - 1);
    }
     print("Applied weekly reputation decay. Academy: $_academyReputation");
  }
  // --- End Reputation Update Logic ---

  // --- Transfer Offer Logic (Basic) ---
  void _generateTransferOffers() {
    _transferOffers.clear();
    final random = Random();
    for (var player in _academyPlayers) {
      double offerChance = ((player.reputation / 500.0) + (_academyReputation / 1000.0)).clamp(0.0, 0.2);
      if (random.nextDouble() < offerChance) {
        String offeringClubName = _allAICLubs[random.nextInt(_allAICLubs.length)].name;
        int offerAmount = (player.currentSkill * 100) + (player.reputation * 50) + random.nextInt(5000);
        _transferOffers.add({
          'playerId': player.id,
          'playerName': player.name,
          'offeringClubName': offeringClubName,
          'offerAmount': offerAmount,
        });
        print("Generated transfer offer for ${player.name} from $offeringClubName for $offerAmount");
        // --- Add Transfer Offer News ---
        _addNewsItem(NewsItem.create(
          title: "Transfer Offer Received",
          description: "$offeringClubName has made an offer of \$$offerAmount for ${player.name}.",
          type: NewsItemType.TransferOffer,
          date: _currentDate,
        ));
        // --- End Transfer Offer News ---
      }
    }
  }

  void acceptTransferOffer(Map<String, dynamic> offer) {
    String playerId = offer['playerId'];
    int offerAmount = offer['offerAmount'];
    Player? player = _academyPlayers.firstWhereOrNull((p) => p.id == playerId);

    if (player != null) {
      unassignPlayerFromAnyCoach(playerId); // Unassign first
      _balance += offerAmount;
      _academyPlayers.removeWhere((p) => p.id == playerId); // Remove player
      _transferOffers.removeWhere((o) => o['playerId'] == playerId);
      _calculateWeeklyWages();
      print("Accepted transfer offer for ${player.name}. Received $offerAmount. Balance: $_balance");
      // --- Add Transfer Decision News ---
      _addNewsItem(NewsItem.create(
        title: "Transfer Accepted",
        description: "We accepted the offer of \$$offerAmount for ${player.name} from ${offer['offeringClubName']}.",
        type: NewsItemType.TransferDecision,
        date: _currentDate,
      ));
      // --- End Transfer Decision News ---
      notifyListeners();
    }
  }

  void rejectTransferOffer(Map<String, dynamic> offer) {
     _transferOffers.removeWhere((o) => o['playerId'] == offer['playerId']);
     print("Rejected transfer offer for ${offer['playerName']}");
     notifyListeners();
  }
  // --- End Transfer Offer Logic ---

  // --- Facility Upgrade Logic ---
  int _calculateFacilityUpgradeCost(int currentLevel) {
    return (pow(currentLevel, 1.5) * 5000).toInt() + 10000;
  }
  int getTrainingFacilityUpgradeCost() => _calculateFacilityUpgradeCost(_trainingFacilityLevel);
  int getScoutingFacilityUpgradeCost() => _calculateFacilityUpgradeCost(_scoutingFacilityLevel);

  bool upgradeTrainingFacility() {
    int cost = getTrainingFacilityUpgradeCost();
    if (_balance >= cost) {
      _balance -= cost;
      _trainingFacilityLevel++;
      print("Upgraded Training Facility to Level $_trainingFacilityLevel. Cost: $cost. Balance: $_balance");
      // --- Add Facility News ---
      _addNewsItem(NewsItem.create(
        title: "Facility Upgraded",
        description: "Training Facility upgraded to Level $_trainingFacilityLevel.",
        type: NewsItemType.Facility,
        date: _currentDate,
      ));
      // --- End Facility News ---
      notifyListeners();
      return true;
    } else {
      print("Cannot upgrade Training Facility. Cost: $cost, Balance: $_balance");
      return false;
    }
  }

  bool upgradeScoutingFacility() {
    int cost = getScoutingFacilityUpgradeCost();
    if (_balance >= cost) {
      _balance -= cost;
      _scoutingFacilityLevel++;
      print("Upgraded Scouting Facility to Level $_scoutingFacilityLevel. Cost: $cost. Balance: $_balance");
      notifyListeners();
      return true;
    } else {
      print("Cannot upgrade Scouting Facility. Cost: $cost, Balance: $_balance");
      return false;
    }
  }
  // --- End Facility Upgrade Logic ---

  // --- News Item Management ---

  void markAllNewsAsRead() {
    bool changed = false;
    for (var item in _newsItems) {
      if (!item.isRead) {
        item.isRead = true;
        changed = true;
      }
    }
    if (changed) {
      notifyListeners(); // Notify only if something actually changed
    }
  }

  // Optional: Method to mark a single item as read (if needed later)
  // void markNewsAsRead(String id) {
  //   final index = _newsItems.indexWhere((item) => item.id == id);
  //   if (index != -1 && !_newsItems[index].isRead) {
  //     _newsItems[index].isRead = true;
  //     notifyListeners();
  //   }
  // }

  void _addNewsItem(NewsItem item) {
    // Optional: Limit the number of news items stored
    // if (_newsItems.length >= 50) {
    //   _newsItems.removeAt(0); // Remove the oldest item
    // }
    _newsItems.add(item);
    // No need to notifyListeners here, as news generation happens within
    // other methods that already call notifyListeners (like advanceWeek).
    // If adding news outside advanceWeek, call notifyListeners() after _addNewsItem.
    print("News Added: ${item.title}");
  }
  // --- End News Item Management ---

  // --- Settings Management ---

  void setDifficulty(Difficulty newDifficulty) {
    if (_difficulty != newDifficulty) {
      print("Changing difficulty from $_difficulty to $newDifficulty");
      _difficulty = newDifficulty;
      // Re-apply settings that depend on difficulty (e.g., starting balance if resetting, AI skill modifier)
      // For now, we only adjust balance/income if the game were reset,
      // but AI skill will be affected immediately in the next match simulation.
      // If we wanted to change current income mid-game, we'd call _applyDifficultySettings here.
      // _applyDifficultySettings(); // Uncomment if income/balance should change immediately
      notifyListeners();
    }
  }

  void setThemeMode(ThemeMode newThemeMode) {
    if (_themeMode != newThemeMode) {
      print("Changing theme mode from $_themeMode to $newThemeMode");
      _themeMode = newThemeMode;
      notifyListeners();
    }
  }
  // --- End Settings Management ---
}
