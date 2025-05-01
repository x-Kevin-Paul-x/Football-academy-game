import 'package:flutter/foundation.dart'; // For ChangeNotifier and kIsWeb
import 'models/tournament.dart';
import 'models/match.dart';
import 'models/player.dart'; // Import Player model
import 'models/staff.dart'; // Import Staff model
import 'models/rival_academy.dart'; // Correct Import Path
import 'models/match_event.dart'; // Import MatchEventType
import 'models/news_item.dart';
import 'models/difficulty.dart'; // Import Difficulty enum
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart'; // Import for ThemeMode
import 'package:intl/intl.dart'; // Import for number formatting

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
  Future<String> readAsString({Object? encoding}) async => throw UnsupportedError("Stub");
  Future<File> writeAsString(String contents, {Object? mode, Object? encoding, Object? flush}) async => throw UnsupportedError("Stub");
}
*/
// --- End Stubs ---

class GameStateManager with ChangeNotifier {
  // Core Game Time & State
  DateTime _currentDate = DateTime(2025, 7, 1); // Starting date of the game
  final Random _random = Random(); // Random number generator
  String _academyName = "My Academy";
  static const String playerAcademyId = 'player_academy_1'; // Unique ID for the player's academy

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
  List<Tournament> _activeTournaments = []; // Tournaments currently in progress (Scheduled or InProgress)
  List<Tournament> _completedTournaments = []; // Tournaments that have finished
  List<Tournament> _availableTournamentTemplates = []; // Templates for new tournaments

  // Rival Academy Data
  List<RivalAcademy> _rivalAcademies = []; // List of all rival academies
  Map<String, RivalAcademy> _rivalAcademyMap = {}; // Map for quick lookup by ID

  // Facility State (Basic)
  int _trainingFacilityLevel = 1;
  int _scoutingFacilityLevel = 1;
  int _medicalBayLevel = 1;

  // Staff Caps
  int _maxCoaches = 1;
  int _maxScouts = 1;
  int _maxPhysios = 1;
  // Manager cap is implicitly 1

  // Reputation
  int _academyReputation = 100;

  // Transfer Offers
  List<Map<String, dynamic>> _transferOffers = [];

  // News Feed
  List<NewsItem> _newsItems = [];

  // Settings
  Difficulty _difficulty = Difficulty.Normal;
  ThemeMode _themeMode = ThemeMode.system;

  // --- Getters ---
  DateTime get currentDate => _currentDate;
  String get academyName => _academyName;
  List<Player> get academyPlayers => List<Player>.unmodifiable(_academyPlayers);
  List<Staff> get hiredStaff => List<Staff>.unmodifiable(_hiredStaff);
  List<Player> get scoutedPlayers => List<Player>.unmodifiable(_scoutedPlayers);
  List<Staff> get availableStaff => List<Staff>.unmodifiable(_availableStaff);
  double get balance => _balance;
  int get weeklyIncome => _weeklyIncome;
  int get totalWeeklyWages => _totalWeeklyWages;
  List<Tournament> get activeTournaments => List<Tournament>.unmodifiable(_activeTournaments);
  List<Tournament> get completedTournaments => List<Tournament>.unmodifiable(_completedTournaments);
  List<Tournament> get availableTournamentTemplates => List<Tournament>.unmodifiable(_availableTournamentTemplates);
  // Rival Academy Getters
  List<RivalAcademy> get rivalAcademies => List<RivalAcademy>.unmodifiable(_rivalAcademies);
  Map<String, RivalAcademy> get rivalAcademyMap => Map<String, RivalAcademy>.unmodifiable(_rivalAcademyMap);
  int get trainingFacilityLevel => _trainingFacilityLevel;
  int get scoutingFacilityLevel => _scoutingFacilityLevel;
  int get medicalBayLevel => _medicalBayLevel;
  int get maxCoaches => _maxCoaches;
  int get maxScouts => _maxScouts;
  int get maxPhysios => _maxPhysios;
  int get academyReputation => _academyReputation;
  List<Map<String, dynamic>> get transferOffers => List<Map<String, dynamic>>.unmodifiable(_transferOffers);
  List<NewsItem> get newsItems => List<NewsItem>.unmodifiable(_newsItems.reversed);
  Difficulty get difficulty => _difficulty;
  ThemeMode get themeMode => _themeMode;

  // --- Save File Name / Key ---
  static const String _saveFileName = 'academy_save.json'; // Used for non-web
  static const String _prefsSaveKey = 'gameState'; // Used for web

  GameStateManager() {
    _applyDifficultySettings(); // Apply difficulty first
    _generateInitialAvailableStaff();
    _populateRivalAcademyMap(); // Populate rivals based on difficulty
    _generateInitialTournamentTemplates(); // Generate tournament templates
    _calculateWeeklyWages();
    _updateStaffCapsFromFacilities();
  }

  // --- Helper for Save File Path (Non-Web Only) ---
  Future<String> _getSaveFilePath() async {
    if (kIsWeb) {
      throw UnsupportedError("_getSaveFilePath is not supported on web.");
    }
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_saveFileName';
  }

  // --- Initialization & Reset ---
   void _generateInitialAvailableStaff() {
    _availableStaff = List<Staff>.generate(5, (index) { // Added <Staff> type argument
      StaffRole role = StaffRole.values[_random.nextInt(StaffRole.values.length)];
      // Ensure some initial variety if possible
      if (index == 0) role = StaffRole.Coach;
      if (index == 1) role = StaffRole.Scout;
      if (index == 2) role = StaffRole.Physio;
      // Ensure at least one coach and physio initially if possible (redundant check, but safe)
      // if (index == 2 && !_availableStaff.any((s) => s.role == StaffRole.Coach)) role = StaffRole.Coach;
      // if (index == 3 && !_availableStaff.any((s) => s.role == StaffRole.Physio)) role = StaffRole.Physio;
      return Staff.randomStaff('staff_${DateTime.now().millisecondsSinceEpoch}_$index', role);
    });
  }

  // Populate Rival Academies
  void _populateRivalAcademyMap() {
    _rivalAcademies.clear();
    _rivalAcademyMap.clear();
    int numberOfRivals = 15; // Default number
    if (_difficulty == Difficulty.Hardcore) {
      numberOfRivals = 23; // More rivals in Hardcore
    } else if (_difficulty == Difficulty.Hard) {
      numberOfRivals = 19;
    }

    _rivalAcademies = List<RivalAcademy>.generate(numberOfRivals, (index) => RivalAcademy.initial(index, difficulty: _difficulty)); // Added <RivalAcademy>

    // Generate initial players for each rival academy
    for (var academy in _rivalAcademies) {
      int initialPlayerCount = 5 + _random.nextInt(6); // 5-10 players initially
      for (int i = 0; i < initialPlayerCount; i++) {
        // Generate players with skill relative to academy skill level
        int potentialSkill = (academy.skillLevel * 1.5).toInt() + _random.nextInt(31); // Potential based on skill, range 30
        potentialSkill = potentialSkill.clamp(30, 95); // Clamp potential
        int currentSkill = (potentialSkill * (0.4 + _random.nextDouble() * 0.4)).toInt(); // 40-80% of potential
        currentSkill = currentSkill.clamp(15, potentialSkill); // Clamp current skill

        academy.players.add(
          Player(
            id: '${academy.id}_player_$i',
            name: 'Rival Player ${academy.id.split('_').last}-$i', // Simple generated name
            age: 15 + _random.nextInt(4),
            position: PlayerPosition.values[_random.nextInt(PlayerPosition.values.length)],
            currentSkill: currentSkill,
            potentialSkill: potentialSkill,
            weeklyWage: 50 + _random.nextInt(101), // Low wages
            reputation: academy.reputation ~/ 5 + _random.nextInt(10), // Reputation based on academy
            stamina: 40 + _random.nextInt(41), // 40-80 stamina
          )
        );
      }
      _rivalAcademyMap[academy.id] = academy;
    }
    print("Populated Rival Academy Map with ${_rivalAcademyMap.length} academies.");
  }

  // Generate Tournament Templates
  void _generateInitialTournamentTemplates() {
    _availableTournamentTemplates.clear();
    // Use the static factory method from Tournament

    // *** ADDED 3v3 Tournament ***
    _availableTournamentTemplates.add(Tournament.createTemplate(
      name: "Kickabout Cup (3v3)",
      type: TournamentType.threeVthree,
      format: TournamentFormat.Knockout, // Added format
      requiredReputation: 20, // Low requirement
      entryFee: 200,
      prizeMoneyBase: 1000,
      numberOfTeams: 8, // Smaller tournament
      // rounds: 3, // Knockout (calculated automatically)
      minTeamsToStart: 4, // Lower minimum to start
    ));

    _availableTournamentTemplates.add(Tournament.createTemplate(
      name: "Local Youth Cup (5v5)",
      type: TournamentType.fiveVfive,
      format: TournamentFormat.Knockout, // Added format
      requiredReputation: 50,
      entryFee: 500,
      prizeMoneyBase: 2000,
      numberOfTeams: 8,
      // rounds: 3, // Knockout (calculated automatically)
    ));
     _availableTournamentTemplates.add(Tournament.createTemplate(
      name: "Regional Junior Cup (7v7)", // Renamed slightly
      type: TournamentType.sevenVseven,
      format: TournamentFormat.Knockout, // Added format
      requiredReputation: 100,
      entryFee: 1000,
      prizeMoneyBase: 5000,
      numberOfTeams: 8,
      // rounds: 3, // Knockout (calculated automatically)
    ));
     _availableTournamentTemplates.add(Tournament.createTemplate(
      name: "National U18 Championship (11v11)",
      type: TournamentType.elevenVeleven,
      format: TournamentFormat.Knockout, // Added format
      requiredReputation: 200,
      entryFee: 2500,
      prizeMoneyBase: 15000,
      numberOfTeams: 16,
      // rounds: 4, // Knockout (calculated automatically)
    ));

    // --- NEW: Annual League Tournament ---
    _availableTournamentTemplates.add(Tournament.createTemplate(
      name: "Elite Youth League (11v11)",
      type: TournamentType.elevenVeleven,
      format: TournamentFormat.League, // LEAGUE format
      requiredReputation: 300, // High reputation requirement
      entryFee: 5000, // Higher entry fee
      prizeMoneyBase: 50000, // Significant prize money
      numberOfTeams: 10, // Fixed number of teams for the league
      minTeamsToStart: 10, // Must have exactly 10 teams
      // rounds: 0, // Ignored for league
    ));
    // --- END NEW ---

    print("Generated ${_availableTournamentTemplates.length} tournament templates.");
  }

  // Apply Difficulty Settings
  void _applyDifficultySettings() {
     // Reset to base values first
     _balance = 50000.0;
     _weeklyIncome = 1000;
     _academyReputation = 100; // Base reputation

     switch (_difficulty) {
       case Difficulty.Easy:
         _balance = 75000.0; _weeklyIncome = 1200; _academyReputation = 120; break;
       case Difficulty.Normal:
         _balance = 50000.0; _weeklyIncome = 1000; _academyReputation = 100; break;
       case Difficulty.Hard:
         _balance = 30000.0; _weeklyIncome = 800; _academyReputation = 80; break;
       case Difficulty.Hardcore: // Added Hardcore Case
         _balance = 10000.0; // Very low starting balance
         _weeklyIncome = 600; // Lower income
         _academyReputation = 50; // Very low starting reputation
         break;
     }
     print("Applied difficulty settings for $_difficulty: Balance=$_balance, Income=$_weeklyIncome, Reputation=$_academyReputation");
     // Note: Rival academies are populated *after* this in constructor/reset
  }

  // Reset Game
  void resetGame() {
    print("--- RESETTING GAME STATE ---");
    _currentDate = DateTime(2025, 7, 1);
    _academyName = "My Academy";
    // _difficulty = Difficulty.Normal; // Keep selected difficulty or reset? Let's keep it.
    _themeMode = ThemeMode.system;
    _academyPlayers.clear();
    _hiredStaff.clear();
    _scoutedPlayers.clear();
    _availableStaff.clear();
    _applyDifficultySettings(); // Apply difficulty settings (balance, income, rep)
    _totalWeeklyWages = 0;
    _activeTournaments.clear();
    _completedTournaments.clear();
    _availableTournamentTemplates.clear(); // Clear templates
    _rivalAcademyMap.clear(); // Clear rival map
    _rivalAcademies.clear(); // Clear rival list
    _populateRivalAcademyMap(); // Repopulate rivals based on current difficulty
    _generateInitialTournamentTemplates(); // Regenerate templates
    _trainingFacilityLevel = 1;
    _scoutingFacilityLevel = 1;
    _medicalBayLevel = 1;
    _updateStaffCapsFromFacilities();
    // _academyReputation is set in _applyDifficultySettings
    _transferOffers.clear();
    _newsItems.clear();
    _generateInitialAvailableStaff();
    _calculateWeeklyWages();

    if (kIsWeb) {
      _clearWebSaveData();
    }

    notifyListeners();
    print("--- GAME STATE RESET COMPLETE ---");
  }

  Future<void> _clearWebSaveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsSaveKey);
      print("--- Cleared web save data ---");
    } catch (e) {
      print("--- Error clearing web save data: $e ---");
    }
  }

  // --- Weekly Update Logic ---
  void advanceWeek() {
    _currentDate = _currentDate.add(const Duration(days: 7));
    print("Advancing week to: $_currentDate");

    // 0. Check for new Tournaments being scheduled (only in first week of month)
    if (_currentDate.day <= 7) {
      _checkForNewTournaments();
    }

    // 1. Update Finances (Player)
    double balanceBefore = _balance;
    _balance += _weeklyIncome;
    _balance -= _totalWeeklyWages;
    double weeklyNet = _balance - balanceBefore;

    // 2. Scouting Logic (Player)
    _scoutedPlayers.clear();
    int totalScoutingSkill = _hiredStaff
        .where((s) => s.role == StaffRole.Scout)
        .fold(0, (sum, scout) => sum + scout.skill);
    int playersToFind = 0;
    if (_hiredStaff.any((s) => s.role == StaffRole.Scout)) {
      playersToFind = (totalScoutingSkill / 50).ceil() + _random.nextInt(2);
    }
    // print("Scouting found $playersToFind players this week."); // Less verbose
    for (int i = 0; i < playersToFind; i++) {
      _scoutedPlayers.add(Player.randomScoutedPlayer('scouted_${_currentDate.millisecondsSinceEpoch}_$i'));
    }
    if (playersToFind > 0) {
       _addNewsItem(NewsItem.create(title: "Scouting Report", description: "Our scouts have identified $playersToFind potential new players this week.", type: NewsItemType.Scouting, date: _currentDate));
    } else if (_hiredStaff.any((s) => s.role == StaffRole.Scout)) {
       _addNewsItem(NewsItem.create(title: "Scouting Report", description: "Scouts found no notable players this week.", type: NewsItemType.Scouting, date: _currentDate));
    }

    // 3. Simulate Tournament Matches & Handle Starts/Completions
    _simulateMatchesForWeek();

    // 4. Handle Player Training (Player)
    _handlePlayerTraining();

    // 5. Reputation Decay & Transfer Offers (Player)
    _updateReputationDecay();
    _generateTransferOffers();

    // 6. Staff Market Refresh (Player)
    _refreshAvailableStaff();

    // 7. Rival Academy Weekly Actions
    _handleRivalAcademyActions();

    // 8. Other weekly events (Player Finance Summary)
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    _addNewsItem(NewsItem.create(title: "Weekly Finances", description: "Income: ${currencyFormat.format(_weeklyIncome)}, Wages: ${currencyFormat.format(_totalWeeklyWages)}. Net: ${currencyFormat.format(weeklyNet)}. Balance: ${currencyFormat.format(_balance)}", type: NewsItemType.Finance, date: _currentDate));

    // 9. Notify Listeners
    notifyListeners();
  }

  // Check for New Tournaments
  void _checkForNewTournaments() {
    // Run only in the first week of the month
    if (_currentDate.day > 7) return;

    print("Checking for new tournaments to schedule...");
    int tournamentsScheduledThisMonth = 0;
    bool forcedAttempt = false; // Flag to ensure at least one attempt if random fails

    // Shuffle templates to vary which ones are considered first
    List<Tournament> shuffledTemplates = List.from(_availableTournamentTemplates)..shuffle(_random);

    for (var template in shuffledTemplates) {
      // Check if an instance of this template is already scheduled or in progress
      bool alreadyActive = _activeTournaments.any((t) => t.baseId == template.id && (t.status == TournamentStatus.Scheduled || t.status == TournamentStatus.InProgress));
      if (alreadyActive) {
        print(" -> Instance of ${template.name} already active. Skipping.");
        continue;
      }

      // *** INCREASED CHANCE: Higher base chance, less dependent on rep ***
      double baseChance = (template.format == TournamentFormat.League) ? 0.25 : 0.50; // Lower chance for league
      double repModifier = (template.requiredReputation / 500.0).clamp(0.1, 0.5); // Rep still has some influence (10-50%)
      double startChance = baseChance + (_random.nextDouble() * repModifier); // Base + Random Rep Influence
      startChance = startChance.clamp(0.05, 0.95); // Clamp between 5% and 95%

      // *** Force attempt if no tournaments scheduled yet this month ***
      if (tournamentsScheduledThisMonth == 0 && !forcedAttempt) {
          // If it's the last template and nothing scheduled, force the check
          if (template == shuffledTemplates.last) {
              print(" -> Forcing attempt for ${template.name} as last chance this month.");
              startChance = 1.0; // Guarantee the check runs
              forcedAttempt = true;
          }
          // Or, give a much higher chance earlier on if nothing scheduled yet
          else if (_random.nextDouble() < 0.8) { // 80% chance to force an earlier attempt
             print(" -> Increasing chance for ${template.name} as none scheduled yet.");
             startChance = max(startChance, 0.9); // Ensure at least 90% chance
             forcedAttempt = true; // Mark that we forced an attempt
          }
      }

      if (_random.nextDouble() < startChance) {
        print(" -> Considering scheduling ${template.name} (Chance: ${startChance.toStringAsFixed(2)})...");

        // Find potential rival participants
        List<RivalAcademy> potentialRivals = _rivalAcademies.where((rival) =>
            rival.reputation >= template.requiredReputation &&
            rival.balance >= template.entryFee &&
            rival.players.length >= template.requiredPlayers &&
            !rival.activeTournamentIds.any((tId) => _activeTournaments.any((at) => at.id == tId)) // Not already in an active one
        ).toList();
        potentialRivals.shuffle(_random);

        List<String> participants = [];
        // Try to fill up to numberOfTeams, but require at least minTeamsToStart
        for (var rival in potentialRivals) {
          if (participants.length >= template.numberOfTeams) break;
          // Ask rival if they want to join
          if (rival.shouldEnterTournament(template, _currentDate.year, _currentDate.month)) {
            participants.add(rival.id);
            // print(" -> ${rival.name} wants to join."); // Less verbose
          }
        }

        // Use minTeamsToStart from template
        // For Leagues, require EXACTLY numberOfTeams (including player if they join later)
        bool canStartPotentially = (template.format == TournamentFormat.League)
            ? (participants.length >= template.minTeamsToStart - 1) // Allow space for player
            : (participants.length >= template.minTeamsToStart -1); // Allow space for player

        if (canStartPotentially) {
          // Create the instance but DON'T add the player yet
          Tournament newTournament = Tournament.fromTemplate(template, participants, _currentDate);
          addActiveTournament(newTournament); // Adds to _activeTournaments with Scheduled status
          // Mark rivals as participating
          for (var participantId in participants) {
              _rivalAcademyMap[participantId]?.activeTournamentIds.add(newTournament.id);
           }
           // *** MODIFIED News Item: Reflect start date ***
           String joinWindow = (template.format == TournamentFormat.League)
               ? "You have until the end of the season to join." // Leagues start next season
               : "You have until next week to join."; // Knockouts start in 2 weeks
           _addNewsItem(NewsItem.create(
               title: "New Tournament Scheduled",
               description: "The ${newTournament.name} is scheduled to start on ${DateFormat.yMMMd().format(newTournament.startDate)} with ${participants.length} teams confirmed so far. $joinWindow",
               type: NewsItemType.Tournament,
               date: _currentDate
           ));
           tournamentsScheduledThisMonth++;
           print(" -> Scheduled ${newTournament.name} (ID: ${newTournament.id}) starting ${DateFormat.yMMMd().format(newTournament.startDate)} with ${participants.length} teams.");
        } else {
          print(" -> Not enough potential participants (${participants.length}) for ${template.name}. Min required (allowing for player): ${template.minTeamsToStart -1}");
        }
      } else {
         print(" -> Skipping ${template.name} this month (Rolled < ${startChance.toStringAsFixed(2)} chance).");
      }
    }
    if (tournamentsScheduledThisMonth == 0) {
        print("No new tournaments were successfully scheduled this month.");
    }
  }

  // Handle Rival Academy Actions
  void _handleRivalAcademyActions() {
    // print("--- Handling Rival Academy Weekly Actions ---"); // Less verbose
    for (var academy in _rivalAcademies) {
      // 1. Facility Upgrades
      String? upgradeType = academy.decideFacilityUpgrade();
      if (upgradeType != null) {
        int currentLevel = 0;
        switch (upgradeType) {
          case 'training': currentLevel = academy.trainingFacilityLevel; break;
          case 'scouting': currentLevel = academy.scoutingFacilityLevel; break;
          case 'medical': currentLevel = academy.medicalBayLevel; break;
        }
        int cost = academy.calculateFacilityUpgradeCost(currentLevel);

        if (academy.balance >= cost) { // Check affordability before upgrading
            academy.balance -= cost;
            int newLevel = 0;
            if (upgradeType == 'training') { academy.trainingFacilityLevel++; newLevel = academy.trainingFacilityLevel; }
            else if (upgradeType == 'scouting') { academy.scoutingFacilityLevel++; newLevel = academy.scoutingFacilityLevel; }
            else if (upgradeType == 'medical') { academy.medicalBayLevel++; newLevel = academy.medicalBayLevel; }
            // print(" -> ${academy.name} upgraded $upgradeType facility to level $newLevel. Cost: $cost"); // Less verbose
            // Optional: Add news item about rival upgrades?
        } else {
             // print(" -> ${academy.name} wanted to upgrade $upgradeType but couldn't afford $cost."); // Verbose
        }
      }

      // 2. Player Training (Simplified)
      double trainingEffectiveness = (academy.trainingFacilityLevel * 0.5) + (academy.skillLevel / 100.0); // Based on facility and skill
      for (var player in academy.players) {
        if (player.currentSkill < player.potentialSkill) {
          double improveChance = 0.02 * trainingEffectiveness; // Low base chance, modified by effectiveness
          if (_random.nextDouble() < improveChance) {
            player.currentSkill++;
            // print(" -> ${academy.name}'s player ${player.name} improved skill to ${player.currentSkill}"); // Maybe too verbose
          }
        }
        // Simple fatigue recovery for rivals
        player.fatigue = (player.fatigue - (5.0 + (player.stamina / 15.0))).clamp(0.0, 100.0);
      }

      // 3. Player Scouting/Signing (Placeholder - Needs more infrastructure)
      // List<Player> playersToSign = academy.decidePlayersToSign(someListOfAvailablePlayers);
      // Sign players, adjust balance...

      // 4. Player Selling (Placeholder)
      // List<Player> playersToSell = academy.decidePlayersToSell();
      // Remove players, adjust balance...

      // 5. Basic Income/Expenses (Simplified)
      double rivalWeeklyIncome = (academy.reputation * 5) + (academy.skillLevel * 10); // Income based on rep/skill
      double rivalWeeklyWages = academy.players.fold(0.0, (sum, p) => sum + p.weeklyWage);
      // Add staff wages later if rivals hire staff
      academy.balance += rivalWeeklyIncome;
      academy.balance -= rivalWeeklyWages;
      // Ensure balance doesn't go excessively negative (or handle bankruptcy later)
      academy.balance = max(0, academy.balance);

      // 6. Reputation Decay (Similar to player)
      academy.reputation = max(10, academy.reputation - 1); // Min reputation 10
    }
  }

  // --- State Modification Methods ---
  void _calculateWeeklyWages() {
    int staffWages = _hiredStaff.fold(0, (sum, staff) => sum + staff.weeklyWage);
    int playerWages = _academyPlayers.fold(0, (sum, player) => sum + player.weeklyWage);
    _totalWeeklyWages = staffWages + playerWages;
    // print("Calculated weekly wages: $_totalWeeklyWages"); // Less verbose
  }

  bool hireStaff(Staff staffToHire) {
    int currentCount = _hiredStaff.where((s) => s.role == staffToHire.role).length;
    bool canHire = true;
    String? reason;

    switch (staffToHire.role) {
      case StaffRole.Manager: if (currentCount >= 1) { canHire = false; reason = "Only one Manager allowed."; } break;
      case StaffRole.Coach: if (currentCount >= _maxCoaches) { canHire = false; reason = "Coach limit reached ($_maxCoaches). Upgrade Training Facility."; } break;
      case StaffRole.Scout: if (currentCount >= _maxScouts) { canHire = false; reason = "Scout limit reached ($_maxScouts). Upgrade Scouting Facility."; } break;
      case StaffRole.Physio: if (currentCount >= _maxPhysios) { canHire = false; reason = "Physio limit reached ($_maxPhysios). Upgrade Medical Bay."; } break;
    }

    if (!canHire) { print("Cannot hire ${staffToHire.name}. Reason: $reason"); return false; }

    _hiredStaff.add(staffToHire);
    _availableStaff.removeWhere((s) => s.id == staffToHire.id);
    _calculateWeeklyWages();
    _addNewsItem(NewsItem.create(title: "Staff Hired", description: "We have hired ${staffToHire.name} as our new ${staffToHire.role.toString().split('.').last}.", type: NewsItemType.StaffChange, date: _currentDate));
    notifyListeners();
    print("Hired ${staffToHire.name}");
    return true;
  }

  void signPlayer(Player playerToSign) {
    playerToSign.isScouted = false;
    _academyPlayers.add(playerToSign);
    _scoutedPlayers.removeWhere((p) => p.id == playerToSign.id);
    _calculateWeeklyWages();
    _addNewsItem(NewsItem.create(title: "Player Signed", description: "We have signed the promising young player ${playerToSign.name} to the academy.", type: NewsItemType.PlayerSigned, date: _currentDate));
    print("Signed ${playerToSign.name}");

    Staff? availableCoach = _hiredStaff.firstWhereOrNull( (s) => s.role == StaffRole.Coach && s.assignedPlayerIds.length < s.maxPlayersTrainable );
    if (availableCoach != null) {
      assignPlayerToCoach(playerToSign.id, availableCoach.id); // Use the method
      print("Automatically assigned ${playerToSign.name} to coach ${availableCoach.name}.");
      _addNewsItem(NewsItem.create(title: "Player Assigned", description: "${playerToSign.name} has been automatically assigned to Coach ${availableCoach.name} for training.", type: NewsItemType.Training, date: _currentDate));
    } else { print("No coaches with available capacity found for ${playerToSign.name}."); }
    notifyListeners();
  }

  void rejectPlayer(Player playerToReject) {
    _scoutedPlayers.removeWhere((p) => p.id == playerToReject.id);
    notifyListeners();
    print("Rejected ${playerToReject.name}");
  }

  // Add Active Tournament (Instance)
  void addActiveTournament(Tournament tournament) {
    if (!_activeTournaments.any((t) => t.id == tournament.id)) {
      _activeTournaments.add(tournament);
      // print("Tournament ${tournament.name} (ID: ${tournament.id}) added to active tournaments with status ${tournament.status}."); // Less verbose
      notifyListeners(); // Notify UI that tournaments list changed
    }
  }

  // --- Try Join Tournament (Player Action) ---
  bool tryJoinTournament(Tournament template) {
    print("Attempting to join tournament template: ${template.name} (ID: ${template.id})");

    // 1. Check Requirements
    if (_academyPlayers.length < template.requiredPlayers) {
      print(" -> Failed: Not enough players (${_academyPlayers.length}/${template.requiredPlayers})");
      return false;
    }
    if (_academyReputation < template.requiredReputation) {
      print(" -> Failed: Not enough reputation (${_academyReputation}/${template.requiredReputation})");
      return false;
    }
    if (_balance < template.entryFee) {
      print(" -> Failed: Not enough balance (${_balance}/${template.entryFee})");
      return false;
    }
    // Check if already joined an instance of this template
    if (_activeTournaments.any((at) => at.baseId == template.id && at.teamIds.contains(playerAcademyId))) {
        print(" -> Failed: Already joined an active instance of this tournament.");
        return false;
    }

    // 2. Find a Scheduled Instance of this Template
    Tournament? scheduledInstance = _activeTournaments.firstWhereOrNull(
      (t) => t.baseId == template.id && t.status == TournamentStatus.Scheduled
    );

    if (scheduledInstance == null) {
      print(" -> Failed: No scheduled instance found for ${template.name}.");
      // Maybe create one on demand if enough rivals are available? For now, require pre-scheduled.
      return false;
    }

    // 3. Check if Instance has Space
    if (scheduledInstance.teamIds.length >= scheduledInstance.numberOfTeams) {
      print(" -> Failed: Scheduled instance ${scheduledInstance.id} is already full (${scheduledInstance.teamIds.length}/${scheduledInstance.numberOfTeams}).");
      return false;
    }

    // 4. Join the Instance
    _balance -= template.entryFee; // Deduct entry fee
    scheduledInstance.teamIds.add(playerAcademyId); // Add player to participants
    // If league, add player to standings
    if (scheduledInstance.format == TournamentFormat.League) {
        scheduledInstance.leagueStandings[playerAcademyId] = LeagueStanding(teamId: playerAcademyId);
    }
    print(" -> Success: Joined scheduled tournament instance ${scheduledInstance.id}. Deducted fee: ${template.entryFee}. New balance: $_balance.");
    _addNewsItem(NewsItem.create(title: "Tournament Joined", description: "Successfully joined the upcoming ${template.name}.", type: NewsItemType.Tournament, date: _currentDate));

    // 5. Notify and Return
    notifyListeners();
    return true;
  }
  // --- End Try Join Tournament ---

  // Simulate Matches & Handle Tournament State Changes
  void _simulateMatchesForWeek() {
    DateTime startOfWeek = _currentDate.subtract(const Duration(days: 7));
    DateTime endOfWeek = _currentDate;
    List<Tournament> completedOrCancelledTournamentsThisWeek = [];
    List<Tournament> tournamentsToCheckForNextRound = []; // Knockout tournaments potentially ready for next round

    // --- Handle Tournament Starts ---
    List<Tournament> tournamentsToCheckStart = List.from(_activeTournaments.where((t) => t.status == TournamentStatus.Scheduled));
    for (var tournament in tournamentsToCheckStart) {
        // Check if the tournament's start date is within the current week being processed
        if (!tournament.startDate.isAfter(endOfWeek)) {
            print("Tournament ${tournament.name} (ID: ${tournament.id}) is due to start.");
            // Attempt to generate matches (this also checks min teams and sets status to Cancelled if needed)
            tournament.generateMatchesForStart();

            if (tournament.status == TournamentStatus.Cancelled) {
                // Match generation failed (not enough teams), handle cancellation
                print(" -> Tournament cancelled - not enough teams (${tournament.teamIds.length}/${tournament.minTeamsToStart}).");
                _addNewsItem(NewsItem.create(title: "${tournament.name} Cancelled", description: "The ${tournament.name} was cancelled due to insufficient participants.", type: NewsItemType.Tournament, date: tournament.startDate));
                // Refund entry fees
                if (tournament.teamIds.contains(playerAcademyId)) {
                    _balance += tournament.entryFee;
                    print(" -> Refunded entry fee ${tournament.entryFee} to player.");
                }
                for (var rivalId in tournament.teamIds) {
                    if (rivalId != playerAcademyId) {
                        _rivalAcademyMap[rivalId]?.balance += tournament.entryFee;
                        _rivalAcademyMap[rivalId]?.activeTournamentIds.remove(tournament.id);
                    }
                }
                completedOrCancelledTournamentsThisWeek.add(tournament); // Move cancelled to completed list
            } else if (tournament.matches.isNotEmpty) {
                // Matches generated successfully, set to InProgress
                tournament.status = TournamentStatus.InProgress;
                print(" -> Tournament is now InProgress.");
                _addNewsItem(NewsItem.create(title: "${tournament.name} Started", description: "The ${tournament.name} has officially begun!", type: NewsItemType.Tournament, date: tournament.startDate));
            } else {
                // Should ideally not happen if generateMatchesForStart handles cancellation, but as a fallback:
                 print(" -> Tournament start check resulted in no matches and not cancelled. Status remains Scheduled? Investigate.");
            }
        }
    }

    // --- Simulate Matches for InProgress Tournaments ---
    for (var tournament in List.from(_activeTournaments)) { // Iterate over a copy
      if (tournament.status == TournamentStatus.InProgress) {
        bool matchesSimulatedThisWeek = false;
        for (var match in tournament.matches) {
          // Simulate matches scheduled for the *current* week (or slightly before if missed)
          if (!match.isSimulated && !match.matchDate.isAfter(endOfWeek)) {
            // print("Preparing detailed simulation for match: ${match.id} scheduled for ${match.matchDate}"); // Less verbose
            TournamentType tournamentType = tournament.type;
            List<Player> homeLineup; List<Player> awayLineup;

            // Get Home Team Lineup
            if (match.homeTeamId == playerAcademyId) {
              homeLineup = selectPlayerTeamForMatch(tournamentType);
            } else {
              RivalAcademy? homeAcademy = _rivalAcademyMap[match.homeTeamId];
              homeLineup = (homeAcademy != null) ? selectRivalTeamForMatch(tournamentType, homeAcademy) : [];
              if (homeAcademy == null) print("Error: Home Rival Academy ${match.homeTeamId} not found for match ${match.id}. Using empty lineup.");
            }

            // Get Away Team Lineup
            if (match.awayTeamId == playerAcademyId) {
              awayLineup = selectPlayerTeamForMatch(tournamentType);
            } else {
              RivalAcademy? awayAcademy = _rivalAcademyMap[match.awayTeamId];
              awayLineup = (awayAcademy != null) ? selectRivalTeamForMatch(tournamentType, awayAcademy) : [];
              if (awayAcademy == null) print("Error: Away Rival Academy ${match.awayTeamId} not found for match ${match.id}. Using empty lineup.");
            }

            Staff? playerManager = _hiredStaff.firstWhereOrNull((s) => s.role == StaffRole.Manager);
            // Simulate the match
            match.simulateDetailed(homeLineup, awayLineup, playerManager: (match.homeTeamId == playerAcademyId || match.awayTeamId == playerAcademyId) ? playerManager : null);

            _updatePlayerStatsAndFatigue(match, homeLineup, awayLineup); // Updates player academy players
            _updateRivalFatigue(match, homeLineup, awayLineup); // Update rival fatigue
            _updateReputationAfterMatch(tournament, match); // Updates player and rival reputation
            _updateLeagueStandings(tournament, match); // NEW: Update league standings

            matchesSimulatedThisWeek = true;

            // News Item for Player's Matches
            if (match.isSimulated && match.result != null && (match.homeTeamId == playerAcademyId || match.awayTeamId == playerAcademyId)) {
              String homeTeamName = match.homeTeamId == playerAcademyId ? _academyName : (_rivalAcademyMap[match.homeTeamId]?.name ?? match.homeTeamId);
              String awayTeamName = match.awayTeamId == playerAcademyId ? _academyName : (_rivalAcademyMap[match.awayTeamId]?.name ?? match.awayTeamId);
              String resultString = ""; // Initialize resultString
              String opponentName;
              if (match.homeTeamId == playerAcademyId) {
                 switch (match.result!) { case MatchResult.homeWin: resultString = "won against"; break; case MatchResult.awayWin: resultString = "lost to"; break; case MatchResult.draw: resultString = "drew with"; break; }
                 opponentName = awayTeamName;
              } else { // Player is away team
                 switch (match.result!) { case MatchResult.homeWin: resultString = "lost to"; break; case MatchResult.awayWin: resultString = "won against"; break; case MatchResult.draw: resultString = "drew with"; break; }
                 opponentName = homeTeamName;
              }
              String score = "${match.homeScore} - ${match.awayScore}";
              _addNewsItem(NewsItem.create(title: "Match Result (${tournament.name})", description: "$_academyName $resultString $opponentName $score.", type: NewsItemType.MatchResult, date: match.matchDate));
            }
          }
        } // End match loop

        // --- Check for Knockout Round Completion ---
        if (matchesSimulatedThisWeek && tournament.format == TournamentFormat.Knockout) {
            // Check if all matches of the *current* knockout round are now simulated
            // Explicitly type 'm' as Match
            int expectedMatchesThisRound = tournament.matches.where((Match m) => m.round == tournament.currentRound).length;
            int simulatedMatchesThisRound = tournament.matches.where((Match m) => m.round == tournament.currentRound && m.isSimulated).length;

            if (expectedMatchesThisRound > 0 && simulatedMatchesThisRound == expectedMatchesThisRound) {
                print("Knockout round ${tournament.currentRound} of ${tournament.name} completed.");
                if (!tournamentsToCheckForNextRound.contains(tournament)) {
                  tournamentsToCheckForNextRound.add(tournament); // Add to list to process after main loop
                }
            }
        }

        // --- Check for Tournament Completion (All matches simulated) ---
        // Explicitly type 'm' as Match
        bool allMatchesSimulated = tournament.matches.every((Match m) => m.isSimulated);
        if (allMatchesSimulated) {
          print("All matches for tournament ${tournament.name} are simulated.");
          // If knockout, the winner might already be set by generateNextKnockoutRound
          if (tournament.status != TournamentStatus.Completed) { // Avoid double completion
             tournament.status = TournamentStatus.Completed;
             completedOrCancelledTournamentsThisWeek.add(tournament);
             // Remove tournament ID from participating rivals
             for (var participantId in tournament.teamIds) {
                if (participantId != playerAcademyId) {
                   _rivalAcademyMap[participantId]?.activeTournamentIds.remove(tournament.id);
                }
             }
             // Award prize money etc.
             _handleTournamentCompletion(tournament);
          }
        }
      } // End if InProgress
    } // End tournament loop

    // --- Generate Next Knockout Rounds ---
    for (var tournament in tournamentsToCheckForNextRound) {
        if (tournament.status == TournamentStatus.InProgress) { // Ensure it wasn't completed above
            bool nextRoundGenerated = tournament.generateNextKnockoutRound();
            if (nextRoundGenerated) {
                print("Generated next knockout round (${tournament.currentRound}) for ${tournament.name}.");
                _addNewsItem(NewsItem.create(title: "${tournament.name} Update", description: "Round ${tournament.currentRound-1} completed. Fixtures for Round ${tournament.currentRound} are set.", type: NewsItemType.Tournament, date: _currentDate));
            } else {
                // generateNextKnockoutRound returns false if completed or error
                if (tournament.status == TournamentStatus.Completed) {
                    print("Tournament ${tournament.name} completed after generating final round.");
                    if (!completedOrCancelledTournamentsThisWeek.contains(tournament)) {
                        completedOrCancelledTournamentsThisWeek.add(tournament);
                         // Remove tournament ID from participating rivals
                         for (var participantId in tournament.teamIds) {
                            if (participantId != playerAcademyId) {
                               _rivalAcademyMap[participantId]?.activeTournamentIds.remove(tournament.id);
                            }
                         }
                        _handleTournamentCompletion(tournament); // Handle completion now
                    }
                }
            }
        }
    }

    // --- Clean up Active/Completed Lists ---
    if (completedOrCancelledTournamentsThisWeek.isNotEmpty) {
      _completedTournaments.addAll(completedOrCancelledTournamentsThisWeek);
      _activeTournaments.removeWhere((t) => completedOrCancelledTournamentsThisWeek.contains(t));
      print("Moved ${completedOrCancelledTournamentsThisWeek.length} tournaments to history/cancelled.");
    }

    _applyWeeklyFatigueRecovery(); // Player fatigue recovery
    // Rival fatigue recovery is handled in _handleRivalAcademyActions
  }

  // --- NEW: Update League Standings ---
  void _updateLeagueStandings(Tournament tournament, Match match) {
      if (tournament.format != TournamentFormat.League || !match.isSimulated || match.result == null) {
          return; // Only for completed league matches
      }

      LeagueStanding? homeStanding = tournament.leagueStandings[match.homeTeamId];
      LeagueStanding? awayStanding = tournament.leagueStandings[match.awayTeamId];

      if (homeStanding == null || awayStanding == null) {
          print("Error: Could not find league standings for teams in match ${match.id}");
          return;
      }

      homeStanding.played++;
      awayStanding.played++;
      homeStanding.goalsFor += match.homeScore;
      homeStanding.goalsAgainst += match.awayScore;
      awayStanding.goalsFor += match.awayScore;
      awayStanding.goalsAgainst += match.homeScore;

      switch (match.result!) {
          case MatchResult.homeWin:
              homeStanding.wins++;
              awayStanding.losses++;
              break;
          case MatchResult.awayWin:
              homeStanding.losses++;
              awayStanding.wins++;
              break;
          case MatchResult.draw:
              homeStanding.draws++;
              awayStanding.draws++;
              break;
      }
      // print("Updated league standings for ${tournament.name} after match ${match.id}"); // Verbose
  }
  // --- END NEW ---

  // Handle Tournament Completion (Awarding Prizes, etc.)
  void _handleTournamentCompletion(Tournament tournament) {
      if (tournament.status != TournamentStatus.Completed) return; // Only handle completed, not cancelled

      print("Handling completion of tournament: ${tournament.name}");
      String? determinedWinnerId = tournament.winnerId; // Winner might be set by knockout logic
      String winnerName = "Unknown"; // Default winner name

      // --- Determine Winner ---
      // Winner for Knockout is usually set by generateNextKnockoutRound when it completes.
      // If it's somehow null here upon completion, we find the winner of the last simulated match.
      if (tournament.format == TournamentFormat.Knockout) {
          if (determinedWinnerId == null && tournament.matches.isNotEmpty) {
              // Find winner from the absolute last simulated match
              List<Match> simulatedMatches = tournament.matches.where((Match m) => m.isSimulated).toList(); // Explicit type
              if (simulatedMatches.isNotEmpty) {
                  simulatedMatches.sort((a, b) => b.matchDate.compareTo(a.matchDate)); // Sort by date descending
                  // The winner of the most recent match should be the tournament winner
                  determinedWinnerId = simulatedMatches.first.winnerId;
                  print(" -> Determined knockout winner from last match: $determinedWinnerId");
              } else {
                  print(" -> Warning: Knockout tournament completed but no simulated matches found to determine winner.");
              }
          }
      }
      // Determine League Winner
      else if (tournament.format == TournamentFormat.League) {
          if (determinedWinnerId == null && tournament.leagueStandings.isNotEmpty) {
              // Determine league winner based on points, then GD, then GF
              List<LeagueStanding> sortedStandings = tournament.leagueStandings.values.toList();
              sortedStandings.sort((a, b) {
                  int pointsComparison = b.points.compareTo(a.points);
                  if (pointsComparison != 0) return pointsComparison;
                  int gdComparison = b.goalDifference.compareTo(a.goalDifference);
                  if (gdComparison != 0) return gdComparison;
                  return b.goalsFor.compareTo(a.goalsFor); // Higher Goals For wins tie
              });
              if (sortedStandings.isNotEmpty) {
                  determinedWinnerId = sortedStandings.first.teamId;
              }
          }
      }

      tournament.winnerId = determinedWinnerId; // Store final winner ID
      int prizeMoney = tournament.prizeMoneyBase; // Base prize for winner

      if (determinedWinnerId != null) {
          if (determinedWinnerId == playerAcademyId) {
              winnerName = _academyName;
              _balance += prizeMoney;
              _academyReputation += (tournament.format == TournamentFormat.League) ? 40 : 20; // More rep for league win
              _addNewsItem(NewsItem.create(
                  title: "Tournament Won!",
                  description: "We won the ${tournament.name} and received ${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(prizeMoney)}!",
                  type: NewsItemType.MatchResult, // Corrected type
                  date: _currentDate
              ));
              print("Player won ${tournament.name}. Prize: $prizeMoney. New Balance: $_balance. New Rep: $_academyReputation");
          } else {
              RivalAcademy? rivalWinner = _rivalAcademyMap[determinedWinnerId];
              if (rivalWinner != null) {
                  winnerName = rivalWinner.name;
                  rivalWinner.balance += prizeMoney;
                  rivalWinner.reputation += (tournament.format == TournamentFormat.League) ? 40 : 20; // Rival rep boost
                   _addNewsItem(NewsItem.create(
                      title: "${tournament.name} Concluded",
                      description: "${rivalWinner.name} won the ${tournament.name}.",
                      type: NewsItemType.MatchResult, // Corrected type
                      date: _currentDate
                  ));
                  print("${rivalWinner.name} won ${tournament.name}. Prize: $prizeMoney. New Balance: ${rivalWinner.balance}. New Rep: ${rivalWinner.reputation}");
              } else {
                  winnerName = "An unknown team"; // Fallback if rival not found
                  print("Warning: Winner ID $determinedWinnerId not found in rival map for tournament ${tournament.name}");
              }
          }
      } else {
           _addNewsItem(NewsItem.create(
              title: "${tournament.name} Concluded",
              description: "The ${tournament.name} has finished.", // Simpler message if no winner determined
              type: NewsItemType.MatchResult, // Corrected type
              date: _currentDate
          ));
          print("${tournament.name} finished without a clear winner determined.");
      }
  }

  void _updatePlayerStatsAndFatigue(Match match, List<Player> homeLineup, List<Player> awayLineup) {
    if (!match.isSimulated) return;
    List<Player> playersToCheck = [];
    // *** FIX: Use match.homeLineup and match.awayLineup which store the actual player IDs used ***
    if (match.homeTeamId == playerAcademyId) playersToCheck.addAll(_academyPlayers.where((p) => match.homeLineup.contains(p.id)));
    if (match.awayTeamId == playerAcademyId) playersToCheck.addAll(_academyPlayers.where((p) => match.awayLineup.contains(p.id)));

    for (var academyPlayer in playersToCheck) {
       // Player already fetched from _academyPlayers, no need for firstWhereOrNull
       // if (academyPlayer != null) { // Check removed as playersToCheck only contains valid players
         academyPlayer.matchesPlayed++;
         double fatigueIncrease = 15.0 + ( (100 - academyPlayer.stamina) / 10.0 ); // Higher increase for lower stamina
         academyPlayer.fatigue = (academyPlayer.fatigue + fatigueIncrease).clamp(0.0, 100.0);
         // print("Player ${academyPlayer.name} played match ${match.id}. Fatigue: ${academyPlayer.fatigue.toStringAsFixed(1)}%"); // Verbose

         // Update goals/assists from event log
         for (var event in match.eventLog) {
           if (event.playerId == academyPlayer.id) {
             if (event.type == MatchEventType.Goal) { academyPlayer.goalsScored++; }
             else if (event.type == MatchEventType.Assist) { academyPlayer.assists++; }
           }
         }
       // } // Check removed
    }
  }

  // Update Rival Fatigue
  void _updateRivalFatigue(Match match, List<Player> homeLineup, List<Player> awayLineup) {
      if (!match.isSimulated) return;
      // *** FIX: Use match.homeLineup and match.awayLineup which store the actual player IDs used ***
      RivalAcademy? homeRival = _rivalAcademyMap[match.homeTeamId];
      RivalAcademy? awayRival = _rivalAcademyMap[match.awayTeamId];

      List<Player> playersToUpdate = [];
      if (homeRival != null) {
          playersToUpdate.addAll(homeRival.players.where((p) => match.homeLineup.contains(p.id)));
      }
      if (awayRival != null) {
          playersToUpdate.addAll(awayRival.players.where((p) => match.awayLineup.contains(p.id)));
      }

      for (var rivalPlayer in playersToUpdate) {
          // Player already fetched from rival academy list
          double fatigueIncrease = 15.0 + ((100 - rivalPlayer.stamina) / 10.0);
          rivalPlayer.fatigue = (rivalPlayer.fatigue + fatigueIncrease).clamp(0.0, 100.0);
          // print("Rival Player ${rivalPlayer.name} fatigue updated to ${rivalPlayer.fatigue.toStringAsFixed(1)}%"); // Verbose
      }
  }

  void _applyWeeklyFatigueRecovery() {
     // print("--- Applying Weekly Fatigue Recovery (Player Academy) ---"); // Less verbose
     for (var player in _academyPlayers) {
        double recoveryAmount = 5.0 + (player.stamina / 10.0); // Better recovery for higher stamina
        // Bonus recovery if medical bay is high
        recoveryAmount *= (1.0 + (_medicalBayLevel - 1) * 0.1); // +10% per level above 1
        player.fatigue = (player.fatigue - recoveryAmount).clamp(0.0, 100.0);
     }
  }

  // Handle Player Training
  void _handlePlayerTraining() {
    // print("--- Handling Player Training ---"); // Less verbose
    bool anyPlayerImproved = false;
    Map<String, Player> playerMap = { for (var p in _academyPlayers) p.id : p };
    final coaches = _hiredStaff.where((s) => s.role == StaffRole.Coach).toList();
    if (coaches.isEmpty) { /* print("No coaches hired. No specific player training applied this week."); */ return; } // Less verbose
    Set<String> trainedPlayerIds = {};
    for (var coach in coaches) {
      // print("Coach ${coach.name} (Skill: ${coach.skill}, Capacity: ${coach.assignedPlayerIds.length}/${coach.maxPlayersTrainable}) is training..."); // Less verbose
      for (var playerId in coach.assignedPlayerIds) {
        if (playerMap.containsKey(playerId) && !trainedPlayerIds.contains(playerId)) {
          Player player = playerMap[playerId]!;
          trainedPlayerIds.add(playerId);
          if (player.currentSkill < player.potentialSkill) {
            int baseChance = 5; int coachBonus = (coach.skill / 5).floor(); int facilityBonus = (_trainingFacilityLevel * 3); int difficultyModifier = 0;
            switch (_difficulty) {
                case Difficulty.Easy: difficultyModifier = 5; break;
                case Difficulty.Normal: difficultyModifier = 0; break;
                case Difficulty.Hard: difficultyModifier = -5; break;
                case Difficulty.Hardcore: difficultyModifier = -8; break; // Added Hardcore penalty
            }
            int totalChance = (baseChance + coachBonus + facilityBonus + difficultyModifier).clamp(1, 99);
            if (_random.nextInt(100) < totalChance) {
              int oldSkill = player.currentSkill; player.currentSkill++;
              // print("  -> Player ${player.name} (under ${coach.name}) improved skill to ${player.currentSkill}. Chance: $totalChance%"); // Less verbose
              anyPlayerImproved = true;
              _addNewsItem(NewsItem.create(title: "Player Improved", description: "${player.name} improved their skill from $oldSkill to ${player.currentSkill} under Coach ${coach.name}.", type: NewsItemType.Training, date: _currentDate));
            }
          }
        } else if (!playerMap.containsKey(playerId)) { print("  -> Warning: Player ID $playerId assigned to coach ${coach.name} not found in academy players."); }
      }
    }
    // int unassignedCount = _academyPlayers.where((p) => !trainedPlayerIds.contains(p.id)).length; // Less verbose
    // if (unassignedCount > 0) { print("$unassignedCount players were not assigned to any coach this week."); }
    // if (!anyPlayerImproved && coaches.isNotEmpty) { print("No players improved under coaching this week."); }
  }

  void _refreshAvailableStaff() {
    int removedCount = 0;
    _availableStaff.removeWhere((staff) { bool leaving = _random.nextDouble() < 0.20; if (leaving) removedCount++; return leaving; });
    int newStaffCount = 1 + _random.nextInt(3); int addedCount = 0;
    for (int i = 0; i < newStaffCount; i++) {
      StaffRole role = StaffRole.values[_random.nextInt(StaffRole.values.length)];
      // Reduce chance of Manager/Physio appearing if many already available?
      if ((role == StaffRole.Physio || role == StaffRole.Manager) && _random.nextBool()) { role = StaffRole.values[_random.nextInt(StaffRole.values.length)]; }
      if (_availableStaff.length < 15) { Staff newStaff = Staff.randomStaff('staff_${_currentDate.millisecondsSinceEpoch}_$i', role); _availableStaff.add(newStaff); addedCount++; }
    }
    // print("Staff Market Refreshed: $removedCount removed, $addedCount added. Total available: ${_availableStaff.length}"); // Less verbose
  }

  bool assignPlayerToCoach(String playerId, String coachId) {
    Staff? coach = _hiredStaff.firstWhereOrNull((s) => s.id == coachId && s.role == StaffRole.Coach);
    if (coach == null) { print("Error: Coach with ID $coachId not found or is not a coach."); return false; }
    Player? player = _academyPlayers.firstWhereOrNull((p) => p.id == playerId);
    if (player == null) { print("Error: Player with ID $playerId not found in academy."); return false; }
    if (coach.assignedPlayerIds.length >= coach.maxPlayersTrainable) { print("Error: Coach ${coach.name} is already at maximum capacity (${coach.maxPlayersTrainable}). Cannot assign ${player.name}."); return false; }
    if (coach.assignedPlayerIds.contains(playerId)) { print("Info: Player ${player.name} is already assigned to coach ${coach.name}."); return true; }
    unassignPlayerFromAnyCoach(playerId); // Ensure player is removed from any other coach first
    coach.assignedPlayerIds.add(playerId);
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

  // Get Team Skill
  int _getTeamSkill(String teamId, List<Player> selectedLineup) {
    if (selectedLineup.isEmpty) { return 10; } // Avoid division by zero

    double totalEffectiveSkill = 0;
    for (var player in selectedLineup) {
      double fatigueModifier = 1.0 - (player.fatigue / 200.0); // Fatigue reduces effectiveness (up to 50%)
      totalEffectiveSkill += player.currentSkill * fatigueModifier;
    }
    int averageEffectiveSkill = (totalEffectiveSkill / selectedLineup.length).round();

    // Apply Manager Bonus for Player Academy
    if (teamId == playerAcademyId) {
      Staff? manager = _hiredStaff.firstWhereOrNull((s) => s.role == StaffRole.Manager);
      if (manager != null) {
        int managerBonus = (manager.skill / 20).floor(); // Example: Skill 60 -> +3 bonus
        averageEffectiveSkill += managerBonus;
        // print("Applying Player Manager Skill Bonus: +$managerBonus"); // Verbose
      }
    }
    // Apply Base Skill Influence for Rival Academies
    else {
      int baseRivalSkill = _getBaseRivalAcademySkill(teamId);
      // Blend average player skill with base academy skill
      averageEffectiveSkill = ((averageEffectiveSkill * 0.7) + (baseRivalSkill * 0.3)).round();
    }

    return averageEffectiveSkill.clamp(1, 100);
  }

  // Get Base Rival Skill
  int _getBaseRivalAcademySkill(String teamId) {
     final academy = _rivalAcademyMap[teamId];
     if (academy != null) {
       int baseSkill = academy.skillLevel;
       // Apply difficulty modifier to rival base skill
       switch (_difficulty) {
           case Difficulty.Easy: baseSkill = (baseSkill * 0.85).round().clamp(1, 100); break;
           case Difficulty.Normal: break; // No change
           case Difficulty.Hard: baseSkill = (baseSkill * 1.15).round().clamp(1, 100); break;
           case Difficulty.Hardcore: baseSkill = (baseSkill * 1.25).round().clamp(1, 100); break; // Added Hardcore boost
       }
       return baseSkill;
     } else {
       print("Warning: Rival Academy with ID '$teamId' not found in _rivalAcademyMap. Returning default skill.");
       return 30; // Default fallback skill
     }
  }

  List<Player> selectPlayerTeamForMatch(TournamentType type, {Staff? manager}) {
    int playersNeeded = _getPlayersNeededForType(type);
    if (_academyPlayers.length < playersNeeded) { print("Warning: Not enough players in academy (${_academyPlayers.length}) for a ${type.toString()} match (needs $playersNeeded). Selecting all available."); return List<Player>.from(_academyPlayers); }
    List<Player> availablePlayers = List<Player>.from(_academyPlayers);
    // Sort by highest skill, penalizing high fatigue
    availablePlayers.sort((a, b) {
        double fatiguePenaltyA = a.fatigue > 75 ? 50 : (a.fatigue / 2); // Heavier penalty above 75%
        double fatiguePenaltyB = b.fatigue > 75 ? 50 : (b.fatigue / 2);
        double effectiveScoreA = a.currentSkill - fatiguePenaltyA;
        double effectiveScoreB = b.currentSkill - fatiguePenaltyB;
        return effectiveScoreB.compareTo(effectiveScoreA); // Descending order
    });
    return availablePlayers.sublist(0, playersNeeded);
  }

  // Select Rival Team
  List<Player> selectRivalTeamForMatch(TournamentType type, RivalAcademy academy) {
     int playersNeeded = _getPlayersNeededForType(type);
     if (academy.players.length < playersNeeded) { print("Warning: Not enough players in rival academy ${academy.name} (${academy.players.length}) for a ${type.toString()} match (needs $playersNeeded). Selecting all available."); return List<Player>.from(academy.players); }
     List<Player> availablePlayers = List<Player>.from(academy.players);
     // Sort by highest skill, penalizing high fatigue
     availablePlayers.sort((a, b) {
        double fatiguePenaltyA = a.fatigue > 75 ? 50 : (a.fatigue / 2);
        double fatiguePenaltyB = b.fatigue > 75 ? 50 : (b.fatigue / 2);
        double effectiveScoreA = a.currentSkill - fatiguePenaltyA;
        double effectiveScoreB = b.currentSkill - fatiguePenaltyB;
        return effectiveScoreB.compareTo(effectiveScoreA); // Descending order
     });
     return availablePlayers.sublist(0, playersNeeded);
  }

  int _getPlayersNeededForType(TournamentType type) { switch (type) { case TournamentType.threeVthree: return 3; case TournamentType.fiveVfive: return 5; case TournamentType.sevenVseven: return 7; case TournamentType.elevenVeleven: return 11; default: return 11; } }

  // Update Reputation After Match
  void _updateReputationAfterMatch(Tournament tournament, Match match) {
    if (!match.isSimulated || match.result == null) return;

    bool playerInvolved = match.homeTeamId == playerAcademyId || match.awayTeamId == playerAcademyId;
    int playerReputationChange = 0;
    int playerIndividualRepChangeBase = 0; // Base change for players involved

    if (playerInvolved) {
      bool playerWon = (match.homeTeamId == playerAcademyId && match.result == MatchResult.homeWin) ||
                       (match.awayTeamId == playerAcademyId && match.result == MatchResult.awayWin);
      bool playerDrew = match.result == MatchResult.draw;

      // Reputation change based on format and result
      int winRep = (tournament.format == TournamentFormat.League) ? 3 : 5;
      int drawRep = (tournament.format == TournamentFormat.League) ? 1 : 2;
      int lossRep = (tournament.format == TournamentFormat.League) ? -1 : -3;

      if (playerWon) {
        playerReputationChange = winRep;
        playerIndividualRepChangeBase = 2;
      } else if (playerDrew) {
        playerReputationChange = drawRep;
        playerIndividualRepChangeBase = 1;
      } else { // Player Lost
        playerReputationChange = lossRep;
        playerIndividualRepChangeBase = 0; // No base rep change for losing, but can gain from goals/assists
      }
      _academyReputation = max(0, _academyReputation + playerReputationChange);
      // print("Player Academy reputation changed by $playerReputationChange to $_academyReputation after match ${match.id}"); // Less verbose
    }

    // Update reputation for participating player academy players
    Set<String> participatingPlayerIds = {};
    // *** FIX: Use match.homeLineup and match.awayLineup which store the actual player IDs used ***
    if (match.homeTeamId == playerAcademyId) participatingPlayerIds.addAll(match.homeLineup);
    if (match.awayTeamId == playerAcademyId) participatingPlayerIds.addAll(match.awayLineup);

    for (String playerId in participatingPlayerIds) {
        Player? player = _academyPlayers.firstWhereOrNull((p) => p.id == playerId);
        if (player != null) {
            int individualChange = playerIndividualRepChangeBase;
            int goals = 0; int assists = 0;
            // Compare event.playerId with playerId (string) directly
            for (var event in match.eventLog) {
              if (event.playerId == playerId) { // This comparison is now correct
                if (event.type == MatchEventType.Goal) goals++;
                if (event.type == MatchEventType.Assist) assists++;
              }
            }
            individualChange += goals * 5; // Bonus for goals
            individualChange += assists * 3; // Bonus for assists
            if (individualChange != 0) {
                player.reputation = max(0, player.reputation + individualChange);
                // print("Player ${player.name} reputation changed by $individualChange to ${player.reputation}"); // Verbose
            }
        }
    }

    // Update Rival Reputation
    RivalAcademy? homeRival = _rivalAcademyMap[match.homeTeamId];
    RivalAcademy? awayRival = _rivalAcademyMap[match.awayTeamId];
    int rivalRepChange = 0;
    int rivalWinRep = (tournament.format == TournamentFormat.League) ? 2 : 3;
    int rivalDrawRep = 1;
    int rivalLossRep = (tournament.format == TournamentFormat.League) ? 0 : -2;

    if (homeRival != null) {
        if (match.result == MatchResult.homeWin) rivalRepChange = rivalWinRep;
        else if (match.result == MatchResult.draw) rivalRepChange = rivalDrawRep;
        else rivalRepChange = rivalLossRep; // Lost
        homeRival.reputation = max(10, homeRival.reputation + rivalRepChange);
        // print("Rival ${homeRival.name} reputation changed by $rivalRepChange to ${homeRival.reputation}"); // Verbose
    }
    if (awayRival != null) {
        if (match.result == MatchResult.awayWin) rivalRepChange = rivalWinRep;
        else if (match.result == MatchResult.draw) rivalRepChange = rivalDrawRep;
        else rivalRepChange = rivalLossRep; // Lost
        awayRival.reputation = max(10, awayRival.reputation + rivalRepChange);
        // print("Rival ${awayRival.name} reputation changed by $rivalRepChange to ${awayRival.reputation}"); // Verbose
    }
  }

  void _updateReputationDecay() {
    // Player academy decay is handled in _handleRivalAcademyActions now
    // _academyReputation = max(0, _academyReputation - 1);
    for (var player in _academyPlayers) { player.reputation = max(0, player.reputation - 1); }
     // print("Applied weekly player reputation decay."); // Rival decay is in their action handler
  }

  // Generate Transfer Offers
  void _generateTransferOffers() {
    _transferOffers.clear(); // Clear previous offers
    // Only generate offers if not in Hardcore mode? Or make them rarer/lower value?
    // For now, let's keep generating them but maybe rivals can also bid later.
    if (_difficulty == Difficulty.Hardcore) {
        // print("Transfer offers disabled in Hardcore mode (for now)."); // Less verbose
        return; // Skip offer generation in Hardcore for simplicity initially
    }

    final random = Random();
    for (var player in _academyPlayers) {
      // Chance based on player rep and academy rep
      double offerChance = ((player.reputation / 500.0) + (_academyReputation / 1000.0)).clamp(0.0, 0.2); // Max 20% chance per player per week
      if (random.nextDouble() < offerChance) {
        // Offer comes from a random rival academy
        if (_rivalAcademies.isEmpty) continue; // No rivals to make offers
        RivalAcademy offeringAcademy = _rivalAcademies[random.nextInt(_rivalAcademies.length)];

        int marketValue = player.calculateMarketValue();
        double offerMultiplier = 0.7 + random.nextDouble() * 0.5; // Offer between 70% and 120% of market value
        int offerAmount = (marketValue * offerMultiplier).round();
        offerAmount = max(100, offerAmount); // Ensure minimum offer

        // Check if the offering academy can afford it (simple check)
        if (offeringAcademy.balance >= offerAmount) {
            _transferOffers.add({
                'playerId': player.id,
                'playerName': player.name,
                'offeringClubName': offeringAcademy.name, // Use academy name
                'offeringClubId': offeringAcademy.id, // Store ID for potential future logic
                'offerAmount': offerAmount,
            });
            // print("Generated transfer offer for ${player.name} (Value: $marketValue) from ${offeringAcademy.name} for $offerAmount"); // Less verbose
            _addNewsItem(NewsItem.create(title: "Transfer Offer Received", description: "${offeringAcademy.name} has made an offer of \$${NumberFormat.compact().format(offerAmount)} for ${player.name}.", type: NewsItemType.TransferOffer, date: _currentDate));
        } else {
             // print(" -> ${offeringAcademy.name} wanted to bid for ${player.name} but couldn't afford \$${offerAmount}."); // Verbose
        }
      }
    }
  }

  // Accept Transfer Offer
  void acceptTransferOffer(Map<String, dynamic> offer) {
    String playerId = offer['playerId']; int offerAmount = offer['offerAmount'];
    String offeringClubId = offer['offeringClubId']; // Get the rival ID

    Player? player = _academyPlayers.firstWhereOrNull((p) => p.id == playerId);
    RivalAcademy? buyingAcademy = _rivalAcademyMap[offeringClubId];

    if (player != null && buyingAcademy != null) {
      // Check if buyer can still afford it (in case their balance changed)
      if (buyingAcademy.balance >= offerAmount) {
          unassignPlayerFromAnyCoach(playerId); // Unassign from player's coach

          // Player academy gains money
          _balance += offerAmount;

          // Buying academy loses money and gains player
          buyingAcademy.balance -= offerAmount;
          // IMPORTANT: Create a *copy* or adjust ID if needed, or handle potential ID conflicts.
          // For now, just add the player object. Consider implications if player IDs aren't globally unique.
          // Let's assume player IDs are unique for now.
          buyingAcademy.players.add(player);

          // Remove player from player's academy
          _academyPlayers.removeWhere((p) => p.id == playerId);

          _transferOffers.removeWhere((o) => o['playerId'] == playerId); // Remove this offer
          _calculateWeeklyWages(); // Recalculate player wages

          print("Accepted transfer offer for ${player.name}. Received $offerAmount. Balance: $_balance");
          print(" -> ${buyingAcademy.name} signed ${player.name}. New Balance: ${buyingAcademy.balance}. Player Count: ${buyingAcademy.players.length}");

          _addNewsItem(NewsItem.create(title: "Transfer Accepted", description: "We accepted the offer of \$${NumberFormat.compact().format(offerAmount)} for ${player.name} from ${offer['offeringClubName']}.", type: NewsItemType.TransferDecision, date: _currentDate));
          notifyListeners();
      } else {
          print("Error: ${buyingAcademy.name} can no longer afford the offer of $offerAmount for ${player.name}. Rejecting offer.");
          rejectTransferOffer(offer); // Reject if they can't afford it anymore
      }
    } else {
        print("Error accepting transfer: Player or Buying Academy not found.");
         _transferOffers.removeWhere((o) => o['playerId'] == playerId); // Remove invalid offer
         notifyListeners();
    }
  }

  void rejectTransferOffer(Map<String, dynamic> offer) {
     _transferOffers.removeWhere((o) => o['playerId'] == offer['playerId']);
     print("Rejected transfer offer for ${offer['playerName']}"); notifyListeners();
  }

  // --- Facility Upgrade Logic ---
  int _calculateFacilityUpgradeCost(int currentLevel) { return (pow(currentLevel, 1.5) * 5000).toInt() + 10000; }

  int getTrainingFacilityUpgradeCost() => _calculateFacilityUpgradeCost(_trainingFacilityLevel);
  int getScoutingFacilityUpgradeCost() => _calculateFacilityUpgradeCost(_scoutingFacilityLevel);
  int getMedicalBayUpgradeCost() => _calculateFacilityUpgradeCost(_medicalBayLevel);

  void _updateStaffCapsFromFacilities() {
    _maxCoaches = 1 + (_trainingFacilityLevel - 1);
    _maxScouts = 1 + (_scoutingFacilityLevel - 1);
    _maxPhysios = 1 + (_medicalBayLevel - 1);

    // print("Updated staff caps: Coaches=$_maxCoaches, Scouts=$_maxScouts, Physios=$_maxPhysios"); // Less verbose
    // Ensure hired staff doesn't exceed new caps (fire excess? prevent hiring?) - For now, just prevents hiring more.
  }

  bool upgradeTrainingFacility() {
    int cost = getTrainingFacilityUpgradeCost();
    if (_balance >= cost) {
      _balance -= cost; _trainingFacilityLevel++;
      _updateStaffCapsFromFacilities();
      print("Upgraded Training Facility to Level $_trainingFacilityLevel. Cost: $cost. Balance: $_balance");
      _addNewsItem(NewsItem.create(title: "Facility Upgraded", description: "Training Facility upgraded to Level $_trainingFacilityLevel. Coach capacity increased to $_maxCoaches.", type: NewsItemType.Facility, date: _currentDate));
      notifyListeners(); return true;
    } else { print("Cannot upgrade Training Facility. Cost: $cost, Balance: $_balance"); return false; }
  }

  bool upgradeScoutingFacility() {
    int cost = getScoutingFacilityUpgradeCost();
    if (_balance >= cost) {
      _balance -= cost; _scoutingFacilityLevel++;
      _updateStaffCapsFromFacilities();
      print("Upgraded Scouting Facility to Level $_scoutingFacilityLevel. Cost: $cost. Balance: $_balance");
       _addNewsItem(NewsItem.create(title: "Facility Upgraded", description: "Scouting Facility upgraded to Level $_scoutingFacilityLevel. Scout capacity increased to $_maxScouts.", type: NewsItemType.Facility, date: _currentDate));
      notifyListeners(); return true;
    } else { print("Cannot upgrade Scouting Facility. Cost: $cost, Balance: $_balance"); return false; }
  }

  bool upgradeMedicalBay() {
    int cost = getMedicalBayUpgradeCost();
    if (_balance >= cost) {
      _balance -= cost; _medicalBayLevel++;
      _updateStaffCapsFromFacilities();
      print("Upgraded Medical Bay to Level $_medicalBayLevel. Cost: $cost. Balance: $_balance");
       _addNewsItem(NewsItem.create(title: "Facility Upgraded", description: "Medical Bay upgraded to Level $_medicalBayLevel. Physio capacity increased to $_maxPhysios.", type: NewsItemType.Facility, date: _currentDate));
      notifyListeners(); return true;
    } else { print("Cannot upgrade Medical Bay. Cost: $cost, Balance: $_balance"); return false; }
  }

  void markAllNewsAsRead() {
    bool changed = false;
    for (var item in _newsItems) { if (!item.isRead) { item.isRead = true; changed = true; } }
    if (changed) { notifyListeners(); }
  }

  void _addNewsItem(NewsItem item) {
    _newsItems.add(item);
    if (_newsItems.length > 100) { // Limit news items
        _newsItems.removeAt(0);
    }
    // print("News Added: ${item.title}"); // Verbose
  }

  // Set Difficulty
  void setDifficulty(Difficulty newDifficulty) {
    if (_difficulty != newDifficulty) {
      print("Changing difficulty from $_difficulty to $newDifficulty");
      _difficulty = newDifficulty;
      // Re-apply settings and repopulate rivals when difficulty changes *during* game setup (e.g., on StartScreen)
      // This might not be the desired behavior if changing mid-game, but essential for setup.
      _applyDifficultySettings();
      _populateRivalAcademyMap();
      notifyListeners();
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
      final gameStateToSave = SerializableGameState(
        currentDate: _currentDate,
        academyName: _academyName,
        academyPlayers: _academyPlayers,
        hiredStaff: _hiredStaff,
        balance: _balance,
        weeklyIncome: _weeklyIncome,
        totalWeeklyWages: _totalWeeklyWages,
        activeTournaments: _activeTournaments,
        completedTournaments: _completedTournaments,
        trainingFacilityLevel: _trainingFacilityLevel,
        scoutingFacilityLevel: _scoutingFacilityLevel,
        medicalBayLevel: _medicalBayLevel,
        academyReputation: _academyReputation,
        newsItems: _newsItems,
        difficulty: _difficulty,
        themeMode: _themeMode,
        rivalAcademies: _rivalAcademies, // Save Rivals
      );
      final jsonMap = gameStateToSave.toJson();
      final jsonString = jsonEncode(jsonMap);

      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefsSaveKey, jsonString);
        print("--- GAME STATE SAVED successfully (Web) ---");
      } else {
        final filePath = await _getSaveFilePath();
        final file = File(filePath);
        await file.writeAsString(jsonString);
        print("--- GAME STATE SAVED successfully to $filePath (Non-Web) ---");
      }
      return true;

    } catch (e, stacktrace) {
      print("--- ERROR SAVING GAME STATE: $e ---");
      print("--- Stacktrace: $stacktrace ---");
      if (kIsWeb && e is UnsupportedError) { print("--- NOTE: File system operations are not supported on web. Using SharedPreferences. ---"); }
      return false;
    }
  }

  Future<bool> loadGame() async {
    try {
      print("--- LOADING GAME STATE ---");
      String? jsonString;

      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        jsonString = prefs.getString(_prefsSaveKey);
        if (jsonString == null || jsonString.isEmpty) { print("--- No save data found (Web) ---"); return false; }
         print("--- Found save data (Web) ---");
      } else {
        final filePath = await _getSaveFilePath();
        final file = File(filePath);
        bool fileExists = await file.exists();
        if (!fileExists) { print("--- No save file found at $filePath (Non-Web) ---"); return false; }
        jsonString = await file.readAsString();
         print("--- Found save data at $filePath (Non-Web) ---");
      }

      if (jsonString == null) { print("--- ERROR: jsonString is null after platform check ---"); return false; }

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      // Check if rivalAcademies data exists in save, handle potential old saves
      if (!jsonMap.containsKey('rivalAcademies')) {
          print("--- Save file is from an older version (missing rivalAcademies). Loading might be incomplete or fail. ---");
          // Optionally, provide default empty list or try to migrate
          jsonMap['rivalAcademies'] = []; // Add empty list to allow parsing
      }
      // Check for leagueStandings in tournaments (older saves)
       if (jsonMap.containsKey('activeTournaments')) {
         List<dynamic> activeT = jsonMap['activeTournaments'];
         for (var tJson in activeT) {
           if (tJson is Map<String, dynamic> && !tJson.containsKey('leagueStandings')) {
             tJson['leagueStandings'] = {}; // Add empty map if missing
           }
           if (tJson is Map<String, dynamic> && !tJson.containsKey('currentByeTeamId')) {
             tJson['currentByeTeamId'] = null; // Add null if missing
           }
         }
       }
       if (jsonMap.containsKey('completedTournaments')) {
         List<dynamic> completedT = jsonMap['completedTournaments'];
         for (var tJson in completedT) {
            if (tJson is Map<String, dynamic> && !tJson.containsKey('leagueStandings')) {
             tJson['leagueStandings'] = {}; // Add empty map if missing
           }
            if (tJson is Map<String, dynamic> && !tJson.containsKey('currentByeTeamId')) {
             tJson['currentByeTeamId'] = null; // Add null if missing
           }
         }
       }

      final loadedState = SerializableGameState.fromJson(jsonMap);

      // Apply loaded state
      _currentDate = loadedState.currentDate;
      _academyName = loadedState.academyName;
      _academyPlayers = loadedState.academyPlayers;
      _hiredStaff = loadedState.hiredStaff;
      _balance = loadedState.balance;
      _weeklyIncome = loadedState.weeklyIncome;
      _totalWeeklyWages = loadedState.totalWeeklyWages;
      _activeTournaments = loadedState.activeTournaments;
      _completedTournaments = loadedState.completedTournaments;
      _trainingFacilityLevel = loadedState.trainingFacilityLevel;
      _scoutingFacilityLevel = loadedState.scoutingFacilityLevel;
      _medicalBayLevel = loadedState.medicalBayLevel;
      _academyReputation = loadedState.academyReputation;
      _newsItems = loadedState.newsItems;
      _difficulty = loadedState.difficulty;
      _themeMode = loadedState.themeMode;
      _rivalAcademies = loadedState.rivalAcademies; // Load Rivals

      // Regenerate/reset transient state
      _scoutedPlayers.clear();
      _transferOffers.clear();
      _generateInitialAvailableStaff(); // Regenerate available staff pool
      _generateInitialTournamentTemplates(); // Regenerate templates
      // Repopulate map from loaded list
      _rivalAcademyMap.clear();
      for (var academy in _rivalAcademies) { _rivalAcademyMap[academy.id] = academy; }
      _updateStaffCapsFromFacilities(); // Recalculate caps based on loaded levels

      print("--- GAME STATE LOADED successfully ---");
      notifyListeners();
      return true;

    } catch (e, stacktrace) { // Catch stacktrace too
      print("--- ERROR LOADING GAME STATE: $e ---");
      print("--- Stacktrace: $stacktrace ---"); // Print stacktrace for debugging
       if (kIsWeb && e is UnsupportedError) { print("--- NOTE: File system operations are not supported on web. Using SharedPreferences. ---"); }
      // Attempt to reset if loading fails catastrophically?
      // resetGame(); // Maybe too drastic?
      return false;
    }
  }
  // --- End Save/Load Logic ---
}
