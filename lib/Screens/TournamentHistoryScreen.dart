import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for formatting
import 'package:provider/provider.dart';
import '../game_state_manager.dart';
import '../models/tournament.dart';
import 'TournamentDetailsScreen.dart'; // To potentially reuse details view

class TournamentHistoryScreen extends StatelessWidget {
  const TournamentHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'en_US', symbol: '\$'); // Formatter

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
              String winnerText = 'Winner: N/A';
              if (tournament.winnerId != null) {
                winnerText =
                    'Winner: ${gameStateManager.rivalAcademyMap[tournament.winnerId]?.name ?? (tournament.winnerId == GameStateManager.playerAcademyId ? gameStateManager.academyName : 'Unknown')}';
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: Icon(
                      _getTournamentIcon(tournament.type)), // Reuse icon logic
                  title: Text(tournament.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  // Use tournament.status.toString() and prizeMoneyBase
                  subtitle: Text(
                      'Status: ${tournament.status.toString().split('.').last}\nPrize: ${currencyFormat.format(tournament.prizeMoneyBase)}\n$winnerText'), // Use prizeMoneyBase and add winner
                  isThreeLine: true,
                  onTap: () {
                    // Navigate to TournamentDetailsScreen using only the ID
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
