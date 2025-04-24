import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_state_manager.dart';
import '../models/tournament.dart';
import 'TournamentDetailsScreen.dart'; // To potentially reuse details view

class TournamentHistoryScreen extends StatelessWidget {
  const TournamentHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournament History'),
      ),
      body: Consumer<GameStateManager>(
        builder: (context, gameStateManager, child) {
          final List<Tournament> completedTournaments = gameStateManager.completedTournaments;

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
              final tournament = completedTournaments[completedTournaments.length - 1 - index];

              // TODO: Determine how to display completed tournament info.
              // Maybe reuse parts of TournamentDetailsScreen or create a summary card.
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: Icon(_getTournamentIcon(tournament.type)), // Reuse icon logic
                  title: Text(tournament.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  // Use tournament.status.toString() and potentially format it
                  subtitle: Text('Status: ${tournament.status.toString().split('.').last}\nPrize: ${tournament.prize}'),
                  isThreeLine: true,
                  onTap: () {
                    // Navigate to a read-only version of details?
                    // For now, just show a snackbar or reuse existing details screen
                     // Get GameStateManager to access AI Club Map and Player ID
                     final gameStateManager = Provider.of<GameStateManager>(context, listen: false);

                     Navigator.push(
                       context,
                       MaterialPageRoute(
                         builder: (context) => TournamentDetailsScreen(
                           tournament: tournament,
                           matches: tournament.matches,
                           aiClubMap: gameStateManager.aiClubMap, // Pass map from GameStateManager
                           playerAcademyId: 'player_academy_1', // TODO: Get player academy ID from GameStateManager if it becomes dynamic
                         ),
                       ),
                     );
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(content: Text('Viewing details for ${tournament.name}')),
                    // );
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
