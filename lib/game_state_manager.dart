import 'package:flutter/foundation.dart'; // For ChangeNotifier and kIsWeb
import 'models/tournament.dart';
import 'models/match.dart';
import 'models/player.dart'; // Import Player model
import 'models/staff.dart'; // Import Staff model
import 'models/rival_academy.dart'; // Correct Import Path
import 'models/ai_club.dart'; // <-- ADD: Import AIClub
import 'models/formation.dart'; // <-- ADD: Import Formation
import 'models/match_event.dart'; // Import MatchEventType
import 'models/news_item.dart';
import 'models/difficulty.dart'; // Import Difficulty enum
import 'dart:math';
import 'dart:collection'; // For UnmodifiableListView and UnmodifiableMapView
import 'package:collection/collection.dart'; // <-- ADD: Import collection
import 'package:flutter/material.dart'; // Import for ThemeMode
import 'package:intl/intl.dart'; // Import for number formatting
import 'utils/name_generator.dart'; // <-- Import NameGenerator

// Import new Services
import 'services/finance_service.dart';
import 'services/time_service.dart';

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

// --- Helper Class for Team Selection ---
class MatchTeamSelection {
  final Formation formation;
  final List<Player> starters;
  final List<Player> bench;

  MatchTeamSelection({required this.formation, required this.starters, required this.bench});
}
// --- End Helper Class ---

class GameStateManager with ChangeNotifier {
  // Services
  final FinanceService _financeService = FinanceService();
  final TimeService _timeService = TimeService();

  // Core Game Time & State
  // DateTime _currentDate = DateTime(2025, 1, 1); // Moved to TimeService
  final Random _random = Random(); // Random number generator
  String _academyName = "My Academy";
  static const String playerAcademyId = 'player_academy_1'; // Unique ID for the player's academy

  // Player & Staff State
  List<Player> _academyPlayers = [];
  List<Staff> _hiredStaff = [];
  List<Player> _scoutedPlayers = []; // Players found by scouts this week
  List<Staff> _availableStaff = [];

  // Financial State - Moved to FinanceService
  // double _balance = 50000.0;
  // int _weeklyIncome = 1000;
  // int _totalWeeklyWages = 0;

  // Tournament State
  List<Tournament> _activeTournaments = []; // Tournaments currently in progress (Scheduled or InProgress)
  List<Tournament> _completedTournaments = []; // Tournaments that have finished
  List<Tournament> _availableTournamentTemplates = []; // Templates for new tournaments

      // Rival Academy Data
      List<RivalAcademy> _rivalAcademies = []; // List of all rival academies
      Map<String, RivalAcademy> _rivalAcademyMap = {}; // Map for quick lookup by ID

      // AI Club Data (Separate from Rivals/Academies)
      List<AIClub> _aiClubs = []; // List of all AI professional clubs
      Map<String, AIClub> _aiClubMap = {}; // Map for quick lookup by ID

      // Facility State (Basic)
  int _trainingFacilityLevel = 1;
  int _scoutingFacilityLevel = 1;
  int _medicalBayLevel = 1;

  // Staff Caps
  int _maxCoaches = 1;
  int _maxScouts = 1;
  int _maxPhysios = 1;
  // int _maxMerchandiseManagers = 0; // Replaced by specific caps below
  int _maxStoreManagers = 0; // 0 if no store, 1 if store exists
  int _maxMatchSalesManagers = 1; // Example: Start with 1, could be upgradable
  // Manager cap (Head Coach/Director) is implicitly 1

  // Merchandise State
  // double _academyMerchStockValue = 0.0; // Moved to FinanceService
  static const double _baseMerchUnitCost = 5.0; // Assumed base cost for a "unit" of merchandise

  // Fans
  int _fans = 100; // Starting fans

  // Facility State (Extended)
  int _merchandiseStoreLevel = 0; // 0 = Not built

  // Reputation
  int _academyReputation = 100;

  // Transfer Offers
  List<Map<String, dynamic>> _transferOffers = [];

  // Coach-Player Assignment Cache (PlayerID -> CoachID)
  // Optimization to allow O(1) lookup of a player's coach
  Map<String, String> _playerCoachMap = {};

  // News Feed
  List<NewsItem> _newsItems = [];

  // Settings
  Difficulty _difficulty = Difficulty.Normal;
  ThemeMode _themeMode = ThemeMode.system;
  int _playerAcademyTier = 0; // 0 = Unranked, 1-3 = Tier

  // Game Status Flags
  bool _isGameOver = false;
  bool _isForcedSellActive = false;

  // --- Getters ---
  bool get isGameOver => _isGameOver;
  bool get isForcedSellActive => _isForcedSellActive;

  DateTime get currentDate => _timeService.currentDate;
  String get academyName => _academyName;
  List<Player> get academyPlayers => UnmodifiableListView(_academyPlayers);
  List<Staff> get hiredStaff => UnmodifiableListView(_hiredStaff);
  List<Player> get scoutedPlayers => UnmodifiableListView(_scoutedPlayers);
  List<Staff> get availableStaff => UnmodifiableListView(_availableStaff);
  double get balance => _financeService.balance;
  int get weeklyIncome => _financeService.weeklyIncome;
  int get totalWeeklyWages => _financeService.totalWeeklyWages;
  List<Tournament> get activeTournaments => UnmodifiableListView(_activeTournaments);
  List<Tournament> get completedTournaments => UnmodifiableListView(_completedTournaments);
  List<Tournament> get availableTournamentTemplates => UnmodifiableListView(_availableTournamentTemplates);
  // Rival Academy Getters
  List<RivalAcademy> get rivalAcademies => UnmodifiableListView(_rivalAcademies);
  Map<String, RivalAcademy> get rivalAcademyMap => UnmodifiableMapView(_rivalAcademyMap);
  // AI Club Getters
  List<AIClub> get aiClubs => UnmodifiableListView(_aiClubs);
  Map<String, AIClub> get aiClubMap => UnmodifiableMapView(_aiClubMap); // <-- ADDED GETTER
  // Facility Getters
  int get trainingFacilityLevel => _trainingFacilityLevel;
  int get scoutingFacilityLevel => _scoutingFacilityLevel;
  int get medicalBayLevel => _medicalBayLevel;
  int get maxCoaches => _maxCoaches;
  int get maxScouts => _maxScouts;
  int get maxPhysios => _maxPhysios;
  // int get maxMerchandiseManagers => _maxMerchandiseManagers; // Replaced
  int get maxStoreManagers => _maxStoreManagers;
  int get maxMatchSalesManagers => _maxMatchSalesManagers;
  double get academyMerchStockValue => _financeService.academyMerchStockValue;
  int get fans => _fans;
  int get merchandiseStoreLevel => _merchandiseStoreLevel;
  int get academyReputation => _academyReputation;
  List<Map<String, dynamic>> get transferOffers => UnmodifiableListView(_transferOffers);
  List<NewsItem> get newsItems => List<NewsItem>.unmodifiable(_newsItems.reversed);
  Difficulty get difficulty => _difficulty;
  ThemeMode get themeMode => _themeMode;
  int get playerAcademyTier => _playerAcademyTier;

  // --- Save File Name / Key ---
  static const String _saveFileName = 'academy_save.json'; // Used for non-web
  static const String _prefsSaveKey = 'gameState'; // Used for web

  GameStateManager() {
    // Initialize services if needed (TimeService defaults to 2025-01-01)
    _applyDifficultySettings(); // Apply difficulty first (Updates FinanceService)
    _generateInitialAvailableStaff();
    _populateRivalAcademyMap(); // Populate rivals based on difficulty
    _populateAIClubs(); // <-- ADD: Populate AI Clubs
    _generateInitialTournamentTemplates(); // Generate tournament templates
    _scheduleInitialProLeagues(); // <-- ADD: Schedule initial leagues
    _calculateWeeklyWages();
    _updateStaffCapsFromFacilities();
    _addInitialMerchandiseManagerToAvailable();
  }

  void _addInitialMerchandiseManagerToAvailable() {
    // Ensure at least one Merchandise Manager is available at the start
    if (!_availableStaff.any((s) => s.role == StaffRole.MerchandiseManager)) {
      _availableStaff.add(
        Staff.randomStaff(
          'staff_${DateTime.now().millisecondsSinceEpoch}_initial_merch',
          StaffRole.MerchandiseManager,
          academyReputation: _academyReputation,
        ),
      );
      // print("Added initial Merchandise Manager to available staff."); // Less verbose
    }
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

  void _rebuildPlayerCoachMap() {
    _playerCoachMap.clear();
    for (var staff in _hiredStaff) {
      if (staff.role == StaffRole.Coach) {
        for (var playerId in staff.assignedPlayerIds) {
          _playerCoachMap[playerId] = staff.id;
        }
      }
    }
  }

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
    int numberOfRivals = 35; // Default number
    if (_difficulty == Difficulty.Hardcore) {
      numberOfRivals = 23; // More rivals in Hardcore
    } //else if (_difficulty == Difficulty.Hard) {
    //  numberOfRivals = 19;
    //}

    _rivalAcademies = List<RivalAcademy>.generate(numberOfRivals, (index) => RivalAcademy.initial(index, difficulty: _difficulty)); // Added <RivalAcademy>

    // Generate initial players for each rival academy
    for (var academy in _rivalAcademies) {
      int initialPlayerCount = 5 + _random.nextInt(6); // 5-10 players initially
      for (int i = 0; i < initialPlayerCount; i++) {
        // --- NEW Player Generation Logic for Rivals ---
        // Aligned more closely with how player's scouted players are generated.
        // Base potential similar to scouted players.
        int basePotential = 30 + _random.nextInt(41); // 30-70

        // Academy's skillLevel acts like a scout's skill for generating initial players.
        // academy.skillLevel ranges from ~16 (Easy) to ~78 (Hardcore).
        // Bonus will range from ~2 to ~11.
        int academySkillBonus = (academy.skillLevel / 7.0).round();

        // Calculate potential skill, similar to Player.randomScoutedPlayer
        int potentialSkill = (basePotential + academySkillBonus).clamp(25, 95); // Clamped 25-95

        // Current skill as a percentage of this new potential.
        // Rivals start with players at 40-80% of their potential.
        int currentSkill = (potentialSkill * (0.4 + _random.nextDouble() * 0.4)).toInt();
        currentSkill = currentSkill.clamp(15, potentialSkill); // Clamp current skill
        // --- END NEW Player Generation Logic ---

        // Use the new factory method to generate player with consistent attributes
        Player newPlayer = Player.createWithTargetSkill(
          id: '${academy.id}_player_$i',
          name: 'Rival Player ${academy.id.split('_').last}-$i',
          age: 15 + _random.nextInt(4),
          naturalPosition: PlayerPosition.values[_random.nextInt(PlayerPosition.values.length)],
          targetSkill: currentSkill,
          potentialSkill: potentialSkill,
          weeklyWage: 50 + _random.nextInt(101),
          reputation: academy.reputation ~/ 5 + _random.nextInt(10),
          // Other fields use defaults or are generated by the factory
        );
        academy.players.add(newPlayer);
      }
      _rivalAcademyMap[academy.id] = academy;
    }
    print("Populated Rival Academy Map with ${_rivalAcademyMap.length} academies.");
  }

  // --- ADD: Populate AI Clubs ---
  void _populateAIClubs() {
    _aiClubs.clear();
    _aiClubMap.clear();
    // Generate AI clubs across tiers (e.g., 10 per tier for 3 tiers)
    int clubsPerTier = 10;
    int numberOfTiers = 3;
    int totalAIClubs = clubsPerTier * numberOfTiers;

    for (int i = 0; i < totalAIClubs; i++) {
        int tier = (i ~/ clubsPerTier) + 1; // Assign tier based on index (1, 2, 3)
        _aiClubs.add(AIClub.initial(i, initialTier: tier));
    }

    // Populate the map
    for (var club in _aiClubs) {
      _aiClubMap[club.id] = club;
      // Generate initial players for AI clubs (similar to rivals, maybe more established?)
      // --- INCREASED PLAYER COUNT: Ensure enough for 11v11 (18 players needed) ---
      int initialPlayerCount = 18 + _random.nextInt(11); // 18-28 players
      // --- END INCREASE ---
      for (int i = 0; i < initialPlayerCount; i++) {
        int potentialSkill = (club.skillLevel * 1.4).toInt() + _random.nextInt(21); // Higher base potential
        potentialSkill = potentialSkill.clamp(1, 99); // Clamp potential
        int currentSkill = (potentialSkill * (0.6 + _random.nextDouble() * 0.3)).toInt(); // 60-90% of potential
        currentSkill = currentSkill.clamp(10, potentialSkill); // Clamp current skill
        PlayerPosition position = PlayerPosition.values[_random.nextInt(PlayerPosition.values.length)]; // Define position

        // Use the new factory method for AI Clubs as well
        club.players.add(
          Player.createWithTargetSkill(
            id: '${club.id}_player_$i',
            name: NameGenerator.generatePlayerName(),
            age: 18 + _random.nextInt(10),
            naturalPosition: position,
            targetSkill: currentSkill,
            potentialSkill: potentialSkill,
            weeklyWage: 200 + _random.nextInt(801),
            reputation: club.reputation ~/ 2 + _random.nextInt(20),
          )
        );
      }
    }
    print("Populated AI Club Map with ${_aiClubMap.length} clubs.");
  }
  // --- END ADD ---

  // Generate Tournament Templates
  void _generateInitialTournamentTemplates() {
    _availableTournamentTemplates.clear();
    // Use the static factory method from Tournament

    // *** ADDED 3v3 Tournament ***
    _availableTournamentTemplates.add(Tournament.createTemplate(
      name: "Kickabout Cup (3v3)",
      type: TournamentType.threeVthree,
      format: TournamentFormat.Knockout, // Added format
      requiredReputation: 0, // Low requirement
      entryFee: 200,
      prizeMoneyBase: 1000,
      numberOfTeams: 32, // Smaller tournament
      // rounds: 3, // Knockout (calculated automatically)
      minTeamsToStart: 4, // Lower minimum to start
    ));

    _availableTournamentTemplates.add(Tournament.createTemplate(
      name: "Local Youth Cup (5v5)",
      type: TournamentType.fiveVfive,
      format: TournamentFormat.Knockout, // Added format
      requiredReputation: 40,
      entryFee: 500,
      prizeMoneyBase: 2000,
      numberOfTeams: 32,
      // rounds: 3, // Knockout (calculated automatically)
    ));
     _availableTournamentTemplates.add(Tournament.createTemplate(
      name: "Regional Junior Cup (7v7)", // Renamed slightly
      type: TournamentType.sevenVseven,
      format: TournamentFormat.Knockout, // Added format
      requiredReputation: 100,
      entryFee: 1000,
      prizeMoneyBase: 5000,
      numberOfTeams: 32,
      // rounds: 3, // Knockout (calculated automatically)
    ));
     _availableTournamentTemplates.add(Tournament.createTemplate(
      name: "National U18 Championship (11v11)",
      type: TournamentType.elevenVeleven,
      format: TournamentFormat.Knockout, // Added format
      requiredReputation: 200,
      entryFee: 2500,
      prizeMoneyBase: 15000,
      numberOfTeams: 70,
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

    // --- NEW: AI Club Focused Leagues ---
    _availableTournamentTemplates.add(Tournament.createTemplate(
      name: "Pro Youth League - Tier 3",
      type: TournamentType.elevenVeleven,
      format: TournamentFormat.League,
      requiredReputation: 150, // Base rep for AI clubs
      youthRepReq: 250, // Higher rep for youth academies to join
      entryFee: 3000,
      prizeMoneyBase: 20000,
      numberOfTeams: 20,
      minTeamsToStart: 8, // Allow slightly fewer teams if needed
      isAIClubFocused: true, // Mark as AI Club focused
    ));
    _availableTournamentTemplates.add(Tournament.createTemplate(
      name: "Pro Youth League - Tier 2",
      type: TournamentType.elevenVeleven,
      format: TournamentFormat.League,
      requiredReputation: 250, // Base rep for AI clubs
      youthRepReq: 400, // Higher rep for youth academies to join
      entryFee: 6000,
      prizeMoneyBase: 40000,
      numberOfTeams: 10,
      minTeamsToStart: 8,
      isAIClubFocused: true,
    ));
    _availableTournamentTemplates.add(Tournament.createTemplate(
      name: "Pro Youth League - Tier 1",
      type: TournamentType.elevenVeleven,
      format: TournamentFormat.League,
      requiredReputation: 400, // Base rep for AI clubs
      youthRepReq: 600, // Very high rep for youth academies to join
      entryFee: 10000,
      prizeMoneyBase: 75000,
      numberOfTeams: 10,
      minTeamsToStart: 8,
      isAIClubFocused: true,
    ));
    // --- END NEW ---

    print("Generated ${_availableTournamentTemplates.length} tournament templates.");
  }

  // Apply Difficulty Settings
  void _applyDifficultySettings() {
     _financeService.applyDifficultySettings(_difficulty);

     // Set reputation based on difficulty
     switch (_difficulty) {
       case Difficulty.Easy: _academyReputation = 30; break;
       case Difficulty.Normal: _academyReputation = 10; break;
       case Difficulty.Hard: _academyReputation = 5; break;
       case Difficulty.Hardcore: _academyReputation = 0; break;
     }
     print("Applied difficulty settings for $_difficulty. Rep=$_academyReputation");
  }

  // Reset Game
  void resetGame() {
    print("--- RESETTING GAME STATE ---");
    _timeService.initialize(DateTime(2025, 1, 1)); // Reset Date
    _academyName = "My Academy";
    // _difficulty = Difficulty.Normal; // Keep selected difficulty or reset? Let's keep it.
    _themeMode = ThemeMode.system;
    _academyPlayers.clear();
    _hiredStaff.clear();
    _scoutedPlayers.clear();
    _availableStaff.clear();
    _applyDifficultySettings(); // Apply difficulty settings (balance, income, rep)
    // _totalWeeklyWages handled by service now
    _activeTournaments.clear();
    _completedTournaments.clear();
    _availableTournamentTemplates.clear(); // Clear templates
    _rivalAcademyMap.clear(); // Clear rival map
    _rivalAcademies.clear(); // Clear rival list
    _aiClubMap.clear(); // <-- ADD: Clear AI Club map
    _aiClubs.clear(); // <-- ADD: Clear AI Club list
    _populateRivalAcademyMap(); // Repopulate rivals based on current difficulty
    _populateAIClubs(); // <-- ADD: Repopulate AI Clubs
    _generateInitialTournamentTemplates(); // Regenerate templates
    _scheduleInitialProLeagues(); // <-- ADD: Schedule initial leagues on reset
    _trainingFacilityLevel = 1;
    _scoutingFacilityLevel = 1;
    _medicalBayLevel = 1;
    _updateStaffCapsFromFacilities();
    // _academyReputation is set in _applyDifficultySettings
    _transferOffers.clear();
    print("--- DEBUG (resetGame): _transferOffers cleared. Length: ${_transferOffers.length} ---");
    _newsItems.clear();
    _playerAcademyTier = 0;
    _merchandiseStoreLevel = 0;
    // _academyMerchStockValue handled by service
    _fans = 100;
    _generateInitialAvailableStaff();
    _addInitialMerchandiseManagerToAvailable(); // Ensure merch manager is available after reset
    _calculateWeeklyWages(); // Updates service

    if (kIsWeb) {
      _clearWebSaveData();
    }

    _rebuildPlayerCoachMap(); // Clear/Rebuild map on reset
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
    if (_isGameOver) {
      print("Cannot advance week. Game Over.");
      return;
    }

    if (_isForcedSellActive && _financeService.balance < 0) {
      print("Cannot advance week. Forced Sell active. Must raise funds.");
      _addNewsItem(NewsItem.create(
        title: "Action Required",
        description: "You must sell players to raise funds before continuing.",
        type: NewsItemType.Finance,
        date: _timeService.currentDate
      ));
      notifyListeners();
      return;
    }

    _timeService.advanceWeek();
    print("Advancing week to: ${_timeService.currentDate}");

    // Merchandise Sales & Fan Updates (before other financial calculations)
    _handleMerchandiseAndFans();

    // 0a. Schedule Annual Pro Leagues (e.g., last week of May)
    // Check if it's May and the day is 22nd or later (covering the last ~10 days)
    if (_timeService.isEndOfSeason()) {
        // Check if leagues for the *current* year have already been scheduled to avoid duplicates
        bool alreadyScheduledThisYear = _activeTournaments.any((t) =>
            t.name.startsWith("Pro Youth League") &&
            t.status == TournamentStatus.Scheduled &&
            t.startDate.year == _timeService.currentDate.year);

        if (!alreadyScheduledThisYear) {
            _scheduleAnnualLeagues(_timeService.currentDate.year);
        }
    }

    // 0b. Check for new *non-Pro League* Tournaments being scheduled (only in first week of month)
    if (_timeService.isFirstWeekOfMonth()) {
      _checkForNewTournaments(); // This function will now ignore Pro Leagues
    }

    // 1. Update Finances (Player)
    double netChange = _financeService.processWeek();

    // Check Bankruptcy Status
    BankruptcyStatus status = _financeService.checkBankruptcyStatus(_difficulty);

    if (status == BankruptcyStatus.GameOver) {
      _isGameOver = true;
      print("GAME OVER: Academy is bankrupt!");
      _addNewsItem(NewsItem.create(
        title: "BANKRUPTCY DECLARED",
        description: "The academy has run out of funds and credit. The board has dissolved the club.",
        type: NewsItemType.Finance,
        date: _timeService.currentDate
      ));
      notifyListeners();
      return;
    }

    if (status == BankruptcyStatus.ForcedSell) {
      _isForcedSellActive = true;
      print("WARNING: Forced player sales required!");
       _addNewsItem(NewsItem.create(
        title: "Financial Crisis",
        description: "We are in debt. The board mandates immediate player sales to balance the books. You cannot continue until you are in the green.",
        type: NewsItemType.Finance,
        date: _timeService.currentDate
      ));
    } else {
      // If status became Safe or Warning, lift the forced sell
      _isForcedSellActive = false;
    }

    if (status == BankruptcyStatus.Warning) {
       _addNewsItem(NewsItem.create(
        title: "Financial Warning",
        description: "We are operating at a loss. Continued debt will lead to bankruptcy.",
        type: NewsItemType.Finance,
        date: _timeService.currentDate
      ));
    }

    // 2. Scouting Logic (Player)
    _scoutedPlayers.clear(); // Clear previous week's finds first
    final activeScouts = _hiredStaff.where((s) => s.role == StaffRole.Scout && s.isAssigned).toList();
    int playersFoundThisWeekByAllScouts = 0;
    const int maxScoutedPlayersCap = 20; // Max players to keep in the scouted list

    if (activeScouts.isNotEmpty) {
      for (var scout in activeScouts) {
        // Chance for a scout to find *any* players this week
        // Base chance + scout skill bonus + facility bonus
        double baseFindChance = 0.3; // 30% base chance
        double scoutSkillBonus = scout.skill / 200.0; // Max 0.5 for 100 skill
        double facilityBonus = _scoutingFacilityLevel / 20.0; // Max 0.25 for level 5 (assuming max level 5 for now)
        double findChance = (baseFindChance + scoutSkillBonus + facilityBonus).clamp(0.1, 0.9); // Clamp chance

        if (_random.nextDouble() < findChance) {
          // Number of players this scout finds (1, maybe more for high skill/facility)
          int numPlayersFoundByScout = 1;
          // Example: Higher skill/facility increases chance of finding more than one player
          if (scout.skill > 70 && _scoutingFacilityLevel > 2 && _random.nextDouble() < 0.3) {
            numPlayersFoundByScout++;
          }
          if (scout.skill > 85 && _scoutingFacilityLevel > 3 && _random.nextDouble() < 0.2) {
            numPlayersFoundByScout++; // Rare chance for a third player
          }

          for (int i = 0; i < numPlayersFoundByScout; i++) {
            // Add to a temporary list first if we want to strictly cap _scoutedPlayers after sorting
            // For now, add directly and then trim if over a larger buffer before final trim.
            // This ensures we don't miss out on potentially good players if many are found.
            // A simpler approach is to cap additions if _scoutedPlayers is already large.
            if (_scoutedPlayers.length < (maxScoutedPlayersCap + 10)) { // Allow a buffer before sorting and final trim
              final newPlayerId = 'scouted_${_timeService.currentDate.millisecondsSinceEpoch}_${scout.id}_$i';
              // Use the scout's skill to influence player generation
              Player newPlayer = Player.randomScoutedPlayer(newPlayerId, scoutSkill: scout.skill);
              _scoutedPlayers.add(newPlayer);
              playersFoundThisWeekByAllScouts++;
            } else {
              break; // Stop this scout if the buffer is full
            }
          }
        }
      }

      if (_scoutedPlayers.isNotEmpty) {
        // Sort by potential (desc) then current skill (desc)
        _scoutedPlayers.sort((a, b) {
          int potCompare = b.potentialSkill.compareTo(a.potentialSkill);
          if (potCompare != 0) return potCompare;
          return b.currentSkill.compareTo(a.currentSkill);
        });

        // Trim to maxScoutedPlayersCap
        if (_scoutedPlayers.length > maxScoutedPlayersCap) {
          _scoutedPlayers.removeRange(maxScoutedPlayersCap, _scoutedPlayers.length);
        }
      }
    }

    if (playersFoundThisWeekByAllScouts > 0) {
       _addNewsItem(NewsItem.create(
           title: "Scouting Report",
           description: "Our scouts have identified $playersFoundThisWeekByAllScouts potential new talent${playersFoundThisWeekByAllScouts > 1 ? 's' : ''} this week.",
           type: NewsItemType.Scouting,
           date: _timeService.currentDate));
    } else if (activeScouts.isNotEmpty) { // Only report "no players found" if scouts were active
       _addNewsItem(NewsItem.create(
           title: "Scouting Report",
           description: "Scouts found no notable players this week despite their efforts.",
           type: NewsItemType.Scouting,
           date: _timeService.currentDate));
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

    // 8. AI Club Weekly Actions (NEW)
    _handleAIClubActions();

    // 9. Other weekly events (Player Finance Summary)
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    _addNewsItem(NewsItem.create(
      title: "Weekly Finances",
      description: "Income: ${currencyFormat.format(_financeService.weeklyIncome)}, Wages: ${currencyFormat.format(_financeService.totalWeeklyWages)}. Net: ${currencyFormat.format(netChange)}. Balance: ${currencyFormat.format(_financeService.balance)}",
      type: NewsItemType.Finance,
      date: _timeService.currentDate
    ));

    // 9. Notify Listeners
    notifyListeners();
  }

  // Check for New Tournaments
  void _checkForNewTournaments() {
    // Run only in the first week of the month (Logic handled by caller or kept here for safety)
    if (!_timeService.isFirstWeekOfMonth()) return;

    print("Checking for new tournaments to schedule...");
    int tournamentsScheduledThisMonth = 0;
    bool forcedAttempt = false; // Flag to ensure at least one attempt if random fails

    // Shuffle templates to vary which ones are considered first
    List<Tournament> shuffledTemplates = List.from(_availableTournamentTemplates)..shuffle(_random);

    for (var template in shuffledTemplates) {
      // --- NEW: Skip Pro Leagues in this check ---
      if (template.name.startsWith("Pro Youth League")) {
        // print(" -> Skipping ${template.name} (handled by annual scheduling)."); // Optional verbose print
        continue;
      }
      // --- END NEW ---

      // Check if an instance of this template is already scheduled or in progress
      bool alreadyActive = _activeTournaments.any((t) => t.baseId == template.id && (t.status == TournamentStatus.Scheduled || t.status == TournamentStatus.InProgress));
      if (alreadyActive) {
        print(" -> Instance of ${template.name} already active. Skipping.");
        continue;
      }

      // *** INCREASED CHANCE: Higher base chance, less dependent on rep ***
      double baseChance = (template.format == TournamentFormat.League) ? 0.50 : 0.80; // Lower chance for league (Increased from 0.25 / 0.50)
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

        List<String> participants = [];
        bool enoughParticipantsFound = false;

        // --- NEW: AI Club Focused League Logic ---
        if (template.isAIClubFocusedLeague) {
          print(" -> Applying AI Club Focused Logic for ${template.name}");

          // 1. Gather Eligible AI Clubs (Based on CURRENT TIER for T1/T2)
          int leagueTier = template.getLeagueTier(); // Helper method needed in Tournament model
          List<AIClub> eligibleAIClubs;

          if (leagueTier == 1 || leagueTier == 2) {
            // For Tier 1 & 2, only clubs *currently* in that tier are eligible
            eligibleAIClubs = _aiClubs.where((club) =>
                club.tier == leagueTier && // MUST be in the correct tier
                club.balance >= template.entryFee &&
                club.players.length >= template.requiredPlayers &&
                !club.activeTournamentIds.any((tId) => _activeTournaments.any((at) => at.id == tId))
            ).toList();
            print(" -> Tier $leagueTier League: Filtering for clubs currently in Tier $leagueTier.");
          } else {
            // For Tier 3 (or if tier unknown), use reputation as the primary filter (entry point)
            eligibleAIClubs = _aiClubs.where((club) =>
                (club.tier == 3 || club.tier == 0) && // Allow Tier 3 or unassigned tier
                club.reputation >= template.requiredReputation &&
                club.balance >= template.entryFee &&
                club.players.length >= template.requiredPlayers &&
                !club.activeTournamentIds.any((tId) => _activeTournaments.any((at) => at.id == tId))
            ).toList();
             print(" -> Tier 3 League: Filtering for Tier 3/unassigned clubs meeting reputation req.");
          }

          eligibleAIClubs.sort((a, b) => b.reputation.compareTo(a.reputation)); // Sort by reputation desc

          // 2. Gather Eligible Youth Academies (Rivals + Player) - Only for Tier 3? Or allow based on high rep?
          // For now, let's restrict Youth Academies primarily to Tier 3 league, unless their rep is very high for T2. T1 is AI Pro only.
          List<dynamic> eligibleYouthAcademies = []; // Use dynamic list
          bool playerEligible = false;
          int youthRepReq = template.youthAcademyMinReputation ?? template.requiredReputation; // Use specific youth req if available

          if (leagueTier == 3 || (leagueTier == 2 && youthRepReq >= 400)) { // Allow high-rep youth in T2
             // Rivals
             eligibleYouthAcademies.addAll(_rivalAcademies.where((rival) =>
                 rival.reputation >= youthRepReq &&
                 rival.balance >= template.entryFee &&
                 rival.players.length >= template.requiredPlayers &&
                 !rival.activeTournamentIds.any((tId) => _activeTournaments.any((at) => at.id == tId))
             ));

             // Player (Check eligibility but don't add yet)
             playerEligible = _academyReputation >= youthRepReq &&
                                   _financeService.canAfford(template.entryFee.toDouble()) &&
                                   _academyPlayers.length >= template.requiredPlayers &&
                                   !_activeTournaments.any((at) => at.teamIds.contains(playerAcademyId));

             eligibleYouthAcademies.sort((a, b) => b.reputation.compareTo(a.reputation)); // Sort by reputation desc
             print(" -> Found ${eligibleAIClubs.length} eligible AI Clubs and ${eligibleYouthAcademies.length} eligible Youth Academies (Player eligible: $playerEligible) for Tier $leagueTier League.");
          } else if (leagueTier == 1) {
             print(" -> Tier 1 League: Only AI Clubs are eligible.");
             // eligibleYouthAcademies remains empty, playerEligible remains false
          } else {
             print(" -> Tier $leagueTier League: Youth academies not eligible based on current rules.");
             // eligibleYouthAcademies remains empty, playerEligible remains false
          }

          // 3. Fill Slots (Prioritize AI Clubs)
          int slotsToFill = template.numberOfTeams;
          if (playerEligible) {
            slotsToFill--; // Reserve a slot for the player if they are eligible
          }

          // Add top AI Clubs first
          for (var club in eligibleAIClubs) {
            if (participants.length >= slotsToFill) break;
            participants.add(club.id);
          }
          print(" -> Added ${participants.length} AI Clubs.");

          // Add top Youth Academies if slots remain
          int aiClubsAdded = participants.length;
          for (var academy in eligibleYouthAcademies) {
            if (participants.length >= slotsToFill) break;
            // Ask rival if they want to join (AI clubs join automatically if selected)
            if (academy is RivalAcademy && academy.shouldEnterTournament(template, _timeService.currentDate.year, _timeService.currentDate.month)) {
               participants.add(academy.id);
            }
            // Player doesn't get added here, only eligibility is checked
          }
          print(" -> Added ${participants.length - aiClubsAdded} Youth Academies.");

          // 4. Check if minimum met (considering potential player join)
          int minRequired = template.minTeamsToStart;
          if (playerEligible) minRequired--; // Player can potentially fill one slot

          if (participants.length >= minRequired) {
            enoughParticipantsFound = true;
          } else {
             print(" -> Not enough participants (${participants.length}) for AI Focused League ${template.name}. Min required (allowing for player): $minRequired");
          }

        }
        // --- END AI Club Focused Logic ---
        // --- ELSE: Standard Tournament Logic (Rivals Only Initially) ---
        else {
          // Find potential rival participants
          List<RivalAcademy> potentialRivals = _rivalAcademies.where((rival) =>
              rival.reputation >= template.requiredReputation &&
              rival.balance >= template.entryFee &&
              rival.players.length >= template.requiredPlayers &&
              !rival.activeTournamentIds.any((tId) => _activeTournaments.any((at) => at.id == tId)) // Not already in an active one
          ).toList();
          potentialRivals.shuffle(_random);

          // Try to fill up to numberOfTeams, but require at least minTeamsToStart
          for (var rival in potentialRivals) {
            if (participants.length >= template.numberOfTeams) break;
            // Ask rival if they want to join
            if (rival.shouldEnterTournament(template, _timeService.currentDate.year, _timeService.currentDate.month)) {
              participants.add(rival.id);
            }
          }

          // Check if minimum met (considering potential player join)
          int minRequired = template.minTeamsToStart;
          // Player eligibility check for standard tournaments
          bool playerEligible = _academyReputation >= template.requiredReputation &&
                                _financeService.canAfford(template.entryFee.toDouble()) &&
                                _academyPlayers.length >= template.requiredPlayers &&
                                !_activeTournaments.any((at) => at.teamIds.contains(playerAcademyId));

          if (playerEligible) minRequired--; // Player can potentially fill one slot

          if (participants.length >= minRequired) {
            enoughParticipantsFound = true;
          } else {
            print(" -> Not enough potential participants (${participants.length}) for Standard Tournament ${template.name}. Min required (allowing for player): $minRequired");
          }
        }
        // --- END Standard Tournament Logic ---

        // --- Create Instance if Enough Participants Found ---
        if (enoughParticipantsFound) {
          Tournament newTournament = Tournament.fromTemplate(template, participants, _timeService.currentDate);
          addActiveTournament(newTournament); // Adds to _activeTournaments with Scheduled status

          // Mark participants as active in this tournament
          for (var participantId in participants) {
            if (_rivalAcademyMap.containsKey(participantId)) {
              _rivalAcademyMap[participantId]?.activeTournamentIds.add(newTournament.id);
            } else if (_aiClubMap.containsKey(participantId)) {
              _aiClubMap[participantId]?.activeTournamentIds.add(newTournament.id);
            }
          }

          String joinWindow = (template.format == TournamentFormat.League)
              ? "You have until the end of the season to join."
              : "You have until next week to join.";
          _addNewsItem(NewsItem.create(
              title: "New Tournament Scheduled",
              description: "The ${newTournament.name} is scheduled to start on ${DateFormat.yMMMd().format(newTournament.startDate)} with ${participants.length} teams confirmed so far. $joinWindow",
              type: NewsItemType.Tournament,
              date: _timeService.currentDate
          ));
          tournamentsScheduledThisMonth++;
          print(" -> Scheduled ${newTournament.name} (ID: ${newTournament.id}) starting ${DateFormat.yMMMd().format(newTournament.startDate)} with ${participants.length} teams.");
        }
        // --- END Create Instance ---

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
        // Rival player training uses the new train method
        // Simplified chance for rivals: if random < effectiveness, try to train.
        // The train() method itself handles if an attribute can be improved.
        if (player.currentSkill < player.potentialSkill) { // Check if there's room to improve overall
            double improveChance = 0.02 * trainingEffectiveness; // Low base chance
            if (_random.nextDouble() < improveChance) {
                player.train(); // Call the train method
                // No direct print here, train() doesn't return skill, but updates affinities
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
  // --- END Rival Academy Actions ---

  // --- NEW: Handle AI Club Actions ---
  void _handleAIClubActions() {
    // print("--- Handling AI Club Weekly Actions ---"); // Less verbose
    // List<Match> matchesThisWeek = _getMatchesPlayedThisWeek(); // Helper needed

    for (var club in _aiClubs) {
      // 1. Financial Simulation (Income/Expenses)
      double matchdayIncome = 0;
      // TODO: Calculate matchday income based on home games this week, fans, ticket price
      // int homeGamesThisWeek = matchesThisWeek.where((m) => m.homeTeamId == club.id && !m.matchDate.isAfter(_currentDate)).length;
      // matchdayIncome = homeGamesThisWeek * club.fanCount * club.ticketPrice * 0.5; // Example: 50% attendance

      // Placeholder income/sponsorship - INCREASED VALUES SIGNIFICANTLY
      // Increased base multiplier and tier bonuses to better cover wages
      double baseWeeklyIncome = (club.reputation * 50) // Increased from 10
                              + (club.skillLevel * 100) // Increased from 20
                              + (club.tier == 1 ? 20000 : (club.tier == 2 ? 10000 : 5000)); // Increased tier bonuses
      double aiWeeklyWages = club.players.fold(0.0, (sum, p) => sum + p.weeklyWage);

      club.balance += baseWeeklyIncome + matchdayIncome;
      club.balance -= aiWeeklyWages;
      club.balance = max(0, club.balance); // Prevent negative balance for now

      // 2. Fan Count Fluctuation
      // TODO: Adjust fan count based on results, reputation, league position

      // 3. Transfer Logic (Offers for Players)
      // TODO: AI identifies transfer targets (player academy, rivals, other AI)
      // TODO: AI decides offer amount based on value and budget
      // TODO: AI makes offers (add to a central offer list or handle directly?)
      // --- START AI CLUB PLAYER ACQUISITION LOGIC ---
      double transferActivityChance = 0.10 + ((4 - club.tier) * 0.05); // Tier 1: 25%, Tier 2: 20%, Tier 3: 15%
      bool alreadyMadeOfferThisWeekByThisClub = _transferOffers.any((o) => o['offeringClubId'] == club.id && o['dateEpoch'] == _timeService.currentDate.millisecondsSinceEpoch);

      if (!alreadyMadeOfferThisWeekByThisClub && _random.nextDouble() < transferActivityChance) {
        // A. Assess Squad Needs
        Map<String, int> desiredCountsPerGroup = {
          "GK": 2,
          "DEF": club.tier == 1 ? 6 : 5, // Adjusted counts for generic positions
          "MID": club.tier == 1 ? 7 : 6, // Adjusted counts
          "FWD": club.tier == 1 ? 3 : 2, // Adjusted counts
        };
        Map<String, PlayerPosition> positionGroups = { // Simplified to single PlayerPosition per group
          "GK": PlayerPosition.Goalkeeper,
          "DEF": PlayerPosition.Defender,
          "MID": PlayerPosition.Midfielder,
          "FWD": PlayerPosition.Forward,
        };

        List<PlayerPosition> neededPositions = []; // Renamed from neededSpecificPositions
        positionGroups.forEach((groupName, positionInGroup) {
          int currentCountInGroup = club.players.where((p) => p.naturalPosition == positionInGroup).length;
          int desiredCountForThisGroup = desiredCountsPerGroup[groupName] ?? 0;
          if (currentCountInGroup < desiredCountForThisGroup) {
            neededPositions.add(positionInGroup); // Add the single position
          }
        });

        // If no specific positional need but squad is generally small, look for any good player
        if (neededPositions.isEmpty && club.players.length < (club.tier == 1 ? 22 : (club.tier == 2 ? 20 : 18)) ) {
          neededPositions.addAll(PlayerPosition.values); // Consider all generic positions
        }

        if (neededPositions.isNotEmpty) {
          neededPositions.shuffle(_random);

          // B. Identify Potential Targets
          List<Map<String, dynamic>> potentialTargetsData = [];

          // B1. From Player's Academy
          for (var player in _academyPlayers) {
            PlayerPosition targetPos = player.naturalPosition; // Use natural position directly
            if (neededPositions.contains(targetPos)) { // Check against the list of needed generic positions
              if (player.age < 23 &&
                  player.potentialSkill > (club.skillLevel * 0.7 + (3 - club.tier) * 5) &&
                  club.balance > player.calculateMarketValue() * 0.5) { // Initial affordability check
                if (!_transferOffers.any((o) => o['playerId'] == player.id && o['offeringClubId'] == club.id)) {
                  potentialTargetsData.add({'player': player, 'ownerId': playerAcademyId, 'ownerName': _academyName, 'position': targetPos});
                }
              }
            }
          }

          // B2. From Rival Academies
          for (var rivalAcademy in _rivalAcademies) {
            for (var player in rivalAcademy.players) {
              PlayerPosition targetPos = player.naturalPosition; // Use natural position directly
              if (neededPositions.contains(targetPos)) { // Check against the list of needed generic positions
                if (player.age < 21 && // Stricter age for rival players
                    player.potentialSkill > (club.skillLevel * 0.65 + (3 - club.tier) * 5) &&
                    club.balance > player.calculateMarketValue() * 0.5) { // Initial affordability check
                  // Check if an offer from this club for this player (from this rival) already exists and is recent
                  bool existingOfferToRival = _transferOffers.any((o) =>
                      o['playerId'] == player.id &&
                      o['offeringClubId'] == club.id &&
                      o['sellingClubId'] == rivalAcademy.id && // Ensure it's for this specific rival
                      o['dateEpoch'] == _timeService.currentDate.millisecondsSinceEpoch); // Check for offer made this exact week

                  if (!existingOfferToRival) { // Only add if no recent offer to this rival for this player
                    potentialTargetsData.add({'player': player, 'ownerId': rivalAcademy.id, 'ownerName': rivalAcademy.name, 'position': targetPos});
                  }
                }
              }
            }
          }

          // B3. From Other AI Clubs
          for (var otherAIClub in _aiClubs) {
            if (otherAIClub.id == club.id) continue; // Don't target self

            for (var player in otherAIClub.players) {
              PlayerPosition targetPos = player.naturalPosition;
              if (neededPositions.contains(targetPos)) {
                // AI clubs might be more willing to buy slightly older/established players from other AIs
                if (player.age < 28 && // Broader age range
                    player.currentSkill > (club.skillLevel * 0.8 + (3 - club.tier) * 3) && // Target slightly better or comparable players
                    player.potentialSkill > (club.skillLevel * 0.7) &&
                    club.balance > player.calculateMarketValue() * 0.6) { // Affordability
                  // Check if an offer from this club for this player (from this other AI club) already exists and is recent
                  bool existingOfferToAI = _transferOffers.any((o) =>
                      o['playerId'] == player.id &&
                      o['offeringClubId'] == club.id &&
                      o['sellingClubId'] == otherAIClub.id && // Ensure it's for this specific AI club
                      o['dateEpoch'] == _timeService.currentDate.millisecondsSinceEpoch);

                  if (!existingOfferToAI) {
                    potentialTargetsData.add({
                      'player': player,
                      'ownerId': otherAIClub.id,
                      'ownerName': otherAIClub.name,
                      'position': targetPos
                    });
                  }
                }
              }
            }
          }

          if (potentialTargetsData.isNotEmpty) {
            potentialTargetsData.sort((a, b) {
              Player pA = a['player'] as Player; Player pB = b['player'] as Player;
              int potCompare = pB.potentialSkill.compareTo(pA.potentialSkill);
              if (potCompare != 0) return potCompare;
              int ageCompare = pA.age.compareTo(pB.age);
              if (ageCompare != 0) return ageCompare;
              return pB.currentSkill.compareTo(pA.currentSkill);
            });

            var targetData = potentialTargetsData.first;
            Player targetPlayer = targetData['player'] as Player;
            String targetPlayerOwnerId = targetData['ownerId'] as String;
            String targetPlayerOwnerName = targetData['ownerName'] as String;
            // PlayerPosition targetedPosition = targetData['position'] as PlayerPosition; // For future use if needed

            int marketValue = targetPlayer.calculateMarketValue();
            double offerMultiplierMin = 0.7;
            double offerMultiplierMax = 1.3;
            if (club.tier == 1) { offerMultiplierMin = 0.85; offerMultiplierMax = 1.6; }
            else if (club.tier == 2) { offerMultiplierMin = 0.8; offerMultiplierMax = 1.45; }
            double potentialGapBonus = ((targetPlayer.potentialSkill - targetPlayer.currentSkill) / 50.0).clamp(0.0, 0.3);
            offerMultiplierMax += potentialGapBonus;

            double offerMultiplier = offerMultiplierMin + _random.nextDouble() * (offerMultiplierMax - offerMultiplierMin);
            int offerAmount = (marketValue * offerMultiplier).round();
            offerAmount = (offerAmount ~/ 100) * 100;
            offerAmount = max(500, offerAmount);

            if (club.balance >= offerAmount) {
              _transferOffers.add({
                'playerId': targetPlayer.id,
                'playerName': targetPlayer.name,
                'offeringClubName': club.name,
                'offeringClubId': club.id,
                'offerAmount': offerAmount,
                'isAIClubOffer': true,
                'sellingClubId': targetPlayerOwnerId,
                'sellingClubName': targetPlayerOwnerName,
                'dateEpoch': _timeService.currentDate.millisecondsSinceEpoch,
              });
              // print("AI Club ${club.name} (Tier ${club.tier}) made an offer of ${NumberFormat.compactCurrency(symbol: '\$').format(offerAmount)} for ${targetPlayer.name} (Pot: ${targetPlayer.potentialSkill}, Age: ${targetPlayer.age}) from $targetPlayerOwnerName. MV: ${NumberFormat.compactCurrency(symbol: '\$').format(marketValue)}");

              // --- DEBUG: Log AI-to-AI or AI-to-Rival offers (REMOVED) ---
              // if (targetPlayerOwnerId != playerAcademyId) {
              //   String ownerType = _rivalAcademyMap.containsKey(targetPlayerOwnerId) ? "Rival Academy" : (_aiClubMap.containsKey(targetPlayerOwnerId) ? "AI Club" : "Unknown Owner");
              //   print("--- DEBUG (AI Offer for Non-Player): AI Club ${club.name} (ID: ${club.id}) offered for ${targetPlayer.name} (Player ID: ${targetPlayer.id}) from $targetPlayerOwnerName ($ownerType ID: $targetPlayerOwnerId). Amount: $offerAmount ---");
              // }
              // --- END DEBUG ---

              if (targetPlayerOwnerId == playerAcademyId) {
                _addNewsItem(NewsItem.create(
                  title: "Transfer Offer Received",
                  description: "${club.name} has made an offer of ${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(offerAmount)} for your player ${targetPlayer.name}.",
                  type: NewsItemType.TransferOffer,
                  date: _timeService.currentDate
                ));
              }
              // TODO: Later, add logic for rival academies to react to these offers in _handleRivalAcademyActions
            }
          }
        }
      }
      // --- END AI CLUB PLAYER ACQUISITION LOGIC ---

      // 4. Transfer Logic (Responding to Offers)
      // TODO: AI decides whether to accept/reject offers for their own players (i.e. if another AI club bids for their player)

      // 5. Player Training/Development (Simplified)
      // TODO: Basic skill improvement chance for AI players (similar to rivals?)
      // Player development for AI clubs is significantly slower than academies.
      double trainingEffectiveness = (club.skillLevel / 100.0); // Simple skill-based training
      for (var player in club.players) {
        // AI club player training uses the new train method
        if (player.currentSkill < player.potentialSkill) { // Check if there's room to improve overall
            // Reduced improvement chance for AI clubs
            double improveChance = 0.002 * trainingEffectiveness; // Was 0.015, significantly reduced
            if (_random.nextDouble() < improveChance) {
                // AI clubs train less effectively, maybe only 1 attribute point if successful
                player.train(improvementAmount: 1);
            }
        }
        // Simple fatigue recovery for AI club players
        player.fatigue = (player.fatigue - (5.0 + (player.stamina / 15.0))).clamp(0.0, 100.0);
      }

      // 6. Recalculate Skill Level periodically
      if (_timeService.currentDate.weekday == DateTime.monday) { // Example: Recalculate weekly
          club.updateSkillLevel();
      }
    }
  }
  // --- END AI Club Actions ---

  // --- State Modification Methods ---
  void _calculateWeeklyWages() {
    int staffWages = _hiredStaff.fold(0, (sum, staff) => sum + staff.weeklyWage);
    int playerWages = _academyPlayers.fold(0, (sum, player) => sum + player.weeklyWage);
    _financeService.updateWeeklyWages(staffWages + playerWages);
  }

  bool hireStaff(Staff staffToHire) {
    int currentCount = _hiredStaff.where((s) => s.role == staffToHire.role).length;
    bool canHire = true;
    String? reason;
    int totalMerchManagerCap = _maxStoreManagers + _maxMatchSalesManagers;

    switch (staffToHire.role) {
      case StaffRole.Manager: if (currentCount >= 1) { canHire = false; reason = "Only one Manager allowed."; } break;
      case StaffRole.Coach: if (currentCount >= _maxCoaches) { canHire = false; reason = "Coach limit reached ($_maxCoaches). Upgrade Training Facility."; } break;
      case StaffRole.Scout: if (currentCount >= _maxScouts) { canHire = false; reason = "Scout limit reached ($_maxScouts). Upgrade Scouting Facility."; } break;
      case StaffRole.Physio: if (currentCount >= _maxPhysios) { canHire = false; reason = "Physio limit reached ($_maxPhysios). Upgrade Medical Bay."; } break;
      case StaffRole.MerchandiseManager: if (currentCount >= totalMerchManagerCap) { canHire = false; reason = "Merchandise Manager limit reached ($totalMerchManagerCap). Upgrade Merchandise Store for more Store Managers."; } break;
    }

    if (!canHire) { print("Cannot hire ${staffToHire.name}. Reason: $reason"); return false; }

    _hiredStaff.add(staffToHire);
    _availableStaff.removeWhere((s) => s.id == staffToHire.id);
    _calculateWeeklyWages();
    _addNewsItem(NewsItem.create(title: "Staff Hired", description: "We have hired ${staffToHire.name} as our new ${staffToHire.role.toString().split('.').last}.", type: NewsItemType.StaffChange, date: _timeService.currentDate));
    notifyListeners();
    print("Hired ${staffToHire.name}");
    return true;
  }

  void fireStaff(Staff staffToFire) {
    // Ensure the staff member exists in the hired list
    if (!_hiredStaff.any((s) => s.id == staffToFire.id)) {
      print("Error: Cannot fire staff ${staffToFire.name} (ID: ${staffToFire.id}). Not found in hired staff.");
      return;
    }

    // If firing a coach, unassign their players first
    if (staffToFire.role == StaffRole.Coach) {
      List<String> playersToUnassign = List.from(staffToFire.assignedPlayerIds); // Copy list to avoid modification issues
      for (String playerId in playersToUnassign) {
        unassignPlayerFromCoach(playerId, staffToFire.id); // Use existing method
        print(" -> Unassigned player ID $playerId from fired coach ${staffToFire.name}");
      }
    }

    _hiredStaff.removeWhere((s) => s.id == staffToFire.id);
    _calculateWeeklyWages(); // Recalculate wages after firing
    _addNewsItem(NewsItem.create(
      title: "Staff Fired",
      description: "We have parted ways with ${staffToFire.name} (${staffToFire.role.toString().split('.').last}).",
      type: NewsItemType.StaffChange,
      date: _timeService.currentDate
    ));
    print("Fired ${staffToFire.name}.");
    notifyListeners();
    // Optional: Add the fired staff back to the available pool? For now, just remove.
    // _availableStaff.add(staffToFire);
  }

  void signPlayer(Player playerToSign) {
    playerToSign.isScouted = false;
    _academyPlayers.add(playerToSign);
    _scoutedPlayers.removeWhere((p) => p.id == playerToSign.id);
    _calculateWeeklyWages();
    _addNewsItem(NewsItem.create(title: "Player Signed", description: "We have signed the promising young player ${playerToSign.name} to the academy.", type: NewsItemType.PlayerSigned, date: _timeService.currentDate));
    print("Signed ${playerToSign.name}");

    Staff? availableCoach = _hiredStaff.firstWhereOrNull( (s) => s.role == StaffRole.Coach && s.assignedPlayerIds.length < s.maxPlayersTrainable );
    if (availableCoach != null) {
      assignPlayerToCoach(playerToSign.id, availableCoach.id); // Use the method
      print("Automatically assigned ${playerToSign.name} to coach ${availableCoach.name}.");
      _addNewsItem(NewsItem.create(title: "Player Assigned", description: "${playerToSign.name} has been automatically assigned to Coach ${availableCoach.name} for training.", type: NewsItemType.Training, date: _timeService.currentDate));
    } else { print("No coaches with available capacity found for ${playerToSign.name}."); }
    notifyListeners();
  }

  void rejectPlayer(Player playerToReject) {
    _scoutedPlayers.removeWhere((p) => p.id == playerToReject.id);
    notifyListeners();
    print("Rejected ${playerToReject.name}");
  }

  void releasePlayer(Player playerToRelease) {
    // Ensure the player exists in the academy list
    if (!_academyPlayers.any((p) => p.id == playerToRelease.id)) {
      print("Error: Cannot release player ${playerToRelease.name} (ID: ${playerToRelease.id}). Not found in academy.");
      return;
    }

    // Unassign player from any coach
    unassignPlayerFromAnyCoach(playerToRelease.id);

    _academyPlayers.removeWhere((p) => p.id == playerToRelease.id);
    _calculateWeeklyWages(); // Recalculate wages after release
    _addNewsItem(NewsItem.create(
      title: "Player Released",
      description: "We have released ${playerToRelease.name} from the academy.",
      type: NewsItemType.PlayerSigned, // Using PlayerSigned for now, maybe add PlayerReleased later?
      date: _timeService.currentDate
    ));
    print("Released ${playerToRelease.name}.");
    notifyListeners();
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
    if (!_financeService.canAfford(template.entryFee.toDouble())) {
      print(" -> Failed: Not enough balance (${_financeService.balance}/${template.entryFee})");
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
    _financeService.deductExpense(template.entryFee.toDouble()); // Deduct entry fee
    scheduledInstance.teamIds.add(playerAcademyId); // Add player to participants
    // If league, add player to standings
    if (scheduledInstance.format == TournamentFormat.League) {
        scheduledInstance.leagueStandings[playerAcademyId] = LeagueStanding(teamId: playerAcademyId);
    }
    print(" -> Success: Joined scheduled tournament instance ${scheduledInstance.id}. Deducted fee: ${template.entryFee}. New balance: ${_financeService.balance}.");
    _addNewsItem(NewsItem.create(title: "Tournament Joined", description: "Successfully joined the upcoming ${template.name}.", type: NewsItemType.Tournament, date: _timeService.currentDate));

    // 5. Notify and Return
    notifyListeners();
    return true;
  }
  // --- End Try Join Tournament ---

  // Simulate Matches & Handle Tournament State Changes
  void _simulateMatchesForWeek() {
    DateTime startOfWeek = _timeService.currentDate.subtract(const Duration(days: 7));
    DateTime endOfWeek = _timeService.currentDate;
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
                    _financeService.addIncome(tournament.entryFee.toDouble());
                    print(" -> Refunded entry fee ${tournament.entryFee} to player.");
                }
                for (var rivalId in tournament.teamIds) {
                    if (rivalId != playerAcademyId) {
                        _rivalAcademyMap[rivalId]?.balance += tournament.entryFee;
                        _rivalAcademyMap[rivalId]?.activeTournamentIds.remove(tournament.id);
                    }
                }
                completedOrCancelledTournamentsThisWeek.add(tournament); // Move cancelled to completed list
            } else if (tournament.status != TournamentStatus.Cancelled) { // Check if not cancelled by generateMatchesForStart
                // If not cancelled, check if matches were actually generated
                if (tournament.matches.isNotEmpty) {
                    // Matches generated successfully, set to InProgress
                    tournament.status = TournamentStatus.InProgress;
                    print(" -> Tournament ${tournament.name} is now InProgress.");
                    _addNewsItem(NewsItem.create(title: "${tournament.name} Started", description: "The ${tournament.name} has officially begun!", type: NewsItemType.Tournament, date: tournament.startDate));
                } else {
                    // Matches were NOT generated, but it wasn't cancelled either. Log a warning.
                    print(" -> WARNING: Tournament ${tournament.name} (ID: ${tournament.id}) met start date condition but generateMatchesForStart() resulted in zero matches. Status remains ${tournament.status}. Investigate Tournament.generateMatchesForStart().");
                }
            }
            // If tournament.status WAS Cancelled, the previous block handles it.
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
            MatchTeamSelection homeSelection; // Use the helper class
            MatchTeamSelection awaySelection; // Use the helper class

            // --- Get Home Team Lineup (Player, Rival, or AI Club) ---
            if (match.homeTeamId == playerAcademyId) {
              homeSelection = selectPlayerTeamForMatch(tournamentType);
            } else {
              // Check if it's a Rival or AI Club
              RivalAcademy? homeRival = _rivalAcademyMap[match.homeTeamId];
              AIClub? homeAIClub = _aiClubMap[match.homeTeamId]; // Check AI Club Map

              if (homeRival != null) {
                homeSelection = selectRivalTeamForMatch(tournamentType, homeRival);
              } else if (homeAIClub != null) { // If AI Club found...
                homeSelection = selectAIClubTeamForMatch(tournamentType, homeAIClub); // Call AI Club selection
              } else {
                // Fallback if team not found in EITHER map
                print("Error: Home Team ${match.homeTeamId} not found as Player, Rival, or AI Club for match ${match.id}. Using empty lineup."); // <-- NEW ERROR PRINT
                homeSelection = MatchTeamSelection(formation: predefinedFormations.first, starters: [], bench: []);
              }
            }

            // --- Get Away Team Lineup (Player, Rival, or AI Club) ---
            if (match.awayTeamId == playerAcademyId) {
              awaySelection = selectPlayerTeamForMatch(tournamentType);
            } else {
               // --- DEBUG PRINTS START ---
              print("DEBUG: Checking Away Team ID: ${match.awayTeamId}");
              print("DEBUG: _rivalAcademyMap contains key? ${_rivalAcademyMap.containsKey(match.awayTeamId)}");
              print("DEBUG: _aiClubMap contains key? ${_aiClubMap.containsKey(match.awayTeamId)}");
              // --- DEBUG PRINTS END ---

              // Check if it's a Rival or AI Club
              RivalAcademy? awayRival = _rivalAcademyMap[match.awayTeamId];
              AIClub? awayAIClub = _aiClubMap[match.awayTeamId]; // Check AI Club Map

              if (awayRival != null) {
                awaySelection = selectRivalTeamForMatch(tournamentType, awayRival);
              } else if (awayAIClub != null) { // If AI Club found...
                awaySelection = selectAIClubTeamForMatch(tournamentType, awayAIClub); // Call AI Club selection
              } else {
                // Fallback if team not found in EITHER map
                print("Error: Away Team ${match.awayTeamId} not found as Player, Rival, or AI Club for match ${match.id}. Using empty lineup."); // <-- NEW ERROR PRINT
                awaySelection = MatchTeamSelection(formation: predefinedFormations.first, starters: [], bench: []);
              }
            }

            Staff? playerManager = _hiredStaff.firstWhereOrNull((s) => s.role == StaffRole.Manager);
            // --- Get Team Reputations for Viewership Calculation ---
            int homeRep = 0;
            int awayRep = 0;
            if (_rivalAcademyMap.containsKey(match.homeTeamId)) {
              homeRep = _rivalAcademyMap[match.homeTeamId]!.reputation;
            } else if (_aiClubMap.containsKey(match.homeTeamId)) {
              homeRep = _aiClubMap[match.homeTeamId]!.reputation;
            } else if (match.homeTeamId == playerAcademyId) {
              homeRep = _academyReputation;
            }

            if (_rivalAcademyMap.containsKey(match.awayTeamId)) {
              awayRep = _rivalAcademyMap[match.awayTeamId]!.reputation;
            } else if (_aiClubMap.containsKey(match.awayTeamId)) {
              awayRep = _aiClubMap[match.awayTeamId]!.reputation;
            } else if (match.awayTeamId == playerAcademyId) {
              awayRep = _academyReputation;
            }

            // Simulate the match, passing whether it's a knockout game
            match.simulateDetailed(
              homeSelection.starters, // Pass starters list
              awaySelection.starters, // Pass starters list
              isKnockout: tournament.format == TournamentFormat.Knockout, // Pass knockout status
              playerManager: (match.homeTeamId == playerAcademyId || match.awayTeamId == playerAcademyId) ? playerManager : null,
              // Pass formations and benches
              homeFormationUsed: homeSelection.formation,
              awayFormationUsed: awaySelection.formation,
              homeBenchPlayers: homeSelection.bench,
              awayBenchPlayers: awaySelection.bench,
              // Pass reputations for viewership
              homeTeamReputation: homeRep,
              awayTeamReputation: awayRep,
              tournamentReputation: tournament.requiredReputation // Add tournament reputation
            );

            // --- Update Stats/Fatigue for ALL involved teams ---
            _updatePlayerStatsAndFatigue(match, homeSelection.starters, awaySelection.starters); // Player Academy
            _updateRivalOrAIClubFatigue(match, homeSelection.starters, awaySelection.starters); // Rivals AND AI Clubs (Use combined function)
            _updateReputationAfterMatch(tournament, match); // Handles Player, Rivals, and AI Clubs
            _updateLeagueStandings(tournament, match); // Handles all team types

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
        // --- Premature Completion Check REMOVED ---
        // The logic below in "Generate Next Knockout Rounds" handles completion correctly.

        } // End if InProgress

        // --- NEW: Check for League Completion ---
        if (tournament.status == TournamentStatus.InProgress && tournament.format == TournamentFormat.League) {
            // Check if all matches in the league are simulated
            // --- FIX: Explicitly type 'match' as Match ---
            bool allMatchesSimulated = tournament.matches.every((Match match) => match.isSimulated);
            // --- END FIX ---
            if (allMatchesSimulated) {
                print(" -> League ${tournament.name} (ID: ${tournament.id}) has completed all matches.");
                tournament.status = TournamentStatus.Completed;
                if (!completedOrCancelledTournamentsThisWeek.contains(tournament)) {
                    completedOrCancelledTournamentsThisWeek.add(tournament);
                    // Remove tournament ID from participating entities (Rivals/AI Clubs)
                    for (var participantId in tournament.teamIds) {
                        if (participantId != playerAcademyId) {
                           _rivalAcademyMap[participantId]?.activeTournamentIds.remove(tournament.id);
                           _aiClubMap[participantId]?.activeTournamentIds.remove(tournament.id); // Also remove from AI clubs
                        }
                    }
                    // Handle completion immediately (awards, news, P/R)
                    // Note: This might lead to _handleTournamentCompletion being called twice if
                    // the league also somehow ended up in completedOrCancelledTournamentsThisWeek later.
                    // We'll rely on the check inside _handleTournamentCompletion to prevent double processing.
                    _handleTournamentCompletion(tournament);
                }
            }
        }
        // --- END NEW ---

    } // End tournament loop

    // --- Generate Next Knockout Rounds ---
    for (var tournament in tournamentsToCheckForNextRound) {
        // Check status again in case it was completed by the league check above
        if (tournament.status == TournamentStatus.InProgress) {
            bool nextRoundGenerated = tournament.generateNextKnockoutRound();
            if (nextRoundGenerated) {
                print("Generated next knockout round (${tournament.currentRound}) for ${tournament.name}.");
                _addNewsItem(NewsItem.create(title: "${tournament.name} Update", description: "Round ${tournament.currentRound-1} completed. Fixtures for Round ${tournament.currentRound} are set.", type: NewsItemType.Tournament, date: _timeService.currentDate));
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
              _financeService.addIncome(prizeMoney.toDouble());
              // --- Increased Academy Reputation for Tournament Win ---
              _academyReputation += (tournament.format == TournamentFormat.League) ? 60 : 30; // Increased rep gain
              // --- End Increased Academy Reputation ---
              _addNewsItem(NewsItem.create(
                  title: "Tournament Won!",
                  description: "We won the ${tournament.name} and received ${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(prizeMoney)}!",
                  type: NewsItemType.MatchResult, // Corrected type
                  date: _timeService.currentDate
              ));
              print("Player won ${tournament.name}. Prize: $prizeMoney. New Balance: ${_financeService.balance}. New Rep: $_academyReputation");
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
                      date: _timeService.currentDate
                  ));
          print("${rivalWinner.name} won ${tournament.name}. Prize: $prizeMoney. New Balance: ${rivalWinner.balance}. New Rep: ${rivalWinner.reputation}");
              } else {
                  // Check if it's an AI Club winner
                  AIClub? aiWinner = _aiClubMap[determinedWinnerId];
                  if (aiWinner != null) {
                      winnerName = aiWinner.name;
                      aiWinner.balance += prizeMoney;
                      aiWinner.reputation += (tournament.format == TournamentFormat.League) ? 50 : 25; // AI club rep boost
                      _addNewsItem(NewsItem.create(
                          title: "${tournament.name} Concluded",
                          description: "${aiWinner.name} won the ${tournament.name}.",
                          type: NewsItemType.MatchResult,
                          date: _timeService.currentDate
                      ));
                      print("${aiWinner.name} won ${tournament.name}. Prize: $prizeMoney. New Balance: ${aiWinner.balance}. New Rep: ${aiWinner.reputation}");
                  } else {
                      winnerName = "An unknown team"; // Fallback if neither rival nor AI club found
                      print("Warning: Winner ID $determinedWinnerId not found in rival or AI club map for tournament ${tournament.name}");
                  }
              }
          }
      } else {
           _addNewsItem(NewsItem.create(
              title: "${tournament.name} Concluded",
              description: "The ${tournament.name} has finished.", // Simpler message if no winner determined
              type: NewsItemType.MatchResult, // Corrected type
              date: _timeService.currentDate
          ));
          print("${tournament.name} finished without a clear winner determined.");
      }

      // --- NEW: Promotion/Relegation Logic for AI Club Leagues ---
      if (tournament.format == TournamentFormat.League && tournament.isAIClubFocusedLeague) {
          _handleLeaguePromotionRelegation(tournament);
      }
      // --- END NEW ---
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

  // --- NEW: Update Rival OR AI Club Fatigue --- // Renamed from _updateRivalFatigue
  void _updateRivalOrAIClubFatigue(Match match, List<Player> homeLineup, List<Player> awayLineup) {
      if (!match.isSimulated) return;

      // Check Home Team
      RivalAcademy? homeRival = _rivalAcademyMap[match.homeTeamId];
      AIClub? homeAIClub = _aiClubMap[match.homeTeamId];
      List<Player> homePlayersToUpdate = [];

      if (homeRival != null) {
          homePlayersToUpdate.addAll(homeRival.players.where((p) => match.homeLineup.contains(p.id)));
      } else if (homeAIClub != null) {
          homePlayersToUpdate.addAll(homeAIClub.players.where((p) => match.homeLineup.contains(p.id)));
      }

      // Check Away Team
      RivalAcademy? awayRival = _rivalAcademyMap[match.awayTeamId];
      AIClub? awayAIClub = _aiClubMap[match.awayTeamId];
      List<Player> awayPlayersToUpdate = [];

      if (awayRival != null) {
          awayPlayersToUpdate.addAll(awayRival.players.where((p) => match.awayLineup.contains(p.id)));
      } else if (awayAIClub != null) {
          awayPlayersToUpdate.addAll(awayAIClub.players.where((p) => match.awayLineup.contains(p.id)));
      }

      // Apply fatigue increase
      List<Player> allPlayersToUpdate = [...homePlayersToUpdate, ...awayPlayersToUpdate];
      for (var player in allPlayersToUpdate) {
          double fatigueIncrease = 15.0 + ((100 - player.stamina) / 10.0);
          player.fatigue = (player.fatigue + fatigueIncrease).clamp(0.0, 100.0);
          // print("Non-Player ${player.name} fatigue updated to ${player.fatigue.toStringAsFixed(1)}%"); // Verbose
      }
  }
  // --- END NEW ---

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
              int oldSkill = player.currentSkill;
              bool improved = player.train(focusPosition: player.assignedPosition); // Use train method
              if (improved) {
                anyPlayerImproved = true;
                // The news item can state general improvement, as specific attribute isn't easily known here.
                // Or, we can just say skill in assigned position improved.
                _addNewsItem(NewsItem.create(title: "Player Improved", description: "${player.name} showed improvement in training under Coach ${coach.name}. Skill in ${player.assignedPosition.name} is now ${player.currentSkill} (was $oldSkill).", type: NewsItemType.Training, date: _timeService.currentDate));
                // print("  -> Player ${player.name} (under ${coach.name}) improved. New skill in ${player.assignedPosition.name}: ${player.currentSkill}. Chance: $totalChance%"); // Less verbose
              }
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
    _availableStaff.removeWhere((staff) {
      bool leaving = _random.nextDouble() < 0.20; // 20% chance any staff leaves the market
      if (leaving) removedCount++;
      return leaving;
    });

    // Number of new staff depends on player's academy reputation
    // Min 1, Max 5. Example: Rep 0-199 -> 1, 200-399 -> 2, ..., 800-1000 -> 5
    int newStaffCount = 1 + (_academyReputation ~/ 200);
    newStaffCount = newStaffCount.clamp(1, 5); // Clamp between 1 and 5

    int addedCount = 0;
    for (int i = 0; i < newStaffCount; i++) {
      StaffRole role = StaffRole.values[_random.nextInt(StaffRole.values.length)];
      // Reduce chance of Manager/Physio appearing if many already available or low rep?
      // For now, keep it simple.
      if (_availableStaff.length < 15) { // Max 15 available staff in the market
        Staff newStaff = Staff.randomStaff(
          'staff_${_timeService.currentDate.millisecondsSinceEpoch}_$i',
          role,
          academyReputation: _academyReputation, // Pass current academy reputation
        );
        _availableStaff.add(newStaff);
        addedCount++;
      }
    }
    // print("Staff Market Refreshed: $removedCount removed, $addedCount added (based on rep $_academyReputation). Total available: ${_availableStaff.length}");
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
    _playerCoachMap[playerId] = coach.id; // Update cache
    print("Assigned player ${player.name} to coach ${coach.name}."); notifyListeners(); return true;
  }

  bool unassignPlayerFromCoach(String playerId, String coachId) {
    Staff? coach = _hiredStaff.firstWhereOrNull((s) => s.id == coachId && s.role == StaffRole.Coach);
    if (coach == null) { print("Error: Coach with ID $coachId not found or is not a coach."); return false; }
    Player? player = _academyPlayers.firstWhereOrNull((p) => p.id == playerId); String playerName = player?.name ?? 'ID: $playerId';
    bool removed = coach.assignedPlayerIds.remove(playerId);
    if (removed) {
      if (_playerCoachMap[playerId] == coachId) {
        _playerCoachMap.remove(playerId); // Update cache
      }
      print("Unassigned player $playerName from coach ${coach.name}."); notifyListeners();
    }
    else { print("Info: Player $playerName was not assigned to coach ${coach.name}."); }
    return removed;
  }

  void unassignPlayerFromAnyCoach(String playerId) {
    // Optimization: Use the map to find the coach directly instead of iterating all coaches
    String? coachId = _playerCoachMap[playerId];
    if (coachId != null) {
      unassignPlayerFromCoach(playerId, coachId);
    } else {
      // Fallback
      for (var coach in _hiredStaff.where((s) => s.role == StaffRole.Coach)) { if (coach.assignedPlayerIds.contains(playerId)) { unassignPlayerFromCoach(playerId, coach.id); break; } }
    }
  }

  Staff? getCoachForPlayer(String playerId) {
    // Optimization: Use the cache map for O(1) lookup
    String? coachId = _playerCoachMap[playerId];
    if (coachId == null) return null;
    return _hiredStaff.firstWhereOrNull((s) => s.id == coachId);
  }

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

  // --- Refactored Team Selection for Player ---
  MatchTeamSelection selectPlayerTeamForMatch(TournamentType type) {
    int startersNeeded = _getPlayersNeededForType(type);
    int benchSize = _getBenchSizeForType(type);
    int totalPlayersNeeded = startersNeeded + benchSize;

    // Get the manager's preferred formation or find a default
    Staff? manager = _hiredStaff.firstWhereOrNull((s) => s.role == StaffRole.Manager);
    // --- FIX: Use predefinedFormations ---
    Formation formation = manager?.preferredFormation ??
                         (predefinedFormations.firstWhereOrNull((f) => f.tournamentType == type) ?? // Find first matching type
                         predefinedFormations.first); // Absolute fallback

    // Check if enough players are available
    if (_academyPlayers.length < totalPlayersNeeded) {
      print("Warning: Not enough players in academy (${_academyPlayers.length}) for a ${type.toString()} match (needs $totalPlayersNeeded). Selecting all available.");
      List<Player> allPlayers = List<Player>.from(_academyPlayers);
      allPlayers.sort(_sortByEffectiveSkill); // Sort even if not enough
      List<Player> starters = allPlayers.take(startersNeeded).toList();
      List<Player> bench = allPlayers.skip(startersNeeded).toList();
      return MatchTeamSelection(formation: formation, starters: starters, bench: bench);
    }

    List<Player> availablePlayers = List<Player>.from(_academyPlayers);
    availablePlayers.sort(_sortByEffectiveSkill); // Sort by skill, penalizing fatigue

    // Select starters and bench
    List<Player> starters = availablePlayers.sublist(0, startersNeeded);
    List<Player> bench = availablePlayers.sublist(startersNeeded, totalPlayersNeeded);

    return MatchTeamSelection(formation: formation, starters: starters, bench: bench);
  }

  // --- Refactored Team Selection for Rival ---
  MatchTeamSelection selectRivalTeamForMatch(TournamentType type, RivalAcademy academy) {
    int startersNeeded = _getPlayersNeededForType(type);
    int benchSize = _getBenchSizeForType(type);
    int totalPlayersNeeded = startersNeeded + benchSize;

    // Rivals use a default formation for now
    // --- FIX: Use predefinedFormations ---
    Formation formation = predefinedFormations.firstWhereOrNull((f) => f.tournamentType == type) ?? // Find first matching type
                         predefinedFormations.first; // Absolute fallback

    // Check if enough players are available
    if (academy.players.length < totalPlayersNeeded) {
      print("Warning: Not enough players in rival academy ${academy.name} (${academy.players.length}) for a ${type.toString()} match (needs $totalPlayersNeeded). Selecting all available.");
      List<Player> allPlayers = List<Player>.from(academy.players);
      allPlayers.sort(_sortByEffectiveSkill); // Sort even if not enough
      List<Player> starters = allPlayers.take(startersNeeded).toList();
      List<Player> bench = allPlayers.skip(startersNeeded).toList();
      return MatchTeamSelection(formation: formation, starters: starters, bench: bench);
    }

    List<Player> availablePlayers = List<Player>.from(academy.players);
    availablePlayers.sort(_sortByEffectiveSkill); // Sort by skill, penalizing fatigue

    // Select starters and bench
    List<Player> starters = availablePlayers.sublist(0, startersNeeded);
    List<Player> bench = availablePlayers.sublist(startersNeeded, totalPlayersNeeded);

    return MatchTeamSelection(formation: formation, starters: starters, bench: bench);
  }

  // --- NEW: Team Selection for AI Club ---
  MatchTeamSelection selectAIClubTeamForMatch(TournamentType type, AIClub club) {
    int startersNeeded = _getPlayersNeededForType(type);
    int benchSize = _getBenchSizeForType(type);
    int totalPlayersNeeded = startersNeeded + benchSize;

    // AI Clubs use a default formation for now
    Formation formation = predefinedFormations.firstWhereOrNull((f) => f.tournamentType == type) ??
                         predefinedFormations.first;

    // Check if enough players are available
    if (club.players.length < totalPlayersNeeded) {
      print("Warning: Not enough players in AI club ${club.name} (${club.players.length}) for a ${type.toString()} match (needs $totalPlayersNeeded). Selecting all available.");
      List<Player> allPlayers = List<Player>.from(club.players);
      allPlayers.sort(_sortByEffectiveSkill);
      List<Player> starters = allPlayers.take(startersNeeded).toList();
      List<Player> bench = allPlayers.skip(startersNeeded).toList();
      return MatchTeamSelection(formation: formation, starters: starters, bench: bench);
    }

    List<Player> availablePlayers = List<Player>.from(club.players);
    availablePlayers.sort(_sortByEffectiveSkill); // Sort by skill, penalizing fatigue

    // Select starters and bench
    List<Player> starters = availablePlayers.sublist(0, startersNeeded);
    List<Player> bench = availablePlayers.sublist(startersNeeded, totalPlayersNeeded);

    return MatchTeamSelection(formation: formation, starters: starters, bench: bench);
  }
  // --- END NEW ---

  // Helper for sorting players by effective skill (skill - fatigue penalty)
  int _sortByEffectiveSkill(Player a, Player b) {
    double fatiguePenaltyA = a.fatigue > 75 ? 50 : (a.fatigue / 2); // Heavier penalty above 75%
    double fatiguePenaltyB = b.fatigue > 75 ? 50 : (b.fatigue / 2);
    double effectiveScoreA = a.currentSkill - fatiguePenaltyA;
    double effectiveScoreB = b.currentSkill - fatiguePenaltyB;
    return effectiveScoreB.compareTo(effectiveScoreA); // Descending order
  }

  // Helper to get number of starters needed
  int _getPlayersNeededForType(TournamentType type) {
    switch (type) {
      case TournamentType.threeVthree: return 3;
      case TournamentType.fiveVfive: return 5;
      case TournamentType.sevenVseven: return 7;
      case TournamentType.elevenVeleven: return 11;
      default: return 11;
    }
  }

  // Helper to get bench size
  int _getBenchSizeForType(TournamentType type) {
    switch (type) {
      case TournamentType.threeVthree: return 2; // e.g., 3 starters + 2 bench
      case TournamentType.fiveVfive: return 3; // e.g., 5 starters + 3 bench
      case TournamentType.sevenVseven: return 4; // e.g., 7 starters + 4 bench
      case TournamentType.elevenVeleven: return 7; // e.g., 11 starters + 7 bench
      default: return 7;
    }
  }

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

      // --- Increased Academy Reputation for Match Win/Draw ---
      // Reputation change based on format and result
      int winRep = (tournament.format == TournamentFormat.League) ? 5 : 8; // Increased win rep
      int drawRep = (tournament.format == TournamentFormat.League) ? 2 : 3; // Increased draw rep
      int lossRep = (tournament.format == TournamentFormat.League) ? -1 : -3; // Loss rep remains
      // --- End Increased Academy Reputation ---

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

      // --- NEW: Direct Fan Changes based on Match Result & Viewership ---
      int fanChangeOnMatch = 0;
      if (playerWon) {
        // Base fan gain for a win, scaled by viewership
        fanChangeOnMatch = (5 + (match.viewership / 20)).round(); // e.g., 5 + (100 viewers / 20) = 10 fans
        fanChangeOnMatch = fanChangeOnMatch.clamp(1, 50); // Clamp fan gain
      } else if (playerDrew) {
        // Smaller gain for a draw, scaled by viewership
        fanChangeOnMatch = (2 + (match.viewership / 50)).round(); // e.g., 2 + (100 viewers / 50) = 4 fans
        fanChangeOnMatch = fanChangeOnMatch.clamp(0, 25);
      } else { // Player Lost
        // Fan loss for a loss, less impact from viewership directly, more from disappointment
        fanChangeOnMatch = -(_random.nextInt(3) + 1); // Lose 1 to 3 fans
        fanChangeOnMatch = fanChangeOnMatch.clamp(-10, 0); // Clamp fan loss
      }

      // Add a small bonus based on raw viewership if it was a player's match
      fanChangeOnMatch += (match.viewership / 100).round().clamp(0,5); // Max +5 from raw viewership

      if (fanChangeOnMatch != 0) {
        _fans += fanChangeOnMatch;
        _fans = max(0, _fans); // Ensure fans don't go below 0
        // print("Direct fan change after match: $fanChangeOnMatch (Viewers: ${match.viewership}). New fans: $_fans");
      }
      // --- END NEW: Direct Fan Changes ---

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
            // --- Increased Reputation Impact ---
            individualChange += goals * 15; // Significant bonus for goals
            individualChange += assists * 8; // Significant bonus for assists
            // --- End Increased Reputation Impact ---
            if (individualChange != 0) {
                player.reputation = max(0, player.reputation + individualChange);
                // print("Player ${player.name} reputation changed by $individualChange to ${player.reputation}"); // Verbose
            }
        }
    }

    // --- Update Rival / AI Club Reputation ---
    dynamic homeEntity = _rivalAcademyMap[match.homeTeamId] ?? _aiClubMap[match.homeTeamId];
    dynamic awayEntity = _rivalAcademyMap[match.awayTeamId] ?? _aiClubMap[match.awayTeamId];

    // Define reputation changes (slightly different for AI clubs vs Rivals)
    int winRep = (tournament.format == TournamentFormat.League) ? 2 : 3; // Base win rep
    int drawRep = 1; // Base draw rep
    int lossRep = (tournament.format == TournamentFormat.League) ? 0 : -2; // Base loss rep

    // Apply to Home Entity
    if (homeEntity != null) {
        int repChange = 0;
        bool isAI = homeEntity is AIClub;
        int currentRep = homeEntity.reputation;
        int entityWinRep = winRep + (isAI ? 1 : 0); // AI clubs get slightly more for winning
        int entityDrawRep = drawRep;
        int entityLossRep = lossRep - (isAI ? 1 : 0); // AI clubs lose slightly more

        if (match.result == MatchResult.homeWin) repChange = entityWinRep;
        else if (match.result == MatchResult.draw) repChange = entityDrawRep;
        else repChange = entityLossRep; // Lost

        homeEntity.reputation = max(isAI ? 20 : 10, currentRep + repChange); // Higher min rep for AI clubs
        // print("${isAI ? 'AI Club' : 'Rival'} ${homeEntity.name} reputation changed by $repChange to ${homeEntity.reputation}"); // Verbose
    }

    // Apply to Away Entity
    if (awayEntity != null) {
        int repChange = 0;
        bool isAI = awayEntity is AIClub;
        int currentRep = awayEntity.reputation;
        int entityWinRep = winRep + (isAI ? 1 : 0);
        int entityDrawRep = drawRep;
        int entityLossRep = lossRep - (isAI ? 1 : 0);

        if (match.result == MatchResult.awayWin) repChange = entityWinRep;
        else if (match.result == MatchResult.draw) repChange = entityDrawRep;
        else repChange = entityLossRep; // Lost

        awayEntity.reputation = max(isAI ? 20 : 10, currentRep + repChange);
        // print("${isAI ? 'AI Club' : 'Rival'} ${awayEntity.name} reputation changed by $repChange to ${awayEntity.reputation}"); // Verbose
    }
    // --- End Update Rival / AI Club Reputation ---
  }

  void _updateReputationDecay() {
    // Player academy decay is handled in _handleRivalAcademyActions now
    // _academyReputation = max(0, _academyReputation - 1);
    // for (var player in _academyPlayers) { player.reputation = max(0, player.reputation - 1); } // Removed weekly player reputation decay
     // print("Applied weekly player reputation decay."); // Rival decay is in their action handler
  }

  // Generate Transfer Offers
  void _generateTransferOffers() {
    print("--- DEBUG: Starting _generateTransferOffers ---");
    // Clear only previous offers made by AI clubs FOR the player's academy players
    _transferOffers.removeWhere((o) =>
        o['sellingClubId'] == playerAcademyId &&
        o['isAIClubOffer'] == true &&
        o['offeringClubId'] != null && _aiClubMap.containsKey(o['offeringClubId']));
    // Only generate offers if not in Hardcore mode? Or make them rarer/lower value?
    // For now, let's keep generating them but maybe rivals can also bid later.
    if (_difficulty == Difficulty.Hardcore) {
        print("--- DEBUG: Skipping transfer offers due to Hardcore difficulty. ---");
        return; // Skip offer generation in Hardcore for simplicity initially
    }

    final random = Random();
    print("--- DEBUG: Iterating through ${_academyPlayers.length} academy players for offers ---");
    for (var player in _academyPlayers) {
      print("--- DEBUG: Considering player ${player.name} (ID: ${player.id}) ---");
      // --- NEW Offer Chance Calculation ---
      double baseChance = 0.01; // Small base chance
      // Skill Factor (higher skill = much higher chance)
      double skillFactor = pow(player.currentSkill / 100.0, 2) * 0.45; // Exponential based on skill, up to 0.45
      // Potential Factor (higher potential = higher chance)
      double potentialFactor = pow(player.potentialSkill / 100.0, 2) * 0.23; // Exponential based on potential, up to 0.23
      // Age Factor (huge bonus for young players 15-18)
      double ageFactor = 0.0;
      if (player.age <= 18) {
        ageFactor = (19 - player.age) * 0.05; // Up to 0.6 bonus for 15yo (19-15)*0.05
      } else if (player.age <= 21) {
        ageFactor = (22 - player.age) * 0.015; // Smaller bonus for 19-21yo
      }
      // Reputation Multiplier (modest impact)
      double repMultiplier = (player.reputation / 500.0) * (1.0 + _academyReputation / 1000.0);
      repMultiplier = repMultiplier.clamp(0.0, 1.5); // Clamp multiplier effect

      // Combine factors
      double combinedChance = (baseChance + skillFactor + potentialFactor + ageFactor) * repMultiplier;
      // Clamp final chance (e.g., max 50% per week for exceptional talents)
      double offerChance = combinedChance.clamp(0.005, 0.50); // Min 0.5%, Max 50%

      // --- END NEW Offer Chance Calculation ---

      if (random.nextDouble() < offerChance) {
        int marketValue = player.calculateMarketValue(); // Calculate value needed for filtering/weighting

        // --- MODIFIED: Weighted Selection of Offering AI Club ---
        List<AIClub> potentialBidders = _aiClubs.where((club) {
          // Filter: Must be able to afford minimum offer (70% market value)
          // Filter: Club tier should be appropriate (e.g., higher tier clubs bid for better players)
          // Filter: Club reputation vs player reputation
          bool canAfford = club.balance >= marketValue * 0.7;
          // Simple tier logic: Higher tier clubs are more likely interested in higher skill players
          bool tierMatch = (club.tier == 1 && player.currentSkill > 60) ||
                           (club.tier == 2 && player.currentSkill > 45) ||
                           (club.tier == 3 && player.currentSkill > 30);
          // Reputation logic: Club rep should generally be higher than player rep
          bool repMatch = club.reputation > player.reputation - 20;

          return canAfford && tierMatch && repMatch;
        }).toList();

        if (potentialBidders.isEmpty) {
            // print("--- DEBUG: No suitable AI club bidders found for ${player.name} ---"); // Verbose
            continue; // No AI clubs meet criteria
        }

        // Calculate weights based on tier, reputation, and balance
        Map<AIClub, double> bidderWeights = {};
        double totalWeight = 0;
        for (var club in potentialBidders) {
          // Weight: Higher tier = higher weight, Reputation bonus, Balance bonus (relative to 1M)
          double tierWeight = (4 - club.tier) * 50.0; // Tier 1=150, Tier 2=100, Tier 3=50
          double repWeight = club.reputation * 0.5;
          double balanceWeight = (club.balance / 1000000.0).clamp(0.1, 1.0) * 50.0; // Up to 50 bonus based on balance
          double weight = tierWeight + repWeight + balanceWeight;
          weight = max(1.0, weight); // Ensure minimum weight
          bidderWeights[club] = weight;
          totalWeight += weight;
        }

        if (totalWeight <= 0) continue; // Avoid division by zero

        // Select bidder based on weight
        double roll = random.nextDouble() * totalWeight;
        double cumulativeWeight = 0;
        AIClub? selectedBidder; // Use nullable type

        for (var entry in bidderWeights.entries) {
          cumulativeWeight += entry.value;
          if (roll <= cumulativeWeight) {
            selectedBidder = entry.key;
            break;
          }
        }
        selectedBidder ??= potentialBidders.last; // Fallback

        AIClub offeringClub = selectedBidder;
        // --- END: Weighted Selection ---

        // Offer Amount Calculation (similar, but maybe AI clubs offer slightly more?)
        double offerMultiplier = 0.75 + random.nextDouble() * 0.6; // Offer between 75% and 135% of market value
        int offerAmount = (marketValue * offerMultiplier).round();
        offerAmount = max(100, offerAmount); // Ensure minimum offer

        // Check if the offering club can *still* afford it (redundant check, but safe)
        if (offeringClub.balance >= offerAmount) {
            _transferOffers.add({
                'playerId': player.id,
                'playerName': player.name,
                'offeringClubName': offeringClub.name, // Use AI club name
                'offeringClubId': offeringClub.id, // Store AI club ID
                'offerAmount': offerAmount,
                'isAIClubOffer': true, // Flag to distinguish from potential future rival offers
                'sellingClubId': playerAcademyId, // Ensure selling club is player's academy
                'sellingClubName': _academyName, // Add selling club name
                'dateEpoch': _timeService.currentDate.millisecondsSinceEpoch, // Add date epoch for consistency
            });
            // print("Generated transfer offer for ${player.name} (Value: $marketValue) from AI Club ${offeringClub.name} for $offerAmount"); // Less verbose
            _addNewsItem(NewsItem.create(title: "Transfer Offer Received", description: "${offeringClub.name} has made an offer of \$${NumberFormat.compact().format(offerAmount)} for ${player.name}.", type: NewsItemType.TransferOffer, date: _timeService.currentDate));
        } else {
             // print(" -> AI Club ${offeringClub.name} wanted to bid for ${player.name} but couldn't afford \$${offerAmount}."); // Verbose
        }
      }
    }
     print("--- DEBUG: Finished _generateTransferOffers. Found ${_transferOffers.length} offers. ---");
  }

  // Accept Transfer Offer (MODIFIED to handle AI Clubs)
  void acceptTransferOffer(Map<String, dynamic> offer) {
    String playerId = offer['playerId'];
    int offerAmount = offer['offerAmount'];
    String offeringClubId = offer['offeringClubId'];
    bool isAIClubOffer = offer['isAIClubOffer'] ?? false; // Check if it's an AI club

    Player? player = _academyPlayers.firstWhereOrNull((p) => p.id == playerId);

    if (player == null) {
        print("Error accepting transfer: Player $playerId not found.");
        _transferOffers.removeWhere((o) => o['playerId'] == playerId); // Remove invalid offer
        notifyListeners();
        return;
    }

    dynamic buyingEntity; // Can be RivalAcademy or AIClub
    bool canAfford = false;
    String buyerName = "Unknown Buyer";

    if (isAIClubOffer) {
        AIClub? buyingClub = _aiClubMap[offeringClubId];
        if (buyingClub != null) {
            buyingEntity = buyingClub;
            canAfford = buyingClub.balance >= offerAmount;
            buyerName = buyingClub.name;
        }
    } else {
        // Handle Rival Academy offers (if re-enabled later)
        RivalAcademy? buyingAcademy = _rivalAcademyMap[offeringClubId];
         if (buyingAcademy != null) {
            buyingEntity = buyingAcademy;
            canAfford = buyingAcademy.balance >= offerAmount;
            buyerName = buyingAcademy.name;
        }
    }

    if (buyingEntity == null) {
        print("Error accepting transfer: Buying entity $offeringClubId not found (isAIClubOffer: $isAIClubOffer).");
        _transferOffers.removeWhere((o) => o['playerId'] == playerId); // Remove invalid offer
        notifyListeners();
        return;
    }

    if (canAfford) {
        unassignPlayerFromAnyCoach(playerId); // Unassign from player's coach

        // Player academy gains money
        _financeService.addIncome(offerAmount.toDouble());

        // Buying entity loses money and gains player
        buyingEntity.balance -= offerAmount;
        // IMPORTANT: Add player to the correct list
        buyingEntity.players.add(player);

        // Remove player from player's academy
        _academyPlayers.removeWhere((p) => p.id == playerId);

        _transferOffers.removeWhere((o) => o['playerId'] == playerId); // Remove this offer
        _calculateWeeklyWages(); // Recalculate player wages

        print("Accepted transfer offer for ${player.name}. Received $offerAmount. Balance: ${_financeService.balance}");
        print(" -> $buyerName signed ${player.name}. New Balance: ${buyingEntity.balance}. Player Count: ${buyingEntity.players.length}");

        _addNewsItem(NewsItem.create(title: "Transfer Accepted", description: "We accepted the offer of \$${NumberFormat.compact().format(offerAmount)} for ${player.name} from $buyerName.", type: NewsItemType.TransferDecision, date: _timeService.currentDate));
        notifyListeners();
    } else {
        print("Error: $buyerName can no longer afford the offer of $offerAmount for ${player.name}. Rejecting offer.");
        rejectTransferOffer(offer); // Reject if they can't afford it anymore
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
  int getMerchandiseStoreUpgradeCost() => _calculateFacilityUpgradeCost(_merchandiseStoreLevel); // Cost for merch store

  void _updateStaffCapsFromFacilities() {
    _maxCoaches = 1 + (_trainingFacilityLevel - 1);
    _maxScouts = 1 + (_scoutingFacilityLevel - 1);
    _maxPhysios = 1 + (_medicalBayLevel - 1);
    _maxStoreManagers = (_merchandiseStoreLevel > 0) ? _merchandiseStoreLevel : 0; // 1 Store Manager per store level
    // _maxMatchSalesManagers is currently static (1), can be made dynamic later if needed.

    // print("Updated staff caps: Coaches=$_maxCoaches, Scouts=$_maxScouts, Physios=$_maxPhysios, StoreMgrs=$_maxStoreManagers, MatchSalesMgrs=$_maxMatchSalesManagers"); // Less verbose
    // Ensure hired staff doesn't exceed new caps (fire excess? prevent hiring?) - For now, just prevents hiring more.
  }

  bool upgradeTrainingFacility() {
    int cost = getTrainingFacilityUpgradeCost();
    if (_financeService.canAfford(cost.toDouble())) {
      _financeService.deductExpense(cost.toDouble());
      _trainingFacilityLevel++;
      _academyReputation += 5; // Add reputation boost
      _updateStaffCapsFromFacilities();
      print("Upgraded Training Facility to Level $_trainingFacilityLevel. Cost: $cost. Balance: ${_financeService.balance}. Rep: $_academyReputation");
      _addNewsItem(NewsItem.create(title: "Facility Upgraded", description: "Training Facility upgraded to Level $_trainingFacilityLevel. Coach capacity increased to $_maxCoaches. Academy reputation increased.", type: NewsItemType.Facility, date: _timeService.currentDate));
      notifyListeners(); return true;
    } else { print("Cannot upgrade Training Facility. Cost: $cost, Balance: ${_financeService.balance}"); return false; }
  }

  bool upgradeScoutingFacility() {
    int cost = getScoutingFacilityUpgradeCost();
    if (_financeService.canAfford(cost.toDouble())) {
      _financeService.deductExpense(cost.toDouble());
      _scoutingFacilityLevel++;
      _updateStaffCapsFromFacilities();
      print("Upgraded Scouting Facility to Level $_scoutingFacilityLevel. Cost: $cost. Balance: ${_financeService.balance}");
       _addNewsItem(NewsItem.create(title: "Facility Upgraded", description: "Scouting Facility upgraded to Level $_scoutingFacilityLevel. Scout capacity increased to $_maxScouts.", type: NewsItemType.Facility, date: _timeService.currentDate));
      notifyListeners(); return true;
    } else { print("Cannot upgrade Scouting Facility. Cost: $cost, Balance: ${_financeService.balance}"); return false; }
  }

  bool upgradeMedicalBay() {
    int cost = getMedicalBayUpgradeCost();
    if (_financeService.canAfford(cost.toDouble())) {
      _financeService.deductExpense(cost.toDouble());
      _medicalBayLevel++;
      _updateStaffCapsFromFacilities();
      print("Upgraded Medical Bay to Level $_medicalBayLevel. Cost: $cost. Balance: ${_financeService.balance}");
       _addNewsItem(NewsItem.create(title: "Facility Upgraded", description: "Medical Bay upgraded to Level $_medicalBayLevel. Physio capacity increased to $_maxPhysios.", type: NewsItemType.Facility, date: _timeService.currentDate));
      notifyListeners(); return true;
    } else { print("Cannot upgrade Medical Bay. Cost: $cost, Balance: ${_financeService.balance}"); return false; }
  }

  bool upgradeMerchandiseStore() {
    int cost = getMerchandiseStoreUpgradeCost();
    if (_financeService.canAfford(cost.toDouble())) {
      _financeService.deductExpense(cost.toDouble());
      _merchandiseStoreLevel++;
      _academyReputation += 3; // Smaller reputation boost for merch store
      _updateStaffCapsFromFacilities(); // This will update _maxStoreManagers
      print("Upgraded Merchandise Store to Level $_merchandiseStoreLevel. Cost: $cost. Balance: ${_financeService.balance}. Rep: $_academyReputation. Max Store Managers: $_maxStoreManagers");
      _addNewsItem(NewsItem.create(
          title: "Facility Upgraded",
          description: "Merchandise Store upgraded to Level $_merchandiseStoreLevel. Store Manager capacity increased to $_maxStoreManagers. Academy reputation increased.",
          type: NewsItemType.Facility,
          date: _timeService.currentDate));
      notifyListeners();
      return true;
    } else {
      print("Cannot upgrade Merchandise Store. Cost: $cost, Balance: ${_financeService.balance}");
      return false;
    }
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
        currentDate: _timeService.currentDate,
        academyName: _academyName,
        academyPlayers: _academyPlayers,
        hiredStaff: _hiredStaff,
        balance: _financeService.balance,
        weeklyIncome: _financeService.weeklyIncome,
        totalWeeklyWages: _financeService.totalWeeklyWages,
        activeTournaments: _activeTournaments,
        completedTournaments: _completedTournaments,
        trainingFacilityLevel: _trainingFacilityLevel,
        scoutingFacilityLevel: _scoutingFacilityLevel,
        medicalBayLevel: _medicalBayLevel,
        merchandiseStoreLevel: _merchandiseStoreLevel,
        fans: _fans,
        academyReputation: _academyReputation,
        newsItems: _newsItems,
        difficulty: _difficulty,
         themeMode: _themeMode,
         rivalAcademies: _rivalAcademies,
         aiClubs: _aiClubs,
         playerAcademyTier: _playerAcademyTier,
         consecutiveNegativeWeeks: _financeService.consecutiveNegativeWeeks,
         isGameOver: _isGameOver,
         isForcedSellActive: _isForcedSellActive,
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
       // Check for aiClubs (older saves)
       if (!jsonMap.containsKey('aiClubs')) {
          print("--- Save file is from an older version (missing aiClubs). Adding empty list. ---");
          jsonMap['aiClubs'] = []; // Add empty list to allow parsing
       }

      final loadedState = SerializableGameState.fromJson(jsonMap);

      // Apply loaded state
      _timeService.initialize(loadedState.currentDate);
      _financeService.initialize(
        balance: loadedState.balance,
        weeklyIncome: loadedState.weeklyIncome,
        totalWeeklyWages: loadedState.totalWeeklyWages,
        consecutiveNegativeWeeks: loadedState.consecutiveNegativeWeeks ?? 0,
        // merchStockValue: loadedState.merchStockValue // Not in save yet
      );

      _isGameOver = loadedState.isGameOver ?? false;
      _isForcedSellActive = loadedState.isForcedSellActive ?? false;

      _academyName = loadedState.academyName;
      _academyPlayers = loadedState.academyPlayers;
      _hiredStaff = loadedState.hiredStaff;
      // _balance = loadedState.balance; // Handled by service
      // _weeklyIncome = loadedState.weeklyIncome; // Handled by service
      // _totalWeeklyWages = loadedState.totalWeeklyWages; // Handled by service
      _activeTournaments = loadedState.activeTournaments;
      _completedTournaments = loadedState.completedTournaments;
      _trainingFacilityLevel = loadedState.trainingFacilityLevel;
      _scoutingFacilityLevel = loadedState.scoutingFacilityLevel;
      _medicalBayLevel = loadedState.medicalBayLevel;
      _merchandiseStoreLevel = loadedState.merchandiseStoreLevel ?? 0; // Load merchandise store level, default to 0 if not present
      _fans = loadedState.fans ?? 100; // Load fans, default to 100 if not present
      _academyReputation = loadedState.academyReputation;
      _newsItems = loadedState.newsItems;
      _difficulty = loadedState.difficulty;
      _themeMode = loadedState.themeMode;
      _rivalAcademies = loadedState.rivalAcademies; // Load Rivals
      _aiClubs = loadedState.aiClubs; // <-- ADD: Load AI Clubs

      // Regenerate/reset transient state
      _scoutedPlayers.clear();
      _transferOffers.clear();
      _generateInitialAvailableStaff(); // Regenerate available staff pool
      _generateInitialTournamentTemplates(); // Regenerate templates
      // Repopulate maps from loaded lists
      _rivalAcademyMap.clear();
      for (var academy in _rivalAcademies) { _rivalAcademyMap[academy.id] = academy; }
      _aiClubMap.clear(); // <-- ADD: Clear AI Club map before repopulating
      for (var club in _aiClubs) { // <-- ADD: Repopulate AI Club map
           _aiClubMap[club.id] = club;
      }
      _updateStaffCapsFromFacilities();

      _rebuildPlayerCoachMap(); // Rebuild map after loading

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

  // --- NEW: Handle League Promotion/Relegation ---
  void _handleLeaguePromotionRelegation(Tournament league) {
      print("Handling Promotion/Relegation for ${league.name}");
      int currentTier = league.getLeagueTier();
      if (currentTier == 0) {
          print(" -> Cannot determine tier for league ${league.name}. Skipping P/R.");
          return;
      }

      List<LeagueStanding> sortedStandings = league.leagueStandings.values.toList();
      if (sortedStandings.length < 4) { // Need at least 4 teams for P/R
          print(" -> Not enough teams (${sortedStandings.length}) in league for promotion/relegation. Skipping.");
          return;
      }

      // Sort standings: Points -> GD -> GF
      sortedStandings.sort((a, b) {
          int pointsComparison = b.points.compareTo(a.points);
          if (pointsComparison != 0) return pointsComparison;
          int gdComparison = b.goalDifference.compareTo(a.goalDifference);
          if (gdComparison != 0) return gdComparison;
          return b.goalsFor.compareTo(a.goalsFor);
      });

      // Determine number to promote/relegate (e.g., 2 up, 2 down)
      int numPromote = 2;
      int numRelegate = 2;

      // --- Promotion ---
      if (currentTier > 1) { // Can only promote from Tier 2 or 3
          int targetTier = currentTier - 1;
          List<LeagueStanding> promotedTeams = sortedStandings.take(numPromote).toList();
          print(" -> Promoting to Tier $targetTier: ${promotedTeams.map((s) => s.teamId).join(', ')}");
          for (var standing in promotedTeams) {
              AIClub? club = _aiClubMap[standing.teamId];
              if (club != null) {
                  if (club.tier == currentTier) { // Only promote if they are currently in this tier
                      club.tier = targetTier;
                      club.reputation += 25; // Reputation boost for promotion
                      print("   -> ${club.name} promoted to Tier $targetTier. New Rep: ${club.reputation}");
                      _addNewsItem(NewsItem.create(title: "Club Promoted!", description: "${club.name} has been promoted to Tier $targetTier after finishing ${sortedStandings.indexOf(standing) + 1}${_getOrdinalSuffix(sortedStandings.indexOf(standing) + 1)} in ${league.name}!", type: NewsItemType.LeagueUpdate, date: _timeService.currentDate));
                  } else {
                      print("   -> ${club.name} finished in promotion spot but is already in Tier ${club.tier}. No change.");
                  }
              } else if (standing.teamId == playerAcademyId) {
                  // Handle Player Academy Promotion
                  if (_playerAcademyTier == currentTier) {
                      _playerAcademyTier = targetTier;
                      _academyReputation += 40; // Player rep boost for promotion
                      print("   -> Player Academy promoted to Tier $targetTier! New Rep: $_academyReputation");
                      _addNewsItem(NewsItem.create(title: "PROMOTED!", description: "Your academy has been promoted to Tier $targetTier after finishing ${sortedStandings.indexOf(standing) + 1}${_getOrdinalSuffix(sortedStandings.indexOf(standing) + 1)} in ${league.name}!", type: NewsItemType.LeagueUpdate, date: _timeService.currentDate));
                  } else {
                      print("   -> Player Academy finished in promotion spot but is already in Tier $_playerAcademyTier. No change.");
                  }
              } else {
                  // Handle Rival Academy Promotion
                  RivalAcademy? academy = _rivalAcademyMap[standing.teamId];
                  if (academy != null) {
                      if (academy.tier == currentTier) {
                          academy.tier = targetTier;
                          academy.reputation += 30; // Rival rep boost for promotion
                          print("   -> Rival Academy ${academy.name} promoted to Tier $targetTier. New Rep: ${academy.reputation}");
                          _addNewsItem(NewsItem.create(title: "Rival Promoted", description: "${academy.name} has been promoted to Tier $targetTier after finishing ${sortedStandings.indexOf(standing) + 1}${_getOrdinalSuffix(sortedStandings.indexOf(standing) + 1)} in ${league.name}.", type: NewsItemType.LeagueUpdate, date: _timeService.currentDate));
                      } else {
                          print("   -> Rival Academy ${academy.name} finished in promotion spot but is already in Tier ${academy.tier}. No change.");
                      }
                  }
              }
          }
      } else {
          print(" -> No promotion from Tier 1.");
      }

      // --- Relegation ---
      if (currentTier < 3) { // Can only relegate from Tier 1 or 2
          int targetTier = currentTier + 1;
          List<LeagueStanding> relegatedTeams = sortedStandings.reversed.take(numRelegate).toList();
          print(" -> Relegating to Tier $targetTier: ${relegatedTeams.map((s) => s.teamId).join(', ')}");
          for (var standing in relegatedTeams) {
              AIClub? club = _aiClubMap[standing.teamId];
              if (club != null) {
                  if (club.tier == currentTier) { // Only relegate if they are currently in this tier
                      club.tier = targetTier;
                      club.reputation = max(10, club.reputation - 15); // Reputation hit for relegation
                      print("   -> ${club.name} relegated to Tier $targetTier. New Rep: ${club.reputation}");
                      _addNewsItem(NewsItem.create(title: "Club Relegated", description: "${club.name} has been relegated to Tier $targetTier after finishing ${sortedStandings.indexOf(standing) + 1}${_getOrdinalSuffix(sortedStandings.indexOf(standing) + 1)} in ${league.name}.", type: NewsItemType.LeagueUpdate, date: _timeService.currentDate));
                  } else {
                      print("   -> ${club.name} finished in relegation spot but is already in Tier ${club.tier}. No change.");
                  }
              } else if (standing.teamId == playerAcademyId) {
                  // Handle Player Academy Relegation
                  if (_playerAcademyTier == currentTier) {
                      _playerAcademyTier = targetTier;
                      _academyReputation = max(10, _academyReputation - 20); // Player rep hit for relegation
                      print("   -> Player Academy relegated to Tier $targetTier. New Rep: $_academyReputation");
                      _addNewsItem(NewsItem.create(title: "RELEGATED!", description: "Your academy has been relegated to Tier $targetTier after finishing ${sortedStandings.indexOf(standing) + 1}${_getOrdinalSuffix(sortedStandings.indexOf(standing) + 1)} in ${league.name}.", type: NewsItemType.LeagueUpdate, date: _timeService.currentDate));
                  } else {
                      print("   -> Player Academy finished in relegation spot but is already in Tier $_playerAcademyTier. No change.");
                  }
              } else {
                   // Handle Rival Academy Relegation
                  RivalAcademy? academy = _rivalAcademyMap[standing.teamId];
                  if (academy != null) {
                      if (academy.tier == currentTier) {
                          academy.tier = targetTier;
                          academy.reputation = max(10, academy.reputation - 15); // Rival rep hit for relegation
                          print("   -> Rival Academy ${academy.name} relegated to Tier $targetTier. New Rep: ${academy.reputation}");
                          _addNewsItem(NewsItem.create(title: "Rival Relegated", description: "${academy.name} has been relegated to Tier $targetTier after finishing ${sortedStandings.indexOf(standing) + 1}${_getOrdinalSuffix(sortedStandings.indexOf(standing) + 1)} in ${league.name}.", type: NewsItemType.LeagueUpdate, date: _timeService.currentDate));
                      } else {
                          print("   -> Rival Academy ${academy.name} finished in relegation spot but is already in Tier ${academy.tier}. No change.");
                      }
                  }
              }
          }
      } else {
          print(" -> No relegation from Tier 3.");
      }
  }

  // Helper for ordinal suffixes (1st, 2nd, 3rd, etc.)
  String _getOrdinalSuffix(int n) {
    if (n % 100 >= 11 && n % 100 <= 13) {
      return 'th';
    }
    switch (n % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }
  // --- END NEW ---

  // --- NEW: Schedule Annual Pro Leagues ---
  void _scheduleAnnualLeagues(int year) {
    print("--- Scheduling Annual Pro Leagues for $year ---");
    DateTime leagueStartDate = DateTime(year, 7, 1); // Fixed start date: July 1st

    List<Tournament> proLeagueTemplates = _availableTournamentTemplates
        .where((t) => t.name.startsWith("Pro Youth League"))
        .toList();

    // Sort templates by tier (optional, but good practice)
    proLeagueTemplates.sort((a, b) => a.getLeagueTier().compareTo(b.getLeagueTier()));

    for (var template in proLeagueTemplates) {
      // Check if an instance of this league is already active or scheduled for the *upcoming* season
      bool alreadyScheduledOrActive = _activeTournaments.any((t) =>
          t.baseId == template.id &&
          (t.status == TournamentStatus.InProgress ||
           (t.status == TournamentStatus.Scheduled && t.startDate.year == year))); // Check year for scheduled

      if (alreadyScheduledOrActive) {
        print(" -> Instance of ${template.name} for $year already active or scheduled. Skipping.");
        continue;
      }

      print(" -> Attempting to schedule ${template.name} for $year season.");
      List<String> participants = [];
      bool enoughParticipantsFound = false;

      // --- Participant Gathering Logic (Deterministic - No Random Chance) ---
      // (This logic is copied and adapted from _checkForNewTournaments, removing the random chance check)

      // 1. Gather Eligible AI Clubs (Based on CURRENT TIER for T1/T2)
      int leagueTier = template.getLeagueTier();
      List<AIClub> eligibleAIClubs;

      if (leagueTier == 1 || leagueTier == 2) {
        eligibleAIClubs = _aiClubs.where((club) =>
            club.tier == leagueTier &&
            club.balance >= template.entryFee &&
            club.players.length >= template.requiredPlayers &&
            !club.activeTournamentIds.any((tId) => _activeTournaments.any((at) => at.id == tId))
        ).toList();
      } else { // Tier 3 or unknown
        eligibleAIClubs = _aiClubs.where((club) =>
            (club.tier == 3 || club.tier == 0) &&
            club.reputation >= template.requiredReputation &&
            club.balance >= template.entryFee &&
            club.players.length >= template.requiredPlayers &&
            !club.activeTournamentIds.any((tId) => _activeTournaments.any((at) => at.id == tId))
        ).toList();
      }
      eligibleAIClubs.sort((a, b) => b.reputation.compareTo(a.reputation));

      // 2. Gather Eligible Youth Academies (Rivals + Player)
      List<dynamic> eligibleYouthAcademies = [];
      bool playerEligible = false;
      int youthRepReq = template.youthAcademyMinReputation ?? template.requiredReputation;

      if (leagueTier == 3 || (leagueTier == 2 && youthRepReq >= 400)) { // Allow high-rep youth in T2
         eligibleYouthAcademies.addAll(_rivalAcademies.where((rival) =>
             rival.reputation >= youthRepReq &&
             rival.balance >= template.entryFee &&
             rival.players.length >= template.requiredPlayers &&
             !rival.activeTournamentIds.any((tId) => _activeTournaments.any((at) => at.id == tId))
         ));
         playerEligible = _academyReputation >= youthRepReq &&
                               _financeService.canAfford(template.entryFee.toDouble()) &&
                               _academyPlayers.length >= template.requiredPlayers &&
                               !_activeTournaments.any((at) => at.teamIds.contains(playerAcademyId));
         eligibleYouthAcademies.sort((a, b) => b.reputation.compareTo(a.reputation));
      } else {
         // Tier 1 or lower-rep Tier 2: No youth academies eligible
      }
      print(" -> Found ${eligibleAIClubs.length} eligible AI Clubs and ${eligibleYouthAcademies.length} eligible Youth Academies (Player eligible: $playerEligible) for Tier $leagueTier League.");

      // 3. Fill Slots (Prioritize AI Clubs)
      int slotsToFill = template.numberOfTeams;
      if (playerEligible) {
        slotsToFill--; // Reserve a slot for the player if they are eligible
      }

      // Add top AI Clubs first
      for (var club in eligibleAIClubs) {
        if (participants.length >= slotsToFill) break;
        participants.add(club.id);
      }
      print(" -> Added ${participants.length} AI Clubs.");

      // Add top Youth Academies if slots remain (Rivals join automatically here as it's the main league)
      int aiClubsAdded = participants.length;
      for (var academy in eligibleYouthAcademies) {
        if (participants.length >= slotsToFill) break;
        if (academy is RivalAcademy) { // Only add Rivals, not the player placeholder
           participants.add(academy.id);
        }
      }
      print(" -> Added ${participants.length - aiClubsAdded} Youth Academies.");

      // 4. Check if minimum met (considering potential player join)
      int minRequired = template.minTeamsToStart;
      if (playerEligible) minRequired--;

      if (participants.length >= minRequired) {
        enoughParticipantsFound = true;
      } else {
         print(" -> Not enough participants (${participants.length}) for AI Focused League ${template.name}. Min required (allowing for player): $minRequired. League will not be scheduled this year.");
      }
      // --- End Participant Gathering ---

      // --- Create Instance if Enough Participants Found ---
      if (enoughParticipantsFound) {
        // --- FIX: Pass the *actual current game date* to the factory ---
        // The factory constructor will calculate the correct July 1st start date based on _currentDate.
        Tournament newTournament = Tournament.fromTemplate(template, participants, _timeService.currentDate);
        // --- END FIX ---
        addActiveTournament(newTournament); // Adds to _activeTournaments with Scheduled status

        // Mark participants as active in this tournament
        for (var participantId in participants) {
          _rivalAcademyMap[participantId]?.activeTournamentIds.add(newTournament.id);
          _aiClubMap[participantId]?.activeTournamentIds.add(newTournament.id);
        }

        // Player join window is until the league starts
        String joinWindow = "You have until ${DateFormat.yMMMd().format(leagueStartDate)} to join.";
        _addNewsItem(NewsItem.create(
            title: "Pro League Scheduled",
            description: "${newTournament.name} is scheduled to start on ${DateFormat.yMMMd().format(newTournament.startDate)} with ${participants.length} teams confirmed so far. $joinWindow",
            type: NewsItemType.Tournament,
            date: _timeService.currentDate // Use current date for the news item
        ));
        print(" -> Scheduled ${newTournament.name} (ID: ${newTournament.id}) starting ${DateFormat.yMMMd().format(newTournament.startDate)} with ${participants.length} teams.");
      }
      // --- END Create Instance ---
    } // End loop through templates
    print("--- Finished Scheduling Annual Pro Leagues ---");
  }
  // --- END Schedule Annual Pro Leagues ---

  // --- NEW: Schedule Initial Pro Leagues (at Game Start/Reset) ---
  void _scheduleInitialProLeagues() {
    int initialYear = _timeService.currentDate.year; // Use the starting year
    print("--- Scheduling Initial Pro Leagues for $initialYear ---");
    // Use the current date directly as the scheduling date, matches will start based on this.
    DateTime schedulingDate = _timeService.currentDate;

    List<Tournament> proLeagueTemplates = _availableTournamentTemplates
        .where((t) => t.name.startsWith("Pro Youth League"))
        .toList();

    proLeagueTemplates.sort((a, b) => a.getLeagueTier().compareTo(b.getLeagueTier()));

    for (var template in proLeagueTemplates) {
      // No need to check if already scheduled, as this runs only once at the start
      print(" -> Attempting to schedule initial ${template.name} for $initialYear season.");
      List<String> participants = [];
      bool enoughParticipantsFound = false;

      // --- Participant Gathering Logic (Deterministic) ---
      int leagueTier = template.getLeagueTier();
      List<AIClub> eligibleAIClubs;
      if (leagueTier == 1 || leagueTier == 2) {
        eligibleAIClubs = _aiClubs.where((club) => club.tier == leagueTier && club.balance >= template.entryFee && club.players.length >= template.requiredPlayers).toList();
      } else { // Tier 3 or unknown
        eligibleAIClubs = _aiClubs.where((club) => (club.tier == 3 || club.tier == 0) && club.reputation >= template.requiredReputation && club.balance >= template.entryFee && club.players.length >= template.requiredPlayers).toList();
      }
      eligibleAIClubs.sort((a, b) => b.reputation.compareTo(a.reputation));

      List<dynamic> eligibleYouthAcademies = [];
      bool playerEligible = false;
      int youthRepReq = template.youthAcademyMinReputation ?? template.requiredReputation;
      if (leagueTier == 3 || (leagueTier == 2 && youthRepReq >= 400)) {
         eligibleYouthAcademies.addAll(_rivalAcademies.where((rival) => rival.reputation >= youthRepReq && rival.balance >= template.entryFee && rival.players.length >= template.requiredPlayers));
         playerEligible = _academyReputation >= youthRepReq && _financeService.canAfford(template.entryFee.toDouble()) && _academyPlayers.length >= template.requiredPlayers;
         eligibleYouthAcademies.sort((a, b) => b.reputation.compareTo(a.reputation));
      }
      print(" -> Found ${eligibleAIClubs.length} eligible AI Clubs and ${eligibleYouthAcademies.length} eligible Youth Academies (Player eligible: $playerEligible) for Initial Tier $leagueTier League.");

      int slotsToFill = template.numberOfTeams;
      // --- MODIFICATION: Don't reserve slot for player in Tier 3 initially ---
      // Let Tier 3 fill up, player can join later if eligible.
      // For Tier 1/2, player isn't allowed anyway for now.
      // --- END MODIFICATION ---

      for (var club in eligibleAIClubs) { if (participants.length >= slotsToFill) break; participants.add(club.id); }
      print(" -> Added ${participants.length} AI Clubs.");
      int aiClubsAdded = participants.length;
      for (var academy in eligibleYouthAcademies) { if (participants.length >= slotsToFill) break; if (academy is RivalAcademy) participants.add(academy.id); }
      print(" -> Added ${participants.length - aiClubsAdded} Youth Academies.");

      // --- MODIFICATION: Adjust min required check based on player eligibility for Tier 3 ---
      int minRequired = template.minTeamsToStart;
      // If player is eligible for Tier 3, they can potentially make up the numbers later
      if (playerEligible && leagueTier == 3) minRequired--;
      // --- END MODIFICATION ---

      if (participants.length >= minRequired) enoughParticipantsFound = true;
      else print(" -> Not enough participants (${participants.length}) for Initial League ${template.name}. Min required (allowing for player): $minRequired. League will not be scheduled.");
      // --- End Participant Gathering ---

      if (enoughParticipantsFound) {
        // Use the schedulingDate (which is the game start date) to create the tournament instance.
        // The tournament's internal logic will set the actual match dates starting from this.
        Tournament newTournament = Tournament.fromTemplate(template, participants, schedulingDate);
        addActiveTournament(newTournament);
        for (var participantId in participants) { _rivalAcademyMap[participantId]?.activeTournamentIds.add(newTournament.id); _aiClubMap[participantId]?.activeTournamentIds.add(newTournament.id); }
        // Adjust join window message slightly
        String joinWindow = (leagueTier == 3 && playerEligible)
            ? "You can join this league if you meet the requirements."
            : "This league is for AI clubs and high-reputation academies."; // Generic message for T1/T2
        _addNewsItem(NewsItem.create(title: "Pro League Scheduled", description: "${newTournament.name} is scheduled to start soon with ${participants.length} teams confirmed. $joinWindow", type: NewsItemType.Tournament, date: _timeService.currentDate));
        print(" -> Scheduled Initial ${newTournament.name} (ID: ${newTournament.id}) starting around ${DateFormat.yMMMd().format(newTournament.startDate)} with ${participants.length} teams.");
      }
    }
    print("--- Finished Scheduling Initial Pro Leagues ---");
  }
  // --- END Schedule Initial Pro Leagues ---

  // --- NEW: Handle Merchandise Sales & Fan Updates ---
  void _handleMerchandiseAndFans() {
    // --- Fan Fluctuation based on recent performance ---
    // This is a simplified version. Could be tied to specific match results from the past week.
    // For now, a general small fluctuation.
    int fanChange = 0;
    if (_random.nextDouble() < 0.1) { // 10% chance of fan change event
      fanChange = _random.nextInt(11) - 5; // -5 to +5 fans
      // Bonus for high reputation
      if (_academyReputation > 300) fanChange += _random.nextInt( (_academyReputation ~/ 100) );
      // Penalty for very low reputation
      if (_academyReputation < 50) fanChange -= _random.nextInt(3);
    }
    _fans = max(0, _fans + fanChange); // Ensure fans don't go below 0

    // --- Merchandise Sales ---
    double merchandiseIncomeThisWeek = 0;
    Staff? merchManager = _hiredStaff.firstWhereOrNull((s) => s.role == StaffRole.MerchandiseManager);

    // 1. Sales at Games (if no store or low level store)
    // This part assumes matches were played this week. We need a way to check that.
    // For simplicity, let's assume some base "at game" sales potential if a manager is hired,
    // even without a store, or if the store is very basic.
    if (merchManager != null && _merchandiseStoreLevel <= 1) {
      // Income based on fans, manager skill, and a bit of luck
      // Lower income compared to a dedicated store
      double atGameSales = (_fans * 0.05) * (merchManager.skill / 100.0) * (0.5 + _random.nextDouble() * 0.5);
      merchandiseIncomeThisWeek += atGameSales.clamp(0, 500); // Cap at-game sales
    }

    // 2. Sales from Merchandise Store (if built and level > 0)
    if (_merchandiseStoreLevel > 0 && merchManager != null) {
      double storeBaseIncome = _merchandiseStoreLevel * 100.0; // Base income per store level
      double fanMultiplier = 1 + (_fans / 500.0); // More fans, more sales
      double managerSkillMultiplier = 0.5 + (merchManager.skill / 200.0); // Skill up to 1.0 multiplier
      double randomFactor = 0.8 + _random.nextDouble() * 0.4; // 0.8 to 1.2

      double storeIncome = storeBaseIncome * fanMultiplier * managerSkillMultiplier * randomFactor;

      // Potential for negative outcome if manager skill is very low or bad luck
      if (merchManager.skill < 30 && _random.nextDouble() < 0.15) { // 15% chance of negative if skill < 30
        double lossAmount = storeIncome * (0.2 + _random.nextDouble() * 0.3); // Lose 20-50% of potential income
        storeIncome -= lossAmount;
        _addNewsItem(NewsItem.create(
            title: "Merchandise Mismanagement",
            description: "Poor handling at the club store led to a loss of ${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(lossAmount.abs())} this week.",
            type: NewsItemType.Finance, // Or a new type like Merch
            date: _timeService.currentDate));
      }
      merchandiseIncomeThisWeek += storeIncome;
    } else if (_merchandiseStoreLevel > 0 && merchManager == null) {
      // Store exists but no manager - reduced income and higher chance of small loss
      double storeBaseIncome = _merchandiseStoreLevel * 50.0; // Reduced base without manager
      double fanMultiplier = 1 + (_fans / 1000.0); // Reduced fan impact
      merchandiseIncomeThisWeek += storeBaseIncome * fanMultiplier * (0.5 + _random.nextDouble() * 0.3); // Lower random factor

      if (_random.nextDouble() < 0.25) { // 25% chance of a small loss
        double lossAmount = (storeBaseIncome * fanMultiplier) * (0.1 + _random.nextDouble() * 0.2);
        merchandiseIncomeThisWeek -= lossAmount;
         _addNewsItem(NewsItem.create(
            title: "Merch Store Issues",
            description: "The unmanaged club store incurred a small loss of ${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(lossAmount.abs())} this week.",
            type: NewsItemType.Finance,
            date: _timeService.currentDate));
      }
    }

    if (merchandiseIncomeThisWeek.abs() > 0.01) { // Only add to balance and news if there's actual income/loss
        if (merchandiseIncomeThisWeek >= 0) {
          _financeService.addIncome(merchandiseIncomeThisWeek);
        } else {
          _financeService.deductExpense(merchandiseIncomeThisWeek.abs());
        }

        String incomeOrLossString = merchandiseIncomeThisWeek >= 0 ? "income" : "loss";
        _addNewsItem(NewsItem.create(
            title: "Merchandise Sales Update",
            description: "This week's merchandise $incomeOrLossString: ${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(merchandiseIncomeThisWeek)}. Current fans: $_fans.",
            type: NewsItemType.Finance, // Or a new type
            date: _timeService.currentDate));
    }
    // print("Merchandise income this week: $merchandiseIncomeThisWeek. Fans: $_fans"); // Less verbose
  }
  // --- END Handle Merchandise Sales & Fan Updates ---

  // --- End Save/Load Logic ---
}
