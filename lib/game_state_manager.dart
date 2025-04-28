import 'package:flutter/foundation.dart'; // For ChangeNotifier and kIsWeb
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

// Imports for Save/Load
import 'dart:convert';
import 'serializable_game_state.dart'; // Import the wrapper class
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

// Conditional imports for non-web platforms using dart:io and path_provider
// When compiling for web (where dart.library.html exists), it uses the stubs.
import 'dart:io' if (dart.library.html) 'src/web_io_stub.dart'; // Use dart:io stub for web
import 'package:path_provider/path_provider.dart' if (dart.library.html) 'src/web_path_provider_stub.dart'; // Use path_provider stub for web

// --- Stubs for Web Compilation ---
// Create these files if they don't exist:

// lib/src/web_path_provider_stub.dart
/*
Future<Directory> getApplicationDocumentsDirectory() async {
  throw UnsupportedError("getApplicationDocumentsDirectory is not supported on web.");
}
class Directory {
  final String path;
  Directory(this.path);
}
*/

// lib/src/web_io_stub.dart
/*
class File {
  final String path;
  File(this.path);
  Future<bool> exists() async => false; // Assume file doesn't exist on web via this stub
  Future<String> readAsString() async => throw UnsupportedError("File reading not supported on web via this stub.");
  Future<File> writeAsString(String contents) async => throw UnsupportedError("File writing not supported on web via this stub.");
}
*/
// --- End Stubs ---


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
  List<Tournament> _completedTournaments = []; // Tournaments that have finished

  // AI Club Data (Centralized)
  final List<AIClub> _allAICLubs = List.generate(16, (index) => AIClub.placeholder(index));
  final Map<String, AIClub> _aiClubMap = {};

  // Facility State (Basic)
  int _trainingFacilityLevel = 1;
  int _scoutingFacilityLevel = 1;

  // --- Reputation ---
  int _academyReputation = 100;

  // --- Transfer Offers ---
  List<Map<String, dynamic>> _transferOffers = [];

  // --- News Feed ---
  List<NewsItem> _newsItems = [];

  // --- Settings ---
  Difficulty _difficulty = Difficulty.Normal;
  ThemeMode _themeMode = ThemeMode.system;

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
  List<Tournament> get completedTournaments => _completedTournaments;
  Map<String, AIClub> get aiClubMap => _aiClubMap;
  int get trainingFacilityLevel => _trainingFacilityLevel;
  int get scoutingFacilityLevel => _scoutingFacilityLevel;
  int get academyReputation => _academyReputation;
  List<Map<String, dynamic>> get transferOffers => _transferOffers;
  List<NewsItem> get newsItems => List.unmodifiable(_newsItems.reversed);
  Difficulty get difficulty => _difficulty;
  ThemeMode get themeMode => _themeMode;

  // --- Save File Name / Key ---
  static const String _saveFileName = 'academy_save.json'; // Used for non-web
  static const String _prefsSaveKey = 'gameState'; // Used for web

  GameStateManager() {
    _applyDifficultySettings();
    _generateInitialAvailableStaff();
    _populateAIClubMap();
    _calculateWeeklyWages();
  }

  // --- Helper for Save File Path (Non-Web Only) ---
  Future<String> _getSaveFilePath() async {
    // This check prevents calling the stub on web
    if (kIsWeb) {
      throw UnsupportedError("_getSaveFilePath is not supported on web.");
    }
    // The conditional import ensures the correct implementation is used.
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_saveFileName';
  }

  // --- Initialization & Reset ---
  // [Existing methods remain here: _generateInitialAvailableStaff, _populateAIClubMap, _applyDifficultySettings]
   void _generateInitialAvailableStaff() {
    _availableStaff = List.generate(5, (index) {
      StaffRole role = StaffRole.values[_random.nextInt(StaffRole.values.length)];
      if (index < 2 && role != StaffRole.Scout) {
        role = StaffRole.Scout;
      }
      return Staff.randomStaff('staff_${DateTime.now().millisecondsSinceEpoch}_$index', role);
    });
  }

  void _populateAIClubMap() {
    _aiClubMap.clear();
    for (var club in _allAICLubs) {
      _aiClubMap[club.id] = club;
    }
    print("Populated AI Club Map with ${_aiClubMap.length} clubs.");
  }

  void _applyDifficultySettings() {
     switch (_difficulty) {
       case Difficulty.Easy:
         _balance = 75000.0; _weeklyIncome = 1200; break;
       case Difficulty.Normal:
         _balance = 50000.0; _weeklyIncome = 1000; break;
       case Difficulty.Hard:
         _balance = 30000.0; _weeklyIncome = 800; break;
     }
  }

  void resetGame() {
    print("--- RESETTING GAME STATE ---");
    _currentDate = DateTime(2025, 7, 1);
    _difficulty = Difficulty.Normal;
    _themeMode = ThemeMode.system;
    _academyPlayers.clear();
    _hiredStaff.clear();
    _scoutedPlayers.clear();
    _availableStaff.clear();
    _applyDifficultySettings();
    _totalWeeklyWages = 0;
    _activeTournaments.clear();
    _completedTournaments.clear();
    _aiClubMap.clear();
    _populateAIClubMap();
    _trainingFacilityLevel = 1;
    _scoutingFacilityLevel = 1;
    _academyReputation = 100;
    _transferOffers.clear();
    _newsItems.clear();
    _generateInitialAvailableStaff();
    _calculateWeeklyWages();

    // Also clear web save data on reset
    if (kIsWeb) {
      _clearWebSaveData();
    }

    notifyListeners();
    print("--- GAME STATE RESET COMPLETE ---");
  }

  // Helper to clear web save data
  Future<void> _clearWebSaveData() async {
    // No need for kIsWeb check here as SharedPreferences works on all platforms
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsSaveKey);
      print("--- Cleared web save data ---");
    } catch (e) {
      print("--- Error clearing web save data: $e ---");
    }
  }

  // --- Weekly Update Logic ---
  // [Existing methods remain here: advanceWeek, _simulateMatchesForWeek, etc.]
  void advanceWeek() {
    _currentDate = _currentDate.add(const Duration(days: 7));
    print("Advancing week to: $_currentDate");

    _balance += _weeklyIncome;
    _balance -= _totalWeeklyWages;

    _scoutedPlayers.clear();
    int totalScoutingSkill = _hiredStaff
        .where((s) => s.role == StaffRole.Scout)
        .fold(0, (sum, scout) => sum + scout.skill);
    int playersToFind = (totalScoutingSkill / 50).ceil() + _random.nextInt(2);
    if (_hiredStaff.where((s) => s.role == StaffRole.Scout).isEmpty) {
      playersToFind = 0;
    }
    print("Scouting found $playersToFind players this week.");
    for (int i = 0; i < playersToFind; i++) {
      _scoutedPlayers.add(Player.randomScoutedPlayer('scouted_${_currentDate.millisecondsSinceEpoch}_$i'));
    }
    if (playersToFind > 0) {
       _addNewsItem(NewsItem.create(title: "Scouting Report", description: "Our scouts have identified $playersToFind potential new players this week.", type: NewsItemType.Scouting, date: _currentDate));
    } else if (_hiredStaff.any((s) => s.role == StaffRole.Scout)) {
       _addNewsItem(NewsItem.create(title: "Scouting Report", description: "Scouts found no notable players this week.", type: NewsItemType.Scouting, date: _currentDate));
    }

    _simulateMatchesForWeek();
    _handlePlayerTraining();
    _updateReputationDecay();
    _generateTransferOffers();
    _refreshAvailableStaff();

    notifyListeners();
  }

  // --- State Modification Methods ---
  // [Existing methods remain here: _calculateWeeklyWages, hireStaff, signPlayer, etc.]
  void _calculateWeeklyWages() {
    int staffWages = _hiredStaff.fold(0, (sum, staff) => sum + staff.weeklyWage);
    int playerWages = _academyPlayers.fold(0, (sum, player) => sum + player.weeklyWage);
    _totalWeeklyWages = staffWages + playerWages;
    print("Calculated weekly wages: $_totalWeeklyWages");
  }

  void hireStaff(Staff staffToHire) {
    _hiredStaff.add(staffToHire);
    _availableStaff.removeWhere((s) => s.id == staffToHire.id);
    _calculateWeeklyWages();
    _addNewsItem(NewsItem.create(title: "Staff Hired", description: "We have hired ${staffToHire.name} as our new ${staffToHire.role.toString().split('.').last}.", type: NewsItemType.StaffChange, date: _currentDate));
    notifyListeners();
    print("Hired ${staffToHire.name}");
  }

  void signPlayer(Player playerToSign) {
    playerToSign.isScouted = false;
    _academyPlayers.add(playerToSign);
    _scoutedPlayers.removeWhere((p) => p.id == playerToSign.id);
    _calculateWeeklyWages();
    _addNewsItem(NewsItem.create(title: "Player Signed", description: "We have signed the promising young player ${playerToSign.name} to the academy.", type: NewsItemType.PlayerSigned, date: _currentDate));
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

  void _simulateMatchesForWeek() {
    DateTime startOfWeek = _currentDate.subtract(const Duration(days: 7));
    DateTime endOfWeek = _currentDate;
    print("Simulating matches between $startOfWeek and $endOfWeek");
    List<Tournament> completedTournamentsThisWeek = [];

    for (var tournament in _activeTournaments) {
      if (tournament.status == TournamentStatus.InProgress) {
        bool tournamentMatchesRemaining = false;
        for (var match in tournament.matches) {
          if (!match.isSimulated && !match.matchDate.isBefore(startOfWeek) && match.matchDate.isBefore(endOfWeek)) {
            print("Preparing detailed simulation for match: ${match.id} scheduled for ${match.matchDate}");
            TournamentType tournamentType = tournament.type;
            List<Player> homeLineup; List<Player> awayLineup;
            const String playerAcademyId = 'player_academy_1';

            if (match.homeTeamId == playerAcademyId) { homeLineup = selectPlayerTeamForMatch(tournamentType); }
            else { AIClub? homeAIClub = _aiClubMap[match.homeTeamId]; homeLineup = (homeAIClub != null) ? selectAITeamForMatch(tournamentType, homeAIClub) : []; if (homeAIClub == null) print("Error: Home AI Club ${match.homeTeamId} not found for match ${match.id}. Using empty lineup."); }

            if (match.awayTeamId == playerAcademyId) { awayLineup = selectPlayerTeamForMatch(tournamentType); }
            else { AIClub? awayAIClub = _aiClubMap[match.awayTeamId]; awayLineup = (awayAIClub != null) ? selectAITeamForMatch(tournamentType, awayAIClub) : []; if (awayAIClub == null) print("Error: Away AI Club ${match.awayTeamId} not found for match ${match.id}. Using empty lineup."); }

            match.simulateDetailed(homeLineup, awayLineup);
            _updatePlayerStatsAndFatigue(match, homeLineup, awayLineup);
            _updateReputationAfterMatch(tournament, match);

            if (match.isSimulated && match.result != null) {
              String homeTeamName = match.homeTeamId == playerAcademyId ? "Academy" : (_aiClubMap[match.homeTeamId]?.name ?? match.homeTeamId);
              String awayTeamName = match.awayTeamId == playerAcademyId ? "Academy" : (_aiClubMap[match.awayTeamId]?.name ?? match.awayTeamId);
              String resultString;
              switch (match.result!) { case MatchResult.homeWin: resultString = "won against"; break; case MatchResult.awayWin: resultString = "lost to"; break; case MatchResult.draw: resultString = "drew with"; break; }
              if (match.awayTeamId == playerAcademyId) { switch (match.result!) { case MatchResult.homeWin: resultString = "lost to"; break; case MatchResult.awayWin: resultString = "won against"; break; case MatchResult.draw: resultString = "drew with"; break; } }
              String score = "${match.homeScore} - ${match.awayScore}";
              String opponentName = match.homeTeamId == playerAcademyId ? awayTeamName : homeTeamName;
              _addNewsItem(NewsItem.create(title: "Match Result (${tournament.name})", description: "Academy $resultString $opponentName $score.", type: NewsItemType.MatchResult, date: match.matchDate));
            }
          }
          if (!match.isSimulated) { tournamentMatchesRemaining = true; }
        }
        if (!tournamentMatchesRemaining) {
          print("Tournament ${tournament.name} completed.");
          tournament.status = TournamentStatus.Completed;
          completedTournamentsThisWeek.add(tournament);
        }
      }
    }
    if (completedTournamentsThisWeek.isNotEmpty) {
      _completedTournaments.addAll(completedTournamentsThisWeek);
      _activeTournaments.removeWhere((t) => completedTournamentsThisWeek.contains(t));
      print("Moved ${completedTournamentsThisWeek.length} tournaments to history.");
    }
    _applyWeeklyFatigueRecovery();
  }

  void _updatePlayerStatsAndFatigue(Match match, List<Player> homeLineup, List<Player> awayLineup) {
    if (!match.isSimulated) return;
    Set<String> academyPlayersInMatch = {};
    List<Player> allPlayersInMatch = [...homeLineup, ...awayLineup];
     for (var lineupPlayer in allPlayersInMatch) {
       Player? academyPlayer = _academyPlayers.firstWhereOrNull((p) => p.id == lineupPlayer.id);
       if (academyPlayer != null) {
         academyPlayersInMatch.add(academyPlayer.id);
         academyPlayer.matchesPlayed++;
         double fatigueIncrease = 15.0 + ( (100 - academyPlayer.stamina) / 10.0 );
         academyPlayer.fatigue = (academyPlayer.fatigue + fatigueIncrease).clamp(0.0, 100.0);
         print("Player ${academyPlayer.name} played match ${match.id}. Matches: ${academyPlayer.matchesPlayed}, Fatigue: ${academyPlayer.fatigue.toStringAsFixed(1)}%");
       }
    }
    for (var event in match.eventLog) {
       Player? academyPlayer = _academyPlayers.firstWhereOrNull((p) => p.id == event.playerId);
       if (academyPlayer != null) {
         if (event.type == MatchEventType.Goal) { academyPlayer.goalsScored++; print("Player ${academyPlayer.name} scored! Total goals: ${academyPlayer.goalsScored}"); }
         else if (event.type == MatchEventType.Assist) { academyPlayer.assists++; print("Player ${academyPlayer.name} assisted! Total assists: ${academyPlayer.assists}"); }
       }
    }
  }

  void _applyWeeklyFatigueRecovery() {
     print("--- Applying Weekly Fatigue Recovery ---");
     for (var player in _academyPlayers) {
        double recoveryAmount = 5.0 + (player.stamina / 10.0);
        player.fatigue = (player.fatigue - recoveryAmount).clamp(0.0, 100.0);
     }
  }

  void _handlePlayerTraining() {
    print("--- Handling Player Training ---");
    bool anyPlayerImproved = false;
    Map<String, Player> playerMap = { for (var p in _academyPlayers) p.id : p };
    final coaches = _hiredStaff.where((s) => s.role == StaffRole.Coach).toList();
    if (coaches.isEmpty) { print("No coaches hired. No specific player training applied this week."); return; }
    Set<String> trainedPlayerIds = {};
    for (var coach in coaches) {
      print("Coach ${coach.name} (Skill: ${coach.skill}, Capacity: ${coach.assignedPlayerIds.length}/${coach.maxPlayersTrainable}) is training...");
      for (var playerId in coach.assignedPlayerIds) {
        if (playerMap.containsKey(playerId) && !trainedPlayerIds.contains(playerId)) {
          Player player = playerMap[playerId]!;
          trainedPlayerIds.add(playerId);
          if (player.currentSkill < player.potentialSkill) {
            int baseChance = 5; int coachBonus = (coach.skill / 5).floor(); int facilityBonus = (_trainingFacilityLevel * 3); int difficultyModifier = 0;
            switch (_difficulty) { case Difficulty.Easy: difficultyModifier = 5; break; case Difficulty.Normal: difficultyModifier = 0; break; case Difficulty.Hard: difficultyModifier = -5; break; }
            int totalChance = (baseChance + coachBonus + facilityBonus + difficultyModifier).clamp(1, 99);
            if (_random.nextInt(100) < totalChance) {
              int oldSkill = player.currentSkill; player.currentSkill++;
              print("  -> Player ${player.name} (under ${coach.name}) improved skill to ${player.currentSkill}. Chance: $totalChance%");
              anyPlayerImproved = true;
              _addNewsItem(NewsItem.create(title: "Player Improved", description: "${player.name} improved their skill from $oldSkill to ${player.currentSkill} under Coach ${coach.name}.", type: NewsItemType.Training, date: _currentDate));
            }
          }
        } else if (!playerMap.containsKey(playerId)) { print("  -> Warning: Player ID $playerId assigned to coach ${coach.name} not found in academy players."); }
      }
    }
    int unassignedCount = _academyPlayers.where((p) => !trainedPlayerIds.contains(p.id)).length;
     if (unassignedCount > 0) { print("$unassignedCount players were not assigned to any coach this week."); }
    if (!anyPlayerImproved && coaches.isNotEmpty) { print("No players improved under coaching this week."); }
  }

  void _refreshAvailableStaff() {
    int removedCount = 0;
    _availableStaff.removeWhere((staff) { bool leaving = _random.nextDouble() < 0.20; if (leaving) removedCount++; return leaving; });
    int newStaffCount = 1 + _random.nextInt(3); int addedCount = 0;
    for (int i = 0; i < newStaffCount; i++) {
      StaffRole role = StaffRole.values[_random.nextInt(StaffRole.values.length)];
      if ((role == StaffRole.Physio || role == StaffRole.Manager) && _random.nextBool()) { role = StaffRole.values[_random.nextInt(StaffRole.values.length)]; }
      if (_availableStaff.length < 15) { Staff newStaff = Staff.randomStaff('staff_${_currentDate.millisecondsSinceEpoch}_$i', role); _availableStaff.add(newStaff); addedCount++; }
    }
    print("Staff Market Refreshed: $removedCount removed, $addedCount added. Total available: ${_availableStaff.length}");
  }

  bool assignPlayerToCoach(String playerId, String coachId) {
    Staff? coach = _hiredStaff.firstWhereOrNull((s) => s.id == coachId && s.role == StaffRole.Coach);
    if (coach == null) { print("Error: Coach with ID $coachId not found or is not a coach."); return false; }
    Player? player = _academyPlayers.firstWhereOrNull((p) => p.id == playerId);
    if (player == null) { print("Error: Player with ID $playerId not found in academy."); return false; }
    if (coach.assignedPlayerIds.length >= coach.maxPlayersTrainable) { print("Error: Coach ${coach.name} is already at maximum capacity (${coach.maxPlayersTrainable}). Cannot assign ${player.name}."); return false; }
    if (coach.assignedPlayerIds.contains(playerId)) { print("Info: Player ${player.name} is already assigned to coach ${coach.name}."); return true; }
    unassignPlayerFromAnyCoach(playerId); coach.assignedPlayerIds.add(playerId);
    print("Assigned player ${player.name} to coach ${coach.name}."); notifyListeners(); return true;
  }

  bool unassignPlayerFromCoach(String playerId, String coachId) {
    Staff? coach = _hiredStaff.firstWhereOrNull((s) => s.id == coachId && s.role == StaffRole.Coach);
    if (coach == null) { print("Error: Coach with ID $coachId not found or is not a coach."); return false; }
    Player? player = _academyPlayers.firstWhereOrNull((p) => p.id == playerId); String playerName = player?.name ?? 'ID: $playerId';
    bool removed = coach.assignedPlayerIds.remove(playerId);
    if (removed) { print("Unassigned player $playerName from coach ${coach.name}."); notifyListeners(); }
    else { print("Info: Player $playerName was not assigned to coach ${coach.name}."); }
    return removed;
  }

  void unassignPlayerFromAnyCoach(String playerId) {
    for (var coach in _hiredStaff.where((s) => s.role == StaffRole.Coach)) { if (coach.assignedPlayerIds.contains(playerId)) { unassignPlayerFromCoach(playerId, coach.id); break; } }
  }

  Staff? getCoachForPlayer(String playerId) { return _hiredStaff.firstWhereOrNull((s) => s.role == StaffRole.Coach && s.assignedPlayerIds.contains(playerId)); }

  int _getTeamSkill(String teamId, List<Player> selectedLineup) {
    const String playerAcademyId = 'player_academy_1';
    if (selectedLineup.isEmpty) { return 10; }
    double totalEffectiveSkill = 0;
    for (var player in selectedLineup) { double fatigueModifier = 1.0 - (player.fatigue / 200.0); totalEffectiveSkill += player.currentSkill * fatigueModifier; }
    int averageEffectiveSkill = (totalEffectiveSkill / selectedLineup.length).round();
    if (teamId != playerAcademyId) { int baseAISkill = _getBaseAIClubSkill(teamId); averageEffectiveSkill = ((averageEffectiveSkill * 0.7) + (baseAISkill * 0.3)).round(); }
    return averageEffectiveSkill.clamp(1, 100);
  }

  int _getBaseAIClubSkill(String teamId) {
     final aiClub = _aiClubMap[teamId];
     if (aiClub != null) {
       int baseSkill = aiClub.skillLevel;
       switch (_difficulty) { case Difficulty.Easy: baseSkill = (baseSkill * 0.85).round().clamp(1, 100); break; case Difficulty.Normal: break; case Difficulty.Hard: baseSkill = (baseSkill * 1.15).round().clamp(1, 100); break; }
       return baseSkill;
     } else { print("Warning: AI Club with ID '$teamId' not found in _aiClubMap. Returning default skill."); return 30; }
  }

  List<Player> selectPlayerTeamForMatch(TournamentType type, {Staff? manager}) {
    int playersNeeded = _getPlayersNeededForType(type);
    if (_academyPlayers.length < playersNeeded) { print("Warning: Not enough players in academy (${_academyPlayers.length}) for a ${type.toString()} match (needs $playersNeeded). Selecting all available."); return List<Player>.from(_academyPlayers); }
    List<Player> availablePlayers = List<Player>.from(_academyPlayers);
    availablePlayers.sort((a, b) { double fatiguePenaltyA = a.fatigue > 75 ? 50 : (a.fatigue / 2); double fatiguePenaltyB = b.fatigue > 75 ? 50 : (b.fatigue / 2); double effectiveScoreA = a.currentSkill - fatiguePenaltyA; double effectiveScoreB = b.currentSkill - fatiguePenaltyB; return effectiveScoreB.compareTo(effectiveScoreA); });
    return availablePlayers.sublist(0, playersNeeded);
  }

  List<Player> selectAITeamForMatch(TournamentType type, AIClub aiClub) {
     int playersNeeded = _getPlayersNeededForType(type);
     if (aiClub.players.length < playersNeeded) { print("Warning: Not enough players in AI club ${aiClub.name} (${aiClub.players.length}) for a ${type.toString()} match (needs $playersNeeded). Selecting all available."); return List<Player>.from(aiClub.players); }
     List<Player> availablePlayers = List<Player>.from(aiClub.players);
     availablePlayers.sort((a, b) { double fatiguePenaltyA = a.fatigue > 75 ? 50 : (a.fatigue / 2); double fatiguePenaltyB = b.fatigue > 75 ? 50 : (b.fatigue / 2); double effectiveScoreA = a.currentSkill - fatiguePenaltyA; double effectiveScoreB = b.currentSkill - fatiguePenaltyB; return effectiveScoreB.compareTo(effectiveScoreA); });
     return availablePlayers.sublist(0, playersNeeded);
  }

  int _getPlayersNeededForType(TournamentType type) { switch (type) { case TournamentType.threeVthree: return 3; case TournamentType.fiveVfive: return 5; case TournamentType.sevenVseven: return 7; case TournamentType.elevenVeleven: return 11; default: return 11; } }

  void _updateReputationAfterMatch(Tournament tournament, Match match) {
    if (!match.isSimulated || match.result == null) return;
    const String playerAcademyId = 'player_academy_1';
    bool playerInvolved = match.homeTeamId == playerAcademyId || match.awayTeamId == playerAcademyId;
    int reputationChange = 0; int playerReputationChangeBase = 0;
    if (playerInvolved) {
      bool playerWon = (match.homeTeamId == playerAcademyId && match.result == MatchResult.homeWin) || (match.awayTeamId == playerAcademyId && match.result == MatchResult.awayWin);
      bool playerDrew = match.result == MatchResult.draw;
      if (playerWon) { reputationChange = 5; playerReputationChangeBase = 3; } else if (playerDrew) { reputationChange = 1; playerReputationChangeBase = 1; } else { reputationChange = -3; playerReputationChangeBase = -1; }
      _academyReputation = max(0, _academyReputation + reputationChange); print("Academy reputation changed by $reputationChange to $_academyReputation after match ${match.id}");
    }
    Set<String> participatingPlayerIds = {};
    if (match.homeTeamId == playerAcademyId) { participatingPlayerIds.addAll(match.homeLineup); }
    if (match.awayTeamId == playerAcademyId) { participatingPlayerIds.addAll(match.awayLineup); }
    for (String playerId in participatingPlayerIds) {
        Player? player = _academyPlayers.firstWhereOrNull((p) => p.id == playerId); if (player == null) continue;
        int individualChange = playerReputationChangeBase; int goals = 0; int assists = 0;
        for (var event in match.eventLog) { if (event.playerId == player.id) { if (event.type == MatchEventType.Goal) goals++; if (event.type == MatchEventType.Assist) assists++; } }
        individualChange += goals * 5; individualChange += assists * 3;
        if (individualChange != 0) { player.reputation = max(0, player.reputation + individualChange); print("Player ${player.name} reputation changed by $individualChange to ${player.reputation}"); }
    }
  }

  void _updateReputationDecay() {
    _academyReputation = max(0, _academyReputation - 1);
    for (var player in _academyPlayers) { player.reputation = max(0, player.reputation - 1); }
     print("Applied weekly reputation decay. Academy: $_academyReputation");
  }

  void _generateTransferOffers() {
    _transferOffers.clear(); final random = Random();
    for (var player in _academyPlayers) {
      double offerChance = ((player.reputation / 500.0) + (_academyReputation / 1000.0)).clamp(0.0, 0.2);
      if (random.nextDouble() < offerChance) {
        String offeringClubName = _allAICLubs[random.nextInt(_allAICLubs.length)].name;
        int offerAmount = (player.currentSkill * 100) + (player.reputation * 50) + random.nextInt(5000);
        _transferOffers.add({ 'playerId': player.id, 'playerName': player.name, 'offeringClubName': offeringClubName, 'offerAmount': offerAmount, });
        print("Generated transfer offer for ${player.name} from $offeringClubName for $offerAmount");
        _addNewsItem(NewsItem.create(title: "Transfer Offer Received", description: "$offeringClubName has made an offer of \$$offerAmount for ${player.name}.", type: NewsItemType.TransferOffer, date: _currentDate));
      }
    }
  }

  void acceptTransferOffer(Map<String, dynamic> offer) {
    String playerId = offer['playerId']; int offerAmount = offer['offerAmount'];
    Player? player = _academyPlayers.firstWhereOrNull((p) => p.id == playerId);
    if (player != null) {
      unassignPlayerFromAnyCoach(playerId); _balance += offerAmount;
      _academyPlayers.removeWhere((p) => p.id == playerId);
      _transferOffers.removeWhere((o) => o['playerId'] == playerId);
      _calculateWeeklyWages();
      print("Accepted transfer offer for ${player.name}. Received $offerAmount. Balance: $_balance");
      _addNewsItem(NewsItem.create(title: "Transfer Accepted", description: "We accepted the offer of \$$offerAmount for ${player.name} from ${offer['offeringClubName']}.", type: NewsItemType.TransferDecision, date: _currentDate));
      notifyListeners();
    }
  }

  void rejectTransferOffer(Map<String, dynamic> offer) {
     _transferOffers.removeWhere((o) => o['playerId'] == offer['playerId']);
     print("Rejected transfer offer for ${offer['playerName']}"); notifyListeners();
  }

  int _calculateFacilityUpgradeCost(int currentLevel) { return (pow(currentLevel, 1.5) * 5000).toInt() + 10000; }
  int getTrainingFacilityUpgradeCost() => _calculateFacilityUpgradeCost(_trainingFacilityLevel);
  int getScoutingFacilityUpgradeCost() => _calculateFacilityUpgradeCost(_scoutingFacilityLevel);

  bool upgradeTrainingFacility() {
    int cost = getTrainingFacilityUpgradeCost();
    if (_balance >= cost) {
      _balance -= cost; _trainingFacilityLevel++;
      print("Upgraded Training Facility to Level $_trainingFacilityLevel. Cost: $cost. Balance: $_balance");
      _addNewsItem(NewsItem.create(title: "Facility Upgraded", description: "Training Facility upgraded to Level $_trainingFacilityLevel.", type: NewsItemType.Facility, date: _currentDate));
      notifyListeners(); return true;
    } else { print("Cannot upgrade Training Facility. Cost: $cost, Balance: $_balance"); return false; }
  }

  bool upgradeScoutingFacility() {
    int cost = getScoutingFacilityUpgradeCost();
    if (_balance >= cost) {
      _balance -= cost; _scoutingFacilityLevel++;
      print("Upgraded Scouting Facility to Level $_scoutingFacilityLevel. Cost: $cost. Balance: $_balance");
       _addNewsItem(NewsItem.create( // Added missing news item
        title: "Facility Upgraded",
        description: "Scouting Facility upgraded to Level $_scoutingFacilityLevel.",
        type: NewsItemType.Facility,
        date: _currentDate,
      ));
      notifyListeners(); return true;
    } else { print("Cannot upgrade Scouting Facility. Cost: $cost, Balance: $_balance"); return false; }
  }

  void markAllNewsAsRead() {
    bool changed = false;
    for (var item in _newsItems) { if (!item.isRead) { item.isRead = true; changed = true; } }
    if (changed) { notifyListeners(); }
  }

  void _addNewsItem(NewsItem item) {
    _newsItems.add(item); print("News Added: ${item.title}");
  }

  void setDifficulty(Difficulty newDifficulty) {
    if (_difficulty != newDifficulty) {
      print("Changing difficulty from $_difficulty to $newDifficulty");
      _difficulty = newDifficulty; notifyListeners();
    }
  }

  void setThemeMode(ThemeMode newThemeMode) {
    if (_themeMode != newThemeMode) {
      print("Changing theme mode from $_themeMode to $newThemeMode");
      _themeMode = newThemeMode; notifyListeners();
    }
  }

  // --- Save/Load Logic ---
  Future<bool> saveGame() async {
    try {
      print("--- SAVING GAME STATE ---");

      // Create the serializable state object
      final gameStateToSave = SerializableGameState(
        currentDate: _currentDate,
        academyPlayers: _academyPlayers,
        hiredStaff: _hiredStaff,
        balance: _balance,
        weeklyIncome: _weeklyIncome,
        totalWeeklyWages: _totalWeeklyWages,
        activeTournaments: _activeTournaments,
        completedTournaments: _completedTournaments,
        trainingFacilityLevel: _trainingFacilityLevel,
        scoutingFacilityLevel: _scoutingFacilityLevel,
        academyReputation: _academyReputation,
        newsItems: _newsItems,
        difficulty: _difficulty,
        themeMode: _themeMode,
      );
      final jsonMap = gameStateToSave.toJson();
      final jsonString = jsonEncode(jsonMap);

      if (kIsWeb) {
        // --- Web Save Logic ---
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefsSaveKey, jsonString);
        print("--- GAME STATE SAVED successfully (Web) ---");
      } else {
        // --- Non-Web Save Logic ---
        final filePath = await _getSaveFilePath();
        // Use dart:io's File for non-web (via conditional import)
        final file = File(filePath);
        await file.writeAsString(jsonString);
        print("--- GAME STATE SAVED successfully to $filePath (Non-Web) ---");
      }
      return true;

    } catch (e) {
      print("--- ERROR SAVING GAME STATE: $e ---");
      // Specific error handling for web if needed
      if (kIsWeb && e is UnsupportedError) {
         print("--- NOTE: File system operations are not supported on web. Using SharedPreferences. ---");
      }
      return false;
    }
  }

  Future<bool> loadGame() async {
    try {
      print("--- LOADING GAME STATE ---");
      String? jsonString;

      if (kIsWeb) {
        // --- Web Load Logic ---
        final prefs = await SharedPreferences.getInstance();
        jsonString = prefs.getString(_prefsSaveKey);
        if (jsonString == null || jsonString.isEmpty) {
          print("--- No save data found (Web) ---");
          return false;
        }
         print("--- Found save data (Web) ---");
      } else {
        // --- Non-Web Load Logic ---
        final filePath = await _getSaveFilePath();
        // Use dart:io's File for non-web (via conditional import)
        final file = File(filePath);
        // Check existence using the potentially stubbed File class
        bool fileExists = await file.exists();
        if (!fileExists) {
          print("--- No save file found at $filePath (Non-Web) ---");
          return false;
        }
        jsonString = await file.readAsString();
         print("--- Found save data at $filePath (Non-Web) ---");
      }

      // --- Common Load Logic ---
      // Ensure jsonString is not null before decoding
      if (jsonString == null) {
         print("--- ERROR: jsonString is null after platform check ---");
         return false;
      }
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final loadedState = SerializableGameState.fromJson(jsonMap);

      // Apply loaded state
      _currentDate = loadedState.currentDate;
      _academyPlayers = loadedState.academyPlayers;
      _hiredStaff = loadedState.hiredStaff;
      _balance = loadedState.balance;
      _weeklyIncome = loadedState.weeklyIncome;
      _totalWeeklyWages = loadedState.totalWeeklyWages;
      _activeTournaments = loadedState.activeTournaments;
      _completedTournaments = loadedState.completedTournaments;
      _trainingFacilityLevel = loadedState.trainingFacilityLevel;
      _scoutingFacilityLevel = loadedState.scoutingFacilityLevel;
      _academyReputation = loadedState.academyReputation;
      _newsItems = loadedState.newsItems;
      _difficulty = loadedState.difficulty;
      _themeMode = loadedState.themeMode;

      // Regenerate/reset transient state
      _scoutedPlayers.clear();
      _transferOffers.clear();
      _generateInitialAvailableStaff();
      _populateAIClubMap();
      // _calculateWeeklyWages(); // Recalculate wages based on loaded players/staff

      print("--- GAME STATE LOADED successfully ---");
      notifyListeners(); // Update UI with loaded state
      return true;

    } catch (e) {
      print("--- ERROR LOADING GAME STATE: $e ---");
       // Specific error handling for web if needed
      if (kIsWeb && e is UnsupportedError) {
         print("--- NOTE: File system operations are not supported on web. Using SharedPreferences. ---");
      }
      // Optionally reset to default state on load error?
      // resetGame();
      return false;
    }
  }
  // --- End Save/Load Logic ---
}
