import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_state_manager.dart';
import '../models/player.dart';
import '../models/staff.dart';

class PlayerAssignmentScreen extends StatelessWidget {
  final Player player;

  const PlayerAssignmentScreen({Key? key, required this.player}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Coach for ${player.name}'),
      ),
      body: Consumer<GameStateManager>(
        builder: (context, gameStateManager, child) {
          // Get available coaches (hired staff with role Coach)
          final coaches = gameStateManager.hiredStaff
              .where((s) => s.role == StaffRole.Coach)
              .toList();

          // Get the coach currently assigned to this player, if any
          final currentCoach = gameStateManager.getCoachForPlayer(player.id);

          if (coaches.isEmpty) {
            return const Center(
              child: Text(
                'No coaches hired.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: coaches.length + 1, // Add 1 for the "Unassign" option
            itemBuilder: (context, index) {
              if (index == coaches.length) {
                // "Unassign" option
                return ListTile(
                  title: const Text('Unassign from Coach'),
                  leading: const Icon(Icons.person_remove_alt_1_outlined),
                  tileColor: currentCoach == null ? Colors.grey[800] : null, // Highlight if unassigned
                  onTap: currentCoach == null ? null : () { // Disable if already unassigned
                    bool success = gameStateManager.unassignPlayerFromCoach(player.id, currentCoach.id);
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                         content: Text(success ? 'Player unassigned.' : 'Failed to unassign.'),
                         backgroundColor: success ? Colors.orangeAccent : Colors.redAccent,
                       ),
                     );
                     if (success && context.mounted) {
                       Navigator.pop(context); // Go back after unassigning
                     }
                  },
                );
              }

              // Coach assignment option
              final coach = coaches[index];
              final bool isCurrentCoach = currentCoach?.id == coach.id;
              final bool canAssign = coach.assignedPlayerIds.length < coach.maxPlayersTrainable;

              return ListTile(
                leading: const Icon(Icons.assignment_ind_outlined),
                title: Text(coach.name),
                subtitle: Text(
                    'Skill: ${coach.skill} | Training: ${coach.assignedPlayerIds.length}/${coach.maxPlayersTrainable}'),
                trailing: isCurrentCoach
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                tileColor: isCurrentCoach ? Colors.green.withOpacity(0.1) : null,
                onTap: isCurrentCoach ? null : (canAssign ? () { // Disable if current coach or coach is full
                  bool success = gameStateManager.assignPlayerToCoach(player.id, coach.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Assigned to ${coach.name}.' : 'Failed to assign (Coach might be full).'),
                      backgroundColor: success ? Colors.lightGreen : Colors.redAccent,
                    ),
                  );
                  if (success && context.mounted) {
                     Navigator.pop(context); // Go back after assigning
                  }
                } : null), // Disable tap if coach is full
                 enabled: canAssign || isCurrentCoach, // Visually disable if full and not current coach
              );
            },
          );
        },
      ),
    );
  }
}
