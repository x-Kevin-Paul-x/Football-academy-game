import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_state_manager.dart';

class FacilitiesScreen extends StatelessWidget {
  const FacilitiesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Added Scaffold for better structure
      // appBar: AppBar( // Optional AppBar
      //   title: const Text('Facilities'),
      //   automaticallyImplyLeading: false,
      // ),
      body: Consumer<GameStateManager>(
        builder: (context, gameStateManager, child) {
          int currentLevel = gameStateManager.trainingFacilityLevel;
          // TODO: Define upgrade costs and logic
          int nextLevel = currentLevel + 1;
          double upgradeCost = 10000 * pow(2, currentLevel - 1).toDouble(); // Example exponential cost
          bool canAfford = gameStateManager.balance >= upgradeCost;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView( // Use ListView for potential future additions
              children: [
                _buildFacilityCard(
                  context: context,
                  icon: Icons.fitness_center,
                  title: 'Training Facility',
                  level: currentLevel,
                  description: 'Improves player skill development rate during weekly training.',
                  upgradeCost: upgradeCost,
                  canAfford: canAfford,
                  onUpgrade: () {
                    // TODO: Implement upgrade logic in GameStateManager
                    // - Check affordability
                    // - Deduct cost
                    // - Increment _trainingFacilityLevel
                    // - notifyListeners()
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Upgrade functionality not yet implemented. Cost: \$${upgradeCost.toStringAsFixed(0)}')),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildFacilityCard(
                  context: context,
                  icon: Icons.visibility,
                  title: 'Scouting Network',
                  level: 1, // Placeholder
                  description: 'Increases the quality and quantity of scouted players.',
                  upgradeCost: 5000, // Placeholder
                  canAfford: false, // Placeholder
                  onUpgrade: () {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Upgrade functionality not yet implemented.')),
                    );
                  },
                  isPlaceholder: true, // Mark as placeholder
                ),
                 const SizedBox(height: 16),
                _buildFacilityCard(
                  context: context,
                  icon: Icons.healing,
                  title: 'Medical Center',
                  level: 1, // Placeholder
                  description: 'Reduces player injury duration and occurrence.',
                   upgradeCost: 7500, // Placeholder
                  canAfford: false, // Placeholder
                  onUpgrade: () {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Upgrade functionality not yet implemented.')),
                    );
                  },
                  isPlaceholder: true, // Mark as placeholder
                ),
                // Add more facility types here...
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFacilityCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int level,
    required String description,
    required double upgradeCost,
    required bool canAfford,
    required VoidCallback onUpgrade,
    bool isPlaceholder = false, // Flag for placeholder facilities
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Chip(
                  label: Text('Level $level'),
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            if (!isPlaceholder) ...[ // Only show upgrade button for non-placeholders for now
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upgrade Cost: \$${upgradeCost.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: canAfford ? Colors.green : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: canAfford ? onUpgrade : null, // Disable if cannot afford
                    icon: const Icon(Icons.upgrade),
                    label: const Text('Upgrade'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canAfford ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ] else ... [
               Text('(More details coming soon)', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
            ]
          ],
        ),
      ),
    );
  }

  // Need to import 'dart:math' for pow()
  num pow(num x, num exponent) {
    num result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= x;
    }
    return result;
  }
}
