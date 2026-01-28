import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_state_manager.dart';
import '../models/tournament.dart';
import 'TournamentDetailsScreen.dart'; // Import the details screen (updated name)
import 'package:intl/intl.dart'; // For currency formatting

class TournamentHistoryScreen extends StatelessWidget {
  const TournamentHistoryScreen({super.key}); // Use super parameters

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournament History'),
      ),
      body: Consumer<GameStateManager>(
        builder: (context, gameStateManager, child) {
          final List<Tournament> completedTournaments =
              gameStateManager.completedTournaments;

          if (completedTournaments.isEmpty) {
            return const Center(
              child: Text(
                'No tournaments completed yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: completedTournaments.length,
            itemBuilder: (context, index) {
              // Display tournaments in reverse chronological order (newest first)
              final tournament =
                  completedTournaments[completedTournaments.length - 1 - index];
              final currencyFormat =
                  NumberFormat.currency(locale: 'en_US', symbol: '\$');

              String winnerText = 'Winner: Unknown';
              if (tournament.winnerId != null) {
                if (tournament.winnerId == GameStateManager.playerAcademyId) {
                  winnerText = 'Winner: ${gameStateManager.academyName} (You!)';
                } else {
                  winnerText =
                      'Winner: ${gameStateManager.rivalAcademyMap[tournament.winnerId]?.name ?? tournament.winnerId}';
                }
              } else if (tournament.status == TournamentStatus.Cancelled) {
                winnerText = 'Status: Cancelled';
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: Icon(_getTournamentIcon(tournament.type)),
                  title: Text(tournament.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  // Display status, winner, and prize money
                  subtitle: Text(
                      '${tournament.status == TournamentStatus.Cancelled ? 'Cancelled' : winnerText}\nPrize: ${currencyFormat.format(tournament.prizeMoneyBase)}'),
                  isThreeLine:
                      true, // Keep as true if winner text makes it long
                  onTap: () {
                    // Navigate using the tournament ID
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TournamentDetailsScreen(
                          tournamentId: tournament.id, // Pass only the ID
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper function copied from TournamentsScreen (consider moving to a shared utility)
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
}
