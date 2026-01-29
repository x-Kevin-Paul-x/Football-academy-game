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
          final players =
              gameStateManager.scoutedPlayers; // Get list from provider

          return players.isEmpty
              ? const EmptyState(
                  icon: Icons.search_off,
                  title: 'No new players found this week.',
                  message: 'Hire more scouts or improve existing ones!',
                )
              : ListView.builder(
                  // List view for players
                  padding: const EdgeInsets.all(8.0),
                  itemCount: players.length, // Use list from provider
                  itemBuilder: (context, index) {
                    final player = players[index]; // Use list from provider
                    // Use the PlayerCard widget for consistent display
                    return PlayerCard(
                      player: player,
                      showPotential: true, // Show potential for scouted players
                      actions: [
                        Tooltip(
                          message: 'Sign player to your academy',
                          child: TextButton.icon(
                            icon: Icon(Icons.check_circle_outline,
                                color: Theme.of(context).colorScheme.primary),
                            label: Text('Sign',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary)),
                            onPressed: () => signPlayerCallback(player),
                          ),
                        ),
                        Tooltip(
                          message: 'Reject this player',
                          child: TextButton.icon(
                            icon: Icon(Icons.cancel_outlined,
                                color: Theme.of(context).colorScheme.error),
                            label: Text('Reject',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.error)),
                            onPressed: () => rejectPlayerCallback(player),
                          ),
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
