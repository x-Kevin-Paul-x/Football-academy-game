import 'package:flutter/material.dart';
import '../models/player.dart';

import '../models/staff.dart'; // Import Staff for type hint, though not directly used in card display now

class PlayerCard extends StatelessWidget {
  final Player player;
  final bool showPotential; // Control whether to show potential skill
  final List<Widget> actions; // Buttons like Sign, Reject, Train, etc.
  final VoidCallback? onTap; // Callback for tapping the card

  const PlayerCard({
    Key? key,
    required this.player,
    this.showPotential = false,
    this.actions = const [],
    this.onTap, // Accept the tap callback
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell( // Make the card tappable
        onTap: onTap, // Use the provided callback
        borderRadius: BorderRadius.circular(10.0), // Match card shape for ripple effect
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    player.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis, // Prevent long names from overflowing
                  ),
                ),
                Chip(
                  label: Text(player.positionString),
                  backgroundColor: _getPositionColor(player.position).withOpacity(0.2),
                  labelStyle: TextStyle(color: _getPositionColor(player.position), fontWeight: FontWeight.bold),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap( // Use Wrap for chips to handle potential overflow
              spacing: 8.0, // Horizontal space between chips
              runSpacing: 4.0, // Vertical space between lines of chips
              children: [
                _buildInfoChip(Icons.cake_outlined, 'Age: ${player.age}'),
                _buildInfoChip(Icons.attach_money_outlined, 'Wage: \$${player.weeklyWage}/wk'),
                _buildInfoChip(Icons.star_outline, 'Rep: ${player.reputation}'), // Display Reputation
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSkillIndicator(
                  context,
                  label: 'Current Skill',
                  value: player.currentSkill,
                  color: Colors.blueAccent,
                ),
                if (showPotential)
                  _buildSkillIndicator(
                    context,
                    label: 'Potential Skill',
                    value: player.potentialSkill,
                    color: Colors.lightGreen, // Changed color slightly for better contrast
                  ),
              ],
            ),
            const SizedBox(height: 10), // Add spacing
            // Display Fatigue and Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Fatigue: ${player.fatigue.toStringAsFixed(1)}%', style: Theme.of(context).textTheme.bodyMedium),
                Text('M: ${player.matchesPlayed} | G: ${player.goalsScored} | A: ${player.assists}', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            if (actions.isNotEmpty)
              const Divider(height: 20, thickness: 1),
            if (actions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0), // Add some space above actions
                child: Wrap(
                  alignment: WrapAlignment.end, // Align actions to the end
                  spacing: 8.0, // Space between action buttons
                  children: actions,
                ),
              ),
          ],
        ), // End Column
       ), // End Padding
      ), // End InkWell
    ); // End Card
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.grey[700]),
      label: Text(text),
      backgroundColor: Colors.grey[800], // Darker chip background for dark theme
      labelStyle: TextStyle(color: Colors.grey[300]),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
    );
  }

  Widget _buildSkillIndicator(BuildContext context, {required String label, required int value, required Color color}) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: value / 100.0, // Assuming max skill is 100
                strokeWidth: 5,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Color _getPositionColor(PlayerPosition position) {
    // Using slightly brighter colors for dark theme
    switch (position) {
      case PlayerPosition.Goalkeeper: return Colors.orangeAccent;
      case PlayerPosition.Defender: return Colors.lightBlueAccent;
      case PlayerPosition.Midfielder: return Colors.lightGreenAccent;
      case PlayerPosition.Forward: return Colors.redAccent;
    }
  }
}
