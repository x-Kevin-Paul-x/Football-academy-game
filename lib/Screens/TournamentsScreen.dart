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
    requiredReputation: 0, // No rep needed for the first one
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
    requiredReputation: 50, // Example requirement
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
    requiredReputation: 100, // Example requirement
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
    requiredReputation: 150, // Example requirement
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
    requiredReputation: 75, // Example requirement
  ),
  Tournament(
    id: 't_7v7_2',
    name: 'District Cup',
    type: TournamentType.sevenVseven,
    requiredPlayers: 7,
    participants: [],
    prize: '\$600 + Reputation',
    requiredReputation: 120, // Example requirement
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
                      Text('Reputation Req: ${tournament.requiredReputation}'), // Display Reputation Req
                      Text('Prize: ${tournament.prize}'),
                      // Text('Starts: ${tournament.startDate.toLocal().toString().split(' ')[0]}'), // REMOVED Start Date Display
                    ],
                  ),
                  // Pass currentPlayerCount and academyReputation to _buildEnterButton
                  trailing: _buildEnterButton(context, tournament, canEnter, isUnlockedProgression, currentPlayerCount, gameStateManager.academyReputation),
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

  // Add currentPlayerCount and academyReputation parameters
  Widget _buildEnterButton(BuildContext context, Tournament tournamentTemplate, bool canEnter, bool isUnlockedProgression, int currentPlayerCount, int currentAcademyReputation) {
    // Get GameStateManager (needed for _enterTournament call)
    final gameStateManager = Provider.of<GameStateManager>(context, listen: false);

    // Check if an instance of this tournament template is currently active
    final bool isAlreadyInProgress = gameStateManager.activeTournaments.any(
      (activeTournament) => activeTournament.baseId == tournamentTemplate.id
    );

    // Explicitly check requirements here for the button state
    final bool meetsPlayerRequirement = currentPlayerCount >= tournamentTemplate.requiredPlayers;
    final bool meetsReputationRequirement = currentAcademyReputation >= tournamentTemplate.requiredReputation;

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
      // Ensure all conditions (player count, reputation, progression) are met for enabling the button
      final bool canActuallyEnter = meetsPlayerRequirement && meetsReputationRequirement && isUnlockedProgression;
      String buttonText = 'Enter';
      Color? buttonColor = canActuallyEnter ? Theme.of(context).colorScheme.primary : Colors.grey[600];
      Color? textColor = canActuallyEnter ? Theme.of(context).colorScheme.onPrimary : Colors.grey[400];
      String? tooltipMessage;

      if (!meetsPlayerRequirement) {
        tooltipMessage = 'Need ${tournamentTemplate.requiredPlayers} players';
      } else if (!meetsReputationRequirement) {
        tooltipMessage = 'Need ${tournamentTemplate.requiredReputation} reputation (Have $currentAcademyReputation)';
      } else if (!isUnlockedProgression) {
        tooltipMessage = 'Unlock by progressing further'; // Placeholder message
      }

      Widget buttonChild = Text(buttonText);
      if (tooltipMessage != null && !canActuallyEnter) {
         // Wrap button in Tooltip if disabled and there's a reason
         buttonChild = Tooltip(
           message: tooltipMessage,
           child: buttonChild,
         );
      }


      return ElevatedButton(
        // Pass the tournament *template* to _enterTournament
        onPressed: canActuallyEnter ? () {
          // Pass current reputation to _enterTournament for the check
          _enterTournament(tournamentTemplate, currentPlayerCount, currentAcademyReputation);
        } : null, // Disable button if requirements not met
        style: ElevatedButton.styleFrom(
           backgroundColor: buttonColor,
           foregroundColor: canActuallyEnter
              ? Theme.of(context).colorScheme.onPrimary
              : Colors.grey[400], // Greyed out text
        ),
        child: const Text('Enter'),
      );
    }
  }

  // Add currentPlayerCount and currentAcademyReputation parameters
  void _enterTournament(Tournament tournament, int currentPlayerCount, int currentAcademyReputation) {
    // Check status
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

    // *** Add reputation check ***
    if (currentAcademyReputation < tournament.requiredReputation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot enter ${tournament.name}. Requires ${tournament.requiredReputation} reputation, you have $currentAcademyReputation.')),
      );
      return; // Stop execution if not enough reputation
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
      requiredReputation: tournament.requiredReputation, // Pass from template
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

  // Updated: Generates a round-robin match schedule relative to entryDate
  List<Match> _generateMatches(Tournament tournament, DateTime entryDate) {
    List<Match> generatedMatches = [];
    List<String> teams = List.from(tournament.participants); // Mutable copy

    // Handle odd number of teams by adding a dummy "bye" team
    bool isOdd = teams.length % 2 != 0;
    if (isOdd) {
      teams.add("bye");
    }

    int numTeams = teams.length;
    int numRounds = numTeams - 1; // Each team plays every other team once
    int matchesPerRound = numTeams ~/ 2;

    List<String> roundTeams = List.from(teams); // List to rotate

    for (int round = 0; round < numRounds; round++) {
      DateTime roundStartDate = entryDate.add(Duration(days: 1 + (round * 7))); // Start matches 1 day after the week starts

      for (int matchIndex = 0; matchIndex < matchesPerRound; matchIndex++) {
        String homeTeamId = roundTeams[matchIndex];
        String awayTeamId = roundTeams[numTeams - 1 - matchIndex];

        // Skip matches involving the dummy "bye" team
        if (homeTeamId == "bye" || awayTeamId == "bye") {
          continue;
        }

        // Alternate home/away based on round or match index if desired (simple version: first is home)
        // For simplicity, we'll just use the pairing as is for now.

        String matchId = 'm_${tournament.id}_${homeTeamId}_vs_${awayTeamId}_r${round}';
        DateTime matchDate = roundStartDate; // All matches in a round happen in the same week

        Match match = Match(
          id: matchId,
          tournamentId: tournament.id,
          homeTeamId: homeTeamId,
          awayTeamId: awayTeamId,
          matchDate: matchDate,
        );
        generatedMatches.add(match);
      }

      // Rotate teams for the next round (excluding the first team if numTeams > 2)
      if (numTeams > 2) {
         String lastTeam = roundTeams.removeLast();
         roundTeams.insert(1, lastTeam); // Insert the last team after the first one
      }
    }

     // Optional: If you want a double round-robin (each team plays each other twice, home and away)
     // You can duplicate the generatedMatches list, swap home/away teams, and adjust dates.
     // For now, we'll stick to single round-robin.

    print("Generated ${generatedMatches.length} matches for ${tournament.name} over $numRounds rounds.");
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
