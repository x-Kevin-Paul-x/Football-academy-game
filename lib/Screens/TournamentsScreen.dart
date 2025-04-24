import 'package:flutter/material.dart';
import 'package:football_academy_game/Screens/TournamentHistoryScreen.dart';
import '../models/tournament.dart'; // Import the Tournament model
import '../models/ai_club.dart'; // Import AIClub model
import '../models/match.dart'; // Import Match model
import 'dart:math'; // For random selection of AI clubs
import 'package:provider/provider.dart'; // Import Provider
import '../game_state_manager.dart'; // Import GameStateManager
import 'TournamentDetailsScreen.dart'; // Import the details screen

// --- Define Game Start Date Reference ---
// NOTE: This should ideally match the initial _currentDate in GameStateManager
final DateTime gameStartDateReference = DateTime(2025, 7, 1);
// ---

// Mock data for available tournaments - using gameStartDateReference
final List<Tournament> availableTournaments = [
  Tournament(
    id: 't_3v3_1',
    name: 'Local Kickabout',
    type: TournamentType.threeVthree,
    requiredPlayers: 3,
    participants: [], // Will be filled later (mutable list needed)
    // startDate: gameStartDateReference.add(const Duration(days: 7)), // REMOVED
    prize: '\$100 + Reputation',
    // status and matches use default values
  ),
  Tournament(
    id: 't_5v5_1',
    name: 'City Futsal Cup',
    type: TournamentType.fiveVfive,
    requiredPlayers: 5,
    participants: [], // Mutable list needed
    // startDate: gameStartDateReference.add(const Duration(days: 14)), // REMOVED
    prize: '\$250 + Reputation',
    // status and matches use default values
  ),
  Tournament(
    id: 't_7v7_1',
    name: 'Regional Challenge',
    type: TournamentType.sevenVseven,
    requiredPlayers: 7,
    participants: [], // Mutable list needed
    // startDate: gameStartDateReference.add(const Duration(days: 21)), // REMOVED
    prize: '\$500 + Reputation',
    // status and matches use default values
  ),
  Tournament(
    id: 't_11v11_league',
    name: 'Youth Development League',
    type: TournamentType.elevenVeleven,
    requiredPlayers: 11,
    participants: [], // Mutable list needed
    // startDate: gameStartDateReference.add(const Duration(days: 30)), // REMOVED
    prize: 'League Trophy + \$1000 + Reputation',
    // status and matches use default values
  ),
  // --- Added More Tournaments ---
  Tournament(
    id: 't_5v5_2',
    name: 'Summer Futsal Jam',
    type: TournamentType.fiveVfive,
    requiredPlayers: 5,
    participants: [],
    prize: '\$300 + Reputation',
  ),
  Tournament(
    id: 't_7v7_2',
    name: 'District Cup',
    type: TournamentType.sevenVseven,
    requiredPlayers: 7,
    participants: [],
    prize: '\$600 + Reputation',
  ),
  // --- End Added ---
];

class TournamentsScreen extends StatefulWidget {
  // final int academyPlayerCount; // REMOVED parameter

  const TournamentsScreen({
    Key? key,
    // required this.academyPlayerCount, // REMOVED
  }) : super(key: key);

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  // Use widget.academyPlayerCount instead of local placeholder
  // final int currentPlayerCount = 0; // <<< REMOVED
  final String playerAcademyId = 'player_academy_1'; // Example academy ID (keep for now)
  // final int playerAcademySkill = 60; // REMOVED - Skill is now calculated in GameStateManager
  // final List<AIClub> allAICLubs = ...; // REMOVED - Now in GameStateManager
  // final Map<String, AIClub> aiClubMap = {}; // REMOVED - Now in GameStateManager

  // REMOVED initState as aiClubMap is no longer local

  @override
  Widget build(BuildContext context) {
    // Use Consumer to get player count and other relevant state
    return Consumer<GameStateManager>(
      builder: (context, gameStateManager, child) {
        // Use gameStateManager.academyPlayers.length for logic
        int currentPlayerCount = gameStateManager.academyPlayers.length; // Get count from provider

        // Determine the highest unlocked tournament type based on player count
        TournamentType highestUnlocked = TournamentType.threeVthree; // Start with 3v3
        if (currentPlayerCount >= 5) highestUnlocked = TournamentType.fiveVfive;
        if (currentPlayerCount >= 7) highestUnlocked = TournamentType.sevenVseven;
        if (currentPlayerCount >= 11) highestUnlocked = TournamentType.elevenVeleven;

        // Filter tournaments: Show only unlocked AND non-completed ones
        final List<Tournament> displayTournaments = availableTournaments
            .where((t) => t.requiredPlayers <= currentPlayerCount && t.status != TournamentStatus.Completed) // Filter out completed
            .toList();

        // Wrap the ListView in a Scaffold to add an AppBar
        return Scaffold(
          // Add AppBar for the history button
          appBar: AppBar(
            title: const Text("Available & Active Tournaments"), // Give it a title
            automaticallyImplyLeading: false, // Remove back button if it appears
            actions: [
              IconButton(
                icon: const Icon(Icons.history),
            tooltip: 'Tournament History',
            onPressed: () {
              // Navigate to the TournamentHistoryScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TournamentHistoryScreen()),
              );
            },
          ),
            ],
          ),
          body: ListView.builder( // The original ListView becomes the body
            padding: const EdgeInsets.all(8.0),
            itemCount: displayTournaments.length,
            itemBuilder: (context, index) {
              final tournament = displayTournaments[index];
              // Use currentPlayerCount (from provider) for canEnter check
              final bool canEnter = currentPlayerCount >= tournament.requiredPlayers;
              // Basic check for progression - only allow entry if it's the 'next' type or lower
              // TODO: This logic needs refinement based on actual game state (e.g., won previous tier)
              final bool isUnlockedProgression = tournament.type.index <= highestUnlocked.index;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 3,
                child: ListTile(
                  leading: Icon(
                    _getTournamentIcon(tournament.type),
                    color: Theme.of(context).colorScheme.secondary,
                    size: 40,
                  ),
                  title: Text(tournament.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tournament.typeDisplay),
                      Text('Requires: ${tournament.requiredPlayers} players'),
                      Text('Prize: ${tournament.prize}'),
                      // Text('Starts: ${tournament.startDate.toLocal().toString().split(' ')[0]}'), // REMOVED Start Date Display
                    ],
                  ),
                  // Pass currentPlayerCount to _buildEnterButton
                  trailing: _buildEnterButton(context, tournament, canEnter, isUnlockedProgression, currentPlayerCount),
                  // Allow tap ONLY if an instance of this tournament is currently in progress
                  onTap: () {
                    Tournament? activeInstance; // Initialize as nullable
                    // Find the active instance corresponding to this template
                    for (final activeT in gameStateManager.activeTournaments) {
                      if (activeT.baseId == tournament.id) {
                        activeInstance = activeT;
                        break; // Found it, no need to continue loop
                      }
                    }

                    if (activeInstance != null) {
                      // Navigate using the active instance
                      _navigateToDetails(context, activeInstance);
                    }
                    // If no active instance, onTap does nothing
                  },
                  isThreeLine: true, // Keep consistent height
                ),
              );
            },
          ), // End ListView.builder
        ); // End Scaffold
      }, // End Consumer builder
    ); // End Consumer
  }

  IconData _getTournamentIcon(TournamentType type) {
    switch (type) {
      case TournamentType.threeVthree:
        return Icons.looks_3;
      case TournamentType.fiveVfive:
        return Icons.looks_5;
      case TournamentType.sevenVseven:
        return Icons.looks_one; // Using 'looks_one' as a placeholder for 7
      case TournamentType.elevenVeleven:
        return Icons.groups; // Icon for full team/league
      default:
        return Icons.emoji_events;
    }
  }

  // Add currentPlayerCount parameter
  Widget _buildEnterButton(BuildContext context, Tournament tournamentTemplate, bool canEnter, bool isUnlockedProgression, int currentPlayerCount) {
    // Get GameStateManager to check active tournaments
    final gameStateManager = Provider.of<GameStateManager>(context, listen: false);

    // Check if an instance of this tournament template is currently active
    final bool isAlreadyInProgress = gameStateManager.activeTournaments.any(
      (activeTournament) => activeTournament.baseId == tournamentTemplate.id
    );

    // Explicitly check player count requirement here for the button state
    final bool meetsPlayerRequirement = currentPlayerCount >= tournamentTemplate.requiredPlayers;

    if (isAlreadyInProgress) { // Check if an instance is active
      return ElevatedButton(
        onPressed: null, // Disabled if already in progress
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[300], // Indicate in progress
          foregroundColor: Colors.black87,
        ),
        child: const Text('In Progress'), // Show 'In Progress'
      );
    } else {
      // Tournament template is available and no instance is active
      // Ensure all conditions (player count, progression) are met for enabling the button
      final bool canActuallyEnter = meetsPlayerRequirement && isUnlockedProgression;
      return ElevatedButton(
        // Pass the tournament *template* to _enterTournament
        onPressed: canActuallyEnter ? () {
          _enterTournament(tournamentTemplate, currentPlayerCount); // Pass template
        } : null, // Disable button if requirements not met (player count or progression)
        style: ElevatedButton.styleFrom(
           backgroundColor: canActuallyEnter
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[600], // Greyed out if cannot enter
           foregroundColor: canActuallyEnter
              ? Theme.of(context).colorScheme.onPrimary
              : Colors.grey[400], // Greyed out text
        ),
        child: const Text('Enter'),
      );
    }
  }

  // Add currentPlayerCount parameter
  void _enterTournament(Tournament tournament, int currentPlayerCount) {
    // Check status instead of ID set
    if (tournament.status != TournamentStatus.Available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tournament ${tournament.name} is already in progress or completed.')),
      );
      return;
    }

    // *** Add explicit check before proceeding ***
    // Use currentPlayerCount (from provider) for the check
    if (currentPlayerCount < tournament.requiredPlayers) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot enter ${tournament.name}. Requires ${tournament.requiredPlayers} players, you have $currentPlayerCount.')),
      );
      return; // Stop execution if not enough players
    }

    // --- Create a unique instance of the tournament for this entry ---
    final String instanceId = '${tournament.id}_${DateTime.now().millisecondsSinceEpoch}';
    final Tournament tournamentInstance = Tournament(
      id: instanceId, // Unique ID for this run
      baseId: tournament.id, // Store the original template ID
      name: tournament.name,
      type: tournament.type,
      requiredPlayers: tournament.requiredPlayers,
      prize: tournament.prize,
      participants: [], // Start with fresh participants list for the instance
      matches: [],      // Start with fresh matches list for the instance
      status: TournamentStatus.InProgress, // Will be set to InProgress shortly
    );
    // ---

    // Add player's academy to the instance
    tournamentInstance.participants.add(playerAcademyId);

    // Add AI clubs to the instance
    int numberOfAIClubsToAdd = 0;
    switch (tournament.type) {
      case TournamentType.threeVthree:
        numberOfAIClubsToAdd = 3; // 1 player + 3 AI = 4 total
        break;
      case TournamentType.fiveVfive:
        numberOfAIClubsToAdd = 5; // 1 player + 5 AI = 6 total
        break;
      case TournamentType.sevenVseven:
        numberOfAIClubsToAdd = 7; // 1 player + 7 AI = 8 total
        break;
      case TournamentType.elevenVeleven:
        numberOfAIClubsToAdd = 11; // Example: 1 player + 11 AI = 12 total (adjust as needed)
        break;
    }

    // Get AI club data from GameStateManager
    final gameStateManager = Provider.of<GameStateManager>(context, listen: false);
    final allAICLubsFromManager = gameStateManager.aiClubMap.values.toList(); // Get list from map

    // Ensure we don't try to add more AI clubs than available (excluding player)
    numberOfAIClubsToAdd = min(numberOfAIClubsToAdd, allAICLubsFromManager.length);

    // Select random AI clubs that are not the player
    final random = Random();
    final availableAI = allAICLubsFromManager.toList(); // Create a mutable copy
    availableAI.shuffle(random);

    int addedCount = 0;
    for (var aiClub in availableAI) {
      if (addedCount < numberOfAIClubsToAdd) {
        tournamentInstance.participants.add(aiClub.id); // Add to instance
        addedCount++;
      } else {
        break;
      }
    }

    // Get the current date from GameStateManager to use as the entry date
    final DateTime entryDate = gameStateManager.currentDate; // Already have gameStateManager

    // Generate the match schedule relative to the entry date for the instance
    List<Match> generatedMatches = _generateMatches(tournamentInstance, entryDate); // Pass instance

    // Update the tournament instance
    tournamentInstance.matches = generatedMatches;
    // tournamentInstance.status = TournamentStatus.InProgress; // Already set during creation

    // Notify GameStateManager that this tournament *instance* is now active
    gameStateManager.addActiveTournament(tournamentInstance); // Pass instance

    // Trigger UI refresh (though the button state change is the main visual feedback)
    setState(() {}); // Rebuild to update button states based on GameStateManager

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Entered ${tournamentInstance.name}! Schedule generated with ${generatedMatches.length} matches.')),
    );

    // TODO: Need to notify Dashboard/Game State Manager that a tournament is active // <<< Kept TODO as reminder
    // This will be handled when integrating with the weekly advance logic. // <<< Kept TODO as reminder
  }

  // Updated: Generates match schedule relative to entryDate
  List<Match> _generateMatches(Tournament tournament, DateTime entryDate) {
    List<Match> generatedMatches = [];
    List<String> participants = tournament.participants;
    if (participants.length < 2) return generatedMatches;

    int matchesPerWeek = (participants.length / 2).floor(); // Simple: half the teams play each week
    int weekOffset = 0;
    int matchInWeekCounter = 0;

    // Basic round-robin generation
    for (int i = 0; i < participants.length; i++) {
      for (int j = i + 1; j < participants.length; j++) {
        String homeTeamId = participants[i];
        String awayTeamId = participants[j];

        // Create unique match ID
        String matchId = 'm_${tournament.id}_${homeTeamId}_vs_${awayTeamId}';

        // Calculate match date based on weeks FROM THE ENTRY DATE
        // Add 1 day buffer so first match isn't on the exact entry day? Optional.
        DateTime matchDate = entryDate.add(Duration(days: 1 + (weekOffset * 7)));

        // Create the match object (unsimulated)
        Match match = Match(
          id: matchId,
          tournamentId: tournament.id,
          homeTeamId: homeTeamId,
          awayTeamId: awayTeamId,
          matchDate: matchDate,
          // homeScore, awayScore, result, isSimulated will be null/false initially
        );

        generatedMatches.add(match);

        // Increment week offset logic (very basic, needs proper scheduling algorithm later)
        matchInWeekCounter++;
        if (matchInWeekCounter >= matchesPerWeek) {
          weekOffset++;
          matchInWeekCounter = 0;
        }
      }
    }
    return generatedMatches;
  }

  // REMOVED _getTeamSkill - This logic is now centralized in GameStateManager._getTeamSkill

  // Helper to get AI club name from ID (can be removed if not used elsewhere)
  // String _getTeamName(String teamId) {
  //   if (teamId == playerAcademyId) {
  //     return "My Academy"; // Replace with actual academy name later
  //   } else {
  //     return aiClubMap[teamId]?.name ?? 'Unknown Club';
  //   }
  // }

  // Navigate to the details screen
  void _navigateToDetails(BuildContext context, Tournament tournament) {
    // Get matches directly from the tournament object
    final List<Match> matches = tournament.matches;
    // Get the AI Club Map from GameStateManager
    final aiClubMapFromManager = Provider.of<GameStateManager>(context, listen: false).aiClubMap;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentDetailsScreen(
          tournament: tournament,
          matches: matches,
          aiClubMap: aiClubMapFromManager, // Pass map from GameStateManager
          playerAcademyId: playerAcademyId,
        ),
      ),
    );
  }
}
