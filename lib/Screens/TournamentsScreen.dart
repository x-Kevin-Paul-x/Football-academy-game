import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../game_state_manager.dart';
import '../models/tournament.dart';
import 'TournamentDetailsScreen.dart'; // Import TournamentDetailsScreen

// Enum to define the type of list to display
enum TournamentListType { available, active, history }

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  @override
  Widget build(BuildContext context) {
    // Top-level Consumer removed. Tabs fetch their own data.
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
        body: const TabBarView(
          children: [
            // Lazy loading: These widgets are built when the tab is active/adjacent
            TournamentListTab(type: TournamentListType.available),
            TournamentListTab(type: TournamentListType.active),
            TournamentListTab(type: TournamentListType.history),
          ],
        ),
      ),
    );
  }
}

class TournamentListTab extends StatelessWidget {
  final TournamentListType type;

  const TournamentListTab({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateManager>(
      builder: (context, gameStateManager, child) {
        final currentPlayerCount = gameStateManager.academyPlayers.length;
        const String playerAcademyId = GameStateManager.playerAcademyId;

        // Fetch the appropriate list based on type
        List<Tournament> tournaments;
        bool isTemplates = false;

        switch (type) {
          case TournamentListType.available:
            tournaments = gameStateManager.availableTournamentTemplates;
            isTemplates = true;
            break;
          case TournamentListType.active:
            tournaments = gameStateManager.activeTournaments;
            isTemplates = false;
            break;
          case TournamentListType.history:
            tournaments = gameStateManager.completedTournaments;
            isTemplates = false;
            break;
        }

        if (tournaments.isEmpty) {
          String message = "No tournaments available.";
          if (type == TournamentListType.history) {
            message = "No completed tournaments yet.";
          } else if (type == TournamentListType.active) {
            message = "No active tournaments currently.";
          } else if (type == TournamentListType.available) {
            message = "No new tournament opportunities right now.";
          }
          return Center(child: Text(message));
        }

        final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

        // Copy and Sort
        // This logic now runs only for this specific tab's build
        final List<Tournament> displayTournaments = List<Tournament>.from(tournaments);

        if (type == TournamentListType.active) {
          // Sort active: InProgress first, then Scheduled by date
          displayTournaments.sort((a, b) {
            if (a.status == TournamentStatus.InProgress && b.status != TournamentStatus.InProgress) return -1;
            if (a.status != TournamentStatus.InProgress && b.status == TournamentStatus.InProgress) return 1;
            return a.startDate.compareTo(b.startDate);
          });
        } else if (type == TournamentListType.history) {
          // Sort history: Newest first
          displayTournaments.sort((a, b) => b.startDate.compareTo(a.startDate));
        }
        // Available (templates) - keep default order

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: displayTournaments.length,
          itemBuilder: (context, index) {
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
                    if (!isTemplates)
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
                      tournament,
                      canJoin,
                      alreadyJoined,
                      meetsPlayers,
                      meetsReputation,
                      gameStateManager,
                    )
                  : (tournament.status != TournamentStatus.Scheduled
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
                      : null
                    ),
                onTap: !isTemplates && tournament.status != TournamentStatus.Scheduled
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TournamentDetailsScreen(tournamentId: tournament.id),
                        ),
                      );
                    }
                  : null,
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  IconData _getTournamentIcon(TournamentType type) {
    switch (type) {
      case TournamentType.threeVthree: return Icons.looks_3;
      case TournamentType.fiveVfive: return Icons.looks_5;
      case TournamentType.sevenVseven: return Icons.looks_one;
      case TournamentType.elevenVeleven: return Icons.emoji_events;
      // No default needed if all cases covered, but if TournamentType has more values in future, default helps.
      // However, lint complains about unreachable default if all covered.
      // I'll keep default if I'm not sure if I covered ALL values.
      // I recall values: threeVthree, fiveVfive, sevenVseven, elevenVeleven.
      // So I covered all. I'll remove default.
    }
  }

  Widget _buildEnterButton(
    BuildContext context,
    Tournament tournamentTemplate,
    bool canJoinOverall,
    bool alreadyJoined,
    bool meetsPlayers,
    bool meetsReputation,
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

    if (tooltipMessage != null && !canJoinOverall) {
      return Tooltip(
        message: tooltipMessage,
        child: joinButton,
      );
    }

    return joinButton;
  }

  String _getTeamName(String teamId, GameStateManager gameState) {
    if (teamId == GameStateManager.playerAcademyId) {
      return gameState.academyName;
    }
    return gameState.rivalAcademyMap[teamId]?.name ?? teamId;
  }

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
                bool success = gameState.tryJoinTournament(template);

                Navigator.of(context).pop();

                if (success) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text('Successfully joined ${template.name}! It will start soon.')),
                   );
                } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text('Failed to join ${template.name}. Requirements might have changed or not enough participants found.')),
                   );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
