import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../models/player.dart';
import '../game_state_manager.dart'; // Import GameStateManager
import '../widgets/player_card.dart'; // Assuming a PlayerCard widget exists
import '../widgets/empty_state.dart';

typedef PlayerActionCallback = void Function(Player player);

class ScoutingScreen extends StatelessWidget {
  // final List<Player> scoutedPlayers; // REMOVED
  final PlayerActionCallback signPlayerCallback;
  final PlayerActionCallback rejectPlayerCallback;

  const ScoutingScreen({
    Key? key,
    // required this.scoutedPlayers, // REMOVED
    required this.signPlayerCallback,
    required this.rejectPlayerCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Wrap body with Consumer
      body: Consumer<GameStateManager>(
        builder: (context, gameStateManager, child) {
          final players = gameStateManager.scoutedPlayers; // Get list from provider

          return players.isEmpty
              ? const EmptyState(
                  icon: Icons.search_off,
                  title: 'No new players found this week.',
                  message: 'Hire more scouts or improve existing ones!',
                )
              : ListView.builder( // List view for players
                  padding: const EdgeInsets.all(8.0),
                  itemCount: players.length, // Use list from provider
                  itemBuilder: (context, index) {
                    final player = players[index]; // Use list from provider
                    // Use the PlayerCard widget for consistent display
                    return PlayerCard(
                      player: player,
                  showPotential: true, // Show potential for scouted players
                  actions: [
                    TextButton.icon(
                      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                      label: const Text('Sign', style: TextStyle(color: Colors.green)),
                      onPressed: () => signPlayerCallback(player),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                      label: const Text('Reject', style: TextStyle(color: Colors.red)),
                      onPressed: () => rejectPlayerCallback(player),
                    ),
                  ],
                );
              },
            ); // ListView.builder ends
        }, // Consumer builder ends
      ), // Consumer ends
    ); // Scaffold ends
  }
}
