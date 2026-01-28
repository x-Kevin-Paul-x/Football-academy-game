import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../game_state_manager.dart'; // Import GameStateManager
import '../models/player.dart';
import '../models/staff.dart'; // Import Staff model
import '../models/player_status.dart'; // Import PlayerStatus enum and helper
import '../widgets/player_card.dart'; // Assuming a PlayerCard widget exists
import 'PlayerAssignmentScreen.dart'; // Import the assignment screen
import 'package:intl/intl.dart'; // For number formatting

class PlayerManagementScreen extends StatelessWidget {
  // REMOVED constructor parameter - data will come from GameStateManager via Consumer
  // final List<Player> academyPlayers;

  const PlayerManagementScreen(
      {Key? key /* required this.academyPlayers REMOVED */})
      : super(key: key);

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
                      Icon(Icons.person_search,
                          size: 80,
                          color: Theme.of(context).colorScheme.outline),
                      const SizedBox(height: 16),
                      Text(
                        'No players in the academy yet.',
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Scout and sign players to build your team!',
                        style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: academyPlayers.length,
                  itemBuilder: (context, index) {
                    final player = academyPlayers[index];
                    // Find the coach assigned to this player (needed for the dialog)
                    final assignedCoach =
                        gameStateManager.getCoachForPlayer(player.id);
                    // Use PlayerCard for consistent display
                    return PlayerCard(
                      player: player,
                      showPotential:
                          true, // Optionally show potential for academy players too
                      actions: [
                        // Add Release Button
                        Tooltip(
                          message: 'Release player from academy',
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.person_remove_outlined),
                            label: const Text('Release'),
                            onPressed: () {
                              // Show confirmation dialog before releasing
                              showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return AlertDialog(
                                    title: Text('Confirm Release'),
                                    content: Text(
                                        'Are you sure you want to release ${player.name} from the academy? This action cannot be undone.'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(dialogContext)
                                              .pop(); // Close the dialog
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Release',
                                            style:
                                                TextStyle(color: Colors.red)),
                                        onPressed: () {
                                          // Use Provider to call the releasePlayer method
                                          Provider.of<GameStateManager>(context,
                                                  listen: false)
                                              .releasePlayer(player);
                                          Navigator.of(dialogContext)
                                              .pop(); // Close the dialog
                                          // Optional: Show confirmation snackbar
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Released ${player.name}.')),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onError,
                            ),
                          ),
                        ),
                        // Add other actions like 'View Details' or 'Train' later
                      ],
                      onTap: () => _showPlayerDetailsDialog(context, player,
                          assignedCoach), // Show details on tap
                    );
                  }, // End itemBuilder
                ); // End ternary operator (false branch)
        },
      ),
    );
  }

  // --- Player Details Dialog ---
  void _showPlayerDetailsDialog(
      BuildContext context, Player player, Staff? coach) {
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    // Access GameStateManager without listening for actions inside the dialog if needed
    // final gameStateManager = Provider.of<GameStateManager>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use Consumer inside the dialog if parts of it need to rebuild based on state changes
        // For now, we pass the data directly.
        return AlertDialog(
          title: Text(player.name),
          content: SingleChildScrollView(
            // Use SingleChildScrollView if content might overflow
            child: ListBody(
              // Use ListBody for column-like layout
              children: <Widget>[
                _buildDetailRow('Position:',
                    player.positionString), // Use positionString getter
                _buildDetailRow('Age:', player.age.toString()),
                // --- CHANGED: Use Progress Bar for Skill ---
                _buildProgressBarRow(context,
                    label: 'Current Skill',
                    value: player.currentSkill.toDouble(),
                    max: 100,
                    valueText:
                        '${player.currentSkill} / ${player.potentialSkill} (Pot)',
                    color: Colors.blueAccent),
                // --- CHANGED: Use Progress Bar for Stamina ---
                _buildProgressBarRow(context,
                    label: 'Stamina',
                    value: player.stamina.toDouble(),
                    max: 20,
                    valueText: '${player.stamina} / 20'),
                // --- CHANGED: Use Progress Bar for Fatigue ---
                _buildProgressBarRow(context,
                    label: 'Fatigue',
                    value: player.fatigue,
                    max: 100,
                    valueText: '${player.fatigue.toStringAsFixed(1)}%',
                    inverseColor: true // High fatigue is bad (Red)
                    ),
                _buildDetailRow('Reputation:', player.reputation.toString()),
                _buildDetailRow(
                    'Weekly Wage:', currencyFormat.format(player.weeklyWage)),
                _buildDetailRow(
                    'Status:', playerStatusToString(player.status)), // New
                _buildDetailRow(
                    'Preferred Format:',
                    player.preferredFormat
                        .toString()
                        .split('.')
                        .last
                        .replaceAll('V', 'v')), // New & formatted
                _buildDetailRow('Coach:', coach?.name ?? 'None'),
                const Divider(height: 20),
                _buildDetailRow(
                    'Matches Played:', player.matchesPlayed.toString()), // New
                _buildDetailRow(
                    'Goals Scored:', player.goalsScored.toString()), // New
                _buildDetailRow('Assists:', player.assists.toString()), // New
                // TODO: Add more stats like average rating, injuries, contract expiry etc. later
              ],
            ),
          ),
          actions: <Widget>[
            // Optional: Add actions like 'View Training', 'Offer Transfer' later
            TextButton(
              child: const Text('Assign Coach'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the details dialog
                // Use root navigator to push on top of the bottom nav bar
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) => PlayerAssignmentScreen(player: player),
                  ),
                );
              },
            ),
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Helper widget for dialog rows
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          // Use Flexible for the value in case it's very long
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end, // Align value to the right
              overflow: TextOverflow.ellipsis, // Handle potential overflow
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for Progress Bar Rows
  Widget _buildProgressBarRow(
    BuildContext context, {
    required String label,
    required double value,
    required double max,
    String? valueText,
    Color? color,
    bool inverseColor = false,
  }) {
    double progress = (value / max).clamp(0.0, 1.0);

    // Determine color
    Color progressColor;
    if (color != null) {
      progressColor = color;
    } else if (inverseColor) {
      // 0 is Good (Green), 1 is Bad (Red)
      // Simple logic: < 50% Green, > 50% Red/Orange
      progressColor =
          progress > 0.5 ? Theme.of(context).colorScheme.error : Colors.green;
    } else {
      // 0 is Bad (Red), 1 is Good (Green)
      progressColor =
          progress < 0.3 ? Theme.of(context).colorScheme.error : Colors.green;
    }

    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 6.0), // Slightly more padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(valueText ?? value.toStringAsFixed(1)),
            ],
          ),
          const SizedBox(height: 4),
          Semantics(
            label: '$label progress bar',
            value: '${(progress * 100).toInt()}%',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
