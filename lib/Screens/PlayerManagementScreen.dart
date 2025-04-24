import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../game_state_manager.dart'; // Import GameStateManager
import '../models/player.dart';
import '../widgets/player_card.dart'; // Assuming a PlayerCard widget exists

class PlayerManagementScreen extends StatelessWidget {
  // REMOVED constructor parameter - data will come from GameStateManager via Consumer
  // final List<Player> academyPlayers;

  const PlayerManagementScreen({Key? key /* required this.academyPlayers REMOVED */}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Wrap the body with Consumer
      body: Consumer<GameStateManager>(
        builder: (context, gameStateManager, child) {
          // Access academyPlayers from gameStateManager
          final List<Player> academyPlayers = gameStateManager.academyPlayers;

          // Return the conditional UI based on academyPlayers
          return academyPlayers.isEmpty
              ? Center(
                  child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No players in the academy yet.',
                     style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                   const SizedBox(height: 8),
                   Text(
                    'Scout and sign players to build your team!',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: academyPlayers.length,
              itemBuilder: (context, index) {
                final player = academyPlayers[index];
                // Use PlayerCard for consistent display
                return PlayerCard(
                  player: player,
                  showPotential: true, // Optionally show potential for academy players too
                  // Add actions for academy players later (e.g., Train, Sell, Release)
                  actions: [],
                );
              }, // End itemBuilder
          ); // End ternary operator (false branch)
        },
      ),
    );
  }
}
