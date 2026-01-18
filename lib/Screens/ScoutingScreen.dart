import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../models/player.dart';
import '../game_state_manager.dart'; // Import GameStateManager
import '../widgets/player_card.dart'; // Assuming a PlayerCard widget exists

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
              ? Center( // Empty state
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Semantics(
                      label: 'Scouting Report Empty',
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No new players found this week.',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hire more scouts or improve existing ones to find more talent!',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
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
                        Tooltip(
                          message: 'Sign player to your academy',
                          child: TextButton.icon(
                            icon: Icon(Icons.check_circle_outline, color: Theme.of(context).colorScheme.primary),
                            label: Text('Sign', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                            onPressed: () => signPlayerCallback(player),
                          ),
                        ),
                        Tooltip(
                          message: 'Reject this player',
                          child: TextButton.icon(
                            icon: Icon(Icons.cancel_outlined, color: Theme.of(context).colorScheme.error),
                            label: Text('Reject', style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
