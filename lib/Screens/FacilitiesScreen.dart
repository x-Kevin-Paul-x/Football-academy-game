import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_state_manager.dart';

class FacilitiesScreen extends StatelessWidget {
  const FacilitiesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academy Facilities'),
      ),
      body: Consumer<GameStateManager>(
        builder: (context, gameStateManager, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildFacilityCard(
                context: context,
                icon: Icons.fitness_center,
                title: 'Training Facility',
                currentLevel: gameStateManager.trainingFacilityLevel,
                description: 'Improves player skill development during training.',
                upgradeCost: gameStateManager.getTrainingFacilityUpgradeCost(),
                canAfford: gameStateManager.balance >= gameStateManager.getTrainingFacilityUpgradeCost(),
                balance: gameStateManager.balance,
                onUpgrade: () {
                  bool success = gameStateManager.upgradeTrainingFacility();
                  if (context.mounted) { // Check if widget is still in the tree
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                         content: Text(success ? 'Training Facility upgraded!' : 'Insufficient funds!'),
                         backgroundColor: success ? Colors.lightGreen : Colors.redAccent,
                       ),
                     );
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildFacilityCard(
                context: context,
                icon: Icons.search,
                title: 'Scouting Network',
                currentLevel: gameStateManager.scoutingFacilityLevel,
                description: 'Increases the quantity and potentially quality of players found by scouts.',
                upgradeCost: gameStateManager.getScoutingFacilityUpgradeCost(),
                canAfford: gameStateManager.balance >= gameStateManager.getScoutingFacilityUpgradeCost(),
                balance: gameStateManager.balance,
                onUpgrade: () {
                   bool success = gameStateManager.upgradeScoutingFacility();
                   if (context.mounted) { // Check if widget is still in the tree
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                         content: Text(success ? 'Scouting Network upgraded!' : 'Insufficient funds!'),
                         backgroundColor: success ? Colors.lightGreen : Colors.redAccent,
                       ),
                     );
                   }
                },
              ),
              const SizedBox(height: 16), // Spacing
              _buildFacilityCard( // <-- ADDED MEDICAL BAY
                context: context,
                icon: Icons.medical_services_outlined, // Medical icon
                title: 'Medical Bay',
                currentLevel: gameStateManager.medicalBayLevel,
                description: 'Reduces player injury recovery time and severity.',
                upgradeCost: gameStateManager.getMedicalBayUpgradeCost(),
                canAfford: gameStateManager.balance >= gameStateManager.getMedicalBayUpgradeCost(),
                balance: gameStateManager.balance,
                onUpgrade: () {
                   bool success = gameStateManager.upgradeMedicalBay();
                   if (context.mounted) { // Check if widget is still in the tree
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                         content: Text(success ? 'Medical Bay upgraded!' : 'Insufficient funds!'),
                         backgroundColor: success ? Colors.lightGreen : Colors.redAccent,
                       ),
                     );
                   }
                },
              ),
              const SizedBox(height: 16), // Spacing for Medical Bay
              _buildFacilityCard(
                context: context,
                icon: Icons.store, // Merchandise icon
                title: 'Merchandise Store',
                currentLevel: gameStateManager.merchandiseStoreLevel,
                description: 'Generates weekly income based on level, fans, and Merchandise Manager skill. Each level increases Store Manager capacity.', // Updated description
                currentEffect: 'Current Max Store Managers: ${gameStateManager.maxStoreManagers}', // <-- ADDED: Current effect
                upgradeCost: gameStateManager.getMerchandiseStoreUpgradeCost(),
                canAfford: gameStateManager.balance >= gameStateManager.getMerchandiseStoreUpgradeCost(),
                balance: gameStateManager.balance,
                onUpgrade: () {
                   bool success = gameStateManager.upgradeMerchandiseStore();
                   if (context.mounted) { // Check if widget is still in the tree
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                         content: Text(success ? 'Merchandise Store upgraded!' : 'Insufficient funds!'),
                         backgroundColor: success ? Colors.lightGreen : Colors.redAccent,
                       ),
                     );
                   }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFacilityCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int currentLevel,
    required String description,
    String? currentEffect, // <-- ADDED: Optional current effect string
    required int upgradeCost, // Pass cost explicitly
    required bool canAfford, // Pass affordability explicitly
    required VoidCallback onUpgrade, // Pass upgrade callback
    required double balance,
  }) {
    String tooltipMessage;
    if (canAfford) {
      tooltipMessage = 'Upgrade for \$${upgradeCost.toStringAsFixed(0)}';
    } else {
      double missing = upgradeCost - balance;
      tooltipMessage =
          'Insufficient funds. Need \$${missing.toStringAsFixed(0)} more.';
    }

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    size: 30, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Chip(
                  label: Text('Level $currentLevel'),
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondaryContainer),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
            if (currentEffect != null &&
                currentEffect.isNotEmpty) ...[ // <-- ADDED: Display current effect if provided
              const SizedBox(height: 8),
              Text(currentEffect,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic, color: Colors.grey[600])),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upgrade to Level ${currentLevel + 1}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Cost: \$${upgradeCost.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: canAfford
                            ? Colors.green[700]
                            : Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
                Tooltip(
                  message: tooltipMessage,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.upgrade),
                    label: const Text('Upgrade'),
                    // Disable button if cannot afford
                    onPressed: canAfford
                        ? () {
                            // Show confirmation dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  title: Text('Confirm Upgrade'),
                                  content: Text(
                                      'Upgrade $title to Level ${currentLevel + 1} for \$${upgradeCost.toStringAsFixed(0)}?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(dialogContext)
                                            .pop(); // Close the dialog
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Upgrade'),
                                      onPressed: () {
                                        Navigator.of(dialogContext)
                                            .pop(); // Close the dialog
                                        onUpgrade(); // Execute the upgrade action passed in
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        : null, // Set onPressed to null to disable
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canAfford
                          ? Colors.green
                          : Colors.grey, // Grey out if disabled
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
