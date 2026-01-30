import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../game_state_manager.dart';
import '../models/tournament.dart';
import '../models/rival_academy.dart'; // Import RivalAcademy
import 'TournamentDetailsScreen.dart'; // Import TournamentDetailsScreen
import '../widgets/empty_state.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({Key? key}) : super(key: key);

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  final String playerAcademyId = GameStateManager.playerAcademyId; // Use constant from GameStateManager

  @override
  Widget build(BuildContext context) {
    // Use Consumer to get player count and other relevant state
    return Consumer<GameStateManager>(
      builder: (context, gameStateManager, child) {
        int currentPlayerCount = gameStateManager.academyPlayers.length;

        // Determine the highest unlocked tournament type based on player count (simple logic for now)
        TournamentType highestUnlocked = TournamentType.threeVthree; // Start with 3v3
        if (currentPlayerCount >= 5) highestUnlocked = TournamentType.fiveVfive;
        if (currentPlayerCount >= 7) highestUnlocked = TournamentType.sevenVseven;
        if (currentPlayerCount >= 11) highestUnlocked = TournamentType.elevenVeleven;

        return DefaultTabController(
          length: 3, // Available, Active, History
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Tournaments"),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Available'), // Show templates player can join
                  Tab(text: 'Active'), // Show Scheduled & InProgress instances
                  Tab(text: 'History'), // Show Completed instances
                ],
              ),
            ),
            body: TabBarView(
              children: [
                // --- Available Tournaments Tab (Templates) ---
                _buildTournamentList(
                  gameStateManager.availableTournamentTemplates,
                  isTemplates: true,
                  gameStateManager: gameStateManager,
                  currentPlayerCount: currentPlayerCount,
                  highestUnlocked: highestUnlocked,
                  emptyTitle: "No tournaments available",
                  emptyMessage: "Check back later for new opportunities.",
                  emptyIcon: Icons.emoji_events_outlined,
                ),
                // --- Active Tournaments Tab (Scheduled & InProgress Instances) ---
                _buildTournamentList(
                  gameStateManager.activeTournaments, // Show all active (Scheduled + InProgress)
                  isTemplates: false,
                  gameStateManager: gameStateManager,
                  currentPlayerCount: currentPlayerCount,
                  highestUnlocked: highestUnlocked,
                  emptyTitle: "No active tournaments",
                  emptyMessage: "Join a tournament to see it here.",
                  emptyIcon: Icons.event_busy,
                ),
                // --- History Tab (Completed Instances) ---
                _buildTournamentList(
                  gameStateManager.completedTournaments,
                  isTemplates: false, // It's an instance list, not templates
                  gameStateManager: gameStateManager,
                  currentPlayerCount: currentPlayerCount, // Not strictly needed for history, but pass for consistency
                  highestUnlocked: highestUnlocked, // Not strictly needed for history
                  emptyTitle: "No completed tournaments",
                  emptyMessage: "Complete tournaments to view your history.",
                  emptyIcon: Icons.history,
                ),
              ],
            ),
          ),
        );
      }, // End Consumer builder
    ); // End Consumer
  }

  Widget _buildTournamentList(
    List<Tournament> tournaments, {
    required bool isTemplates,
    required GameStateManager gameStateManager,
    required int currentPlayerCount,
    required TournamentType highestUnlocked, // Keep for potential future filtering
    required String emptyTitle,
    required String emptyMessage,
    required IconData emptyIcon,
  }) {
    if (tournaments.isEmpty) {
      return EmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        message: emptyMessage,
      );
    }

    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    // *** FIX: Create a mutable copy before sorting ***
    final List<Tournament> displayTournaments = List<Tournament>.from(tournaments);

    // Sort active tournaments: InProgress first, then Scheduled by date
    if (!isTemplates && displayTournaments.any((t) => t.status != TournamentStatus.Completed)) {
      displayTournaments.sort((a, b) {
        if (a.status == TournamentStatus.InProgress && b.status != TournamentStatus.InProgress) return -1;
        if (a.status != TournamentStatus.InProgress && b.status == TournamentStatus.InProgress) return 1;
        // If both are Scheduled or both InProgress, sort by start date
        return a.startDate.compareTo(b.startDate);
      });
    }
    // Sort completed tournaments by start date descending (newest first)
    else if (!isTemplates && displayTournaments.every((t) => t.status == TournamentStatus.Completed)) {
       displayTournaments.sort((a, b) => b.startDate.compareTo(a.startDate));
    }
    // No sorting needed for templates (isTemplates == true)

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      // *** FIX: Use the mutable list's length ***
      itemCount: displayTournaments.length,
      itemBuilder: (context, index) {
        // *** FIX: Use the mutable list to get the tournament ***
        final tournament = displayTournaments[index];
        bool canJoin = false;
        bool alreadyJoined = false;
        bool meetsReputation = false;
        bool meetsPlayers = false;

        if (isTemplates) {
          meetsPlayers = currentPlayerCount >= tournament.requiredPlayers;
          meetsReputation = gameStateManager.academyReputation >= tournament.requiredReputation;
          canJoin = meetsPlayers && meetsReputation && gameStateManager.balance >= tournament.entryFee;

          alreadyJoined = gameStateManager.activeTournaments.any((at) =>
              at.baseId == tournament.id && at.teamIds.contains(playerAcademyId)
          );
        } else {
           alreadyJoined = tournament.teamIds.contains(playerAcademyId);
        }

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
                Text('Type: ${tournament.typeDisplay}'),
                Text('Requires: ${tournament.requiredPlayers} players'),
                Text('Reputation Req: ${tournament.requiredReputation}'),
                Text('Entry Fee: ${currencyFormat.format(tournament.entryFee)}'),
                Text('Prize (Base): ${currencyFormat.format(tournament.prizeMoneyBase)}'),
                if (!isTemplates) // Show status and dates only for instances
                  Text('Status: ${tournament.status.toString().split('.').last}'),
                if (!isTemplates)
                   Text('Teams: ${tournament.teamIds.length} / ${tournament.numberOfTeams}'),
                if (!isTemplates && tournament.status != TournamentStatus.Scheduled)
                   Text('Starts: ${DateFormat.yMMMd().format(tournament.startDate)}'),
                if (tournament.status == TournamentStatus.Completed && tournament.winnerId != null)
                   Text('Winner: ${_getTeamName(tournament.winnerId!, gameStateManager)}', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
              ],
            ),
            trailing: isTemplates
              ? _buildEnterButton(
                  context,
                  tournament, // Pass template
                  canJoin,
                  alreadyJoined,
                  meetsPlayers,
                  meetsReputation,
                  gameStateManager,
                )
              : (tournament.status != TournamentStatus.Scheduled // Don't show button for scheduled before start
                  ? IconButton(
                      icon: const Icon(Icons.info_outline),
                      tooltip: 'View Details',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TournamentDetailsScreen(tournamentId: tournament.id),
                          ),
                        );
                      },
                    )
                  : null // No button for scheduled
                ),
             onTap: !isTemplates && tournament.status != TournamentStatus.Scheduled
                ? () { // Allow tapping list tile to navigate for active/completed
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TournamentDetailsScreen(tournamentId: tournament.id),
                      ),
                    );
                  }
                : null, // No action on tap for templates or scheduled
            isThreeLine: true, // Adjust based on content, might need more lines
          ),
        );
      },
    );
  }

  IconData _getTournamentIcon(TournamentType type) {
    switch (type) {
      case TournamentType.threeVthree: return Icons.looks_3;
      case TournamentType.fiveVfive: return Icons.looks_5;
      case TournamentType.sevenVseven: return Icons.looks_one; // Placeholder
      case TournamentType.elevenVeleven: return Icons.emoji_events; // Trophy icon
      default: return Icons.help_outline;
    }
  }

  Widget _buildEnterButton(
    BuildContext context,
    Tournament tournamentTemplate,
    bool canJoinOverall, // Combined check: players, rep, balance
    bool alreadyJoined,
    bool meetsPlayers, // Individual checks for tooltip
    bool meetsReputation, // Individual checks for tooltip
    GameStateManager gameStateManager,
  ) {
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    if (alreadyJoined) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[300],
          foregroundColor: Colors.black87,
        ),
        child: const Text('Joined'),
      );
    }

    String buttonText = 'Join';
    Color? buttonColor = canJoinOverall ? Theme.of(context).colorScheme.primary : Colors.grey[600];
    Color? textColor = canJoinOverall ? Theme.of(context).colorScheme.onPrimary : Colors.grey[400];
    String? tooltipMessage;

    if (!meetsPlayers) {
      tooltipMessage = 'Need ${tournamentTemplate.requiredPlayers} players (Have ${gameStateManager.academyPlayers.length})';
    } else if (!meetsReputation) {
      tooltipMessage = 'Need ${tournamentTemplate.requiredReputation} reputation (Have ${gameStateManager.academyReputation})';
    } else if (gameStateManager.balance < tournamentTemplate.entryFee) {
       tooltipMessage = 'Need ${currencyFormat.format(tournamentTemplate.entryFee)} (Have ${currencyFormat.format(gameStateManager.balance)})';
    }

    // Create the button widget first
    Widget joinButton = ElevatedButton(
      onPressed: canJoinOverall
          ? () {
              _showJoinConfirmationDialog(
                  context, tournamentTemplate, gameStateManager);
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: textColor,
      ),
      child: Text(buttonText),
    );

    // If there's a tooltip message (e.g. reasoning for being disabled), wrap the button
    // Wrapping the entire button is necessary for tooltips to work on disabled buttons
    if (tooltipMessage != null && !canJoinOverall) {
      return Tooltip(
        message: tooltipMessage,
        child: joinButton,
      );
    }

    return joinButton;
  }

  // Helper to get team name
  String _getTeamName(String teamId, GameStateManager gameState) {
    if (teamId == playerAcademyId) {
      return gameState.academyName;
    }
    return gameState.rivalAcademyMap[teamId]?.name ?? teamId; // Fallback to ID
  }

  // --- Join Confirmation Dialog ---
  void _showJoinConfirmationDialog(BuildContext context, Tournament template, GameStateManager gameState) {
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Join ${template.name}?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Entry Fee: ${currencyFormat.format(template.entryFee)}'),
              Text('Reputation Required: ${template.requiredReputation}'),
              Text('Players Required: ${template.requiredPlayers}'),
              const SizedBox(height: 10),
              Text('Your Balance: ${currencyFormat.format(gameState.balance)}'),
              Text('Your Reputation: ${gameState.academyReputation}'),
              Text('Your Players: ${gameState.academyPlayers.length}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Confirm Join'),
              onPressed: () {
                // Use the GameStateManager method to handle joining
                bool success = gameState.tryJoinTournament(template);

                Navigator.of(context).pop(); // Close dialog

                if (success) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text('Successfully joined ${template.name}! It will start soon.')),
                   );
                } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text('Failed to join ${template.name}. Requirements might have changed or not enough participants found.')),
                   );
                }
                // No need for setState here, GameStateManager notifies listeners
              },
            ),
          ],
        );
      },
    );
  }
}

// Extension method moved to game_state_manager.dart
// extension TournamentJoining on GameStateManager { ... }
