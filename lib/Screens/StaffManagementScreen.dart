import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../game_state_manager.dart'; // Import GameStateManager
import '../models/staff.dart';
import '../models/player.dart'; // Import Player model
import '../widgets/staff_card.dart'; // Assuming a StaffCard widget exists
import '../widgets/empty_state.dart';

// REMOVED typedef HireStaffCallback = void Function(Staff staff);

class StaffManagementScreen extends StatelessWidget {
  // REMOVED constructor parameters - data will come from GameStateManager via Consumer
  // final List<Staff> hiredStaff;
  // final List<Staff> availableStaff;
  // final HireStaffCallback hireStaffCallback;

  const StaffManagementScreen({
    Key? key,
    // required this.hiredStaff, // REMOVED
    // required this.availableStaff, // REMOVED
    // required this.hireStaffCallback, // REMOVED
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Hired and Available
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Staff Management'), // Restore AppBar title
          bottom: const TabBar( // Move TabBar to appBar.bottom
            tabs: [
              Tab(text: 'Hired Staff'),
              Tab(text: 'Available for Hire'),
            ],
          ),
        ),
        body: Consumer<GameStateManager>(
          builder: (context, gameStateManager, child) {
            final List<Staff> hiredStaff = gameStateManager.hiredStaff;
            final List<Staff> availableStaff = gameStateManager.availableStaff;

            return Column( // Wrap with Column
              children: [
                _buildStaffCapsSummary(context, gameStateManager), // Add the summary here
                const Divider(),
                Expanded( // TabBarView needs to be Expanded within a Column
                  child: TabBarView(
                    children: [
                      _buildStaffList(context, hiredStaff, isHiredList: true),
                      _buildStaffList(context, availableStaff, isHiredList: false),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStaffCapsSummary(BuildContext context, GameStateManager gameState) {
    TextStyle capStyle = Theme.of(context).textTheme.bodyMedium!;
    TextStyle countStyle(int current, int max) => capStyle.copyWith(
      color: current >= max ? Colors.redAccent : (current > 0 ? Colors.green : null),
      fontWeight: current > 0 ? FontWeight.bold : null,
    );

    int hiredManagers = gameState.hiredStaff.where((s) => s.role == StaffRole.Manager).length;
    int hiredCoaches = gameState.hiredStaff.where((s) => s.role == StaffRole.Coach).length;
    int hiredScouts = gameState.hiredStaff.where((s) => s.role == StaffRole.Scout).length;
    int hiredPhysios = gameState.hiredStaff.where((s) => s.role == StaffRole.Physio).length;
    int hiredMerchManagers = gameState.hiredStaff.where((s) => s.role == StaffRole.MerchandiseManager).length;
    int totalMerchCap = gameState.maxStoreManagers + gameState.maxMatchSalesManagers;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Wrap(
        spacing: 16.0,
        runSpacing: 8.0,
        alignment: WrapAlignment.center,
        children: [
          Text('Managers: ', style: capStyle),
          Text('$hiredManagers/1', style: countStyle(hiredManagers, 1)),
          Text('Coaches: ', style: capStyle),
          Text('$hiredCoaches/${gameState.maxCoaches}', style: countStyle(hiredCoaches, gameState.maxCoaches)),
          Text('Scouts: ', style: capStyle),
          Text('$hiredScouts/${gameState.maxScouts}', style: countStyle(hiredScouts, gameState.maxScouts)),
          Text('Physios: ', style: capStyle),
          Text('$hiredPhysios/${gameState.maxPhysios}', style: countStyle(hiredPhysios, gameState.maxPhysios)),
          Text('Merch Mgrs: ', style: capStyle),
          Tooltip(
            message: 'Store Mgrs: ${gameState.maxStoreManagers}\nMatch Sales Mgrs: ${gameState.maxMatchSalesManagers}',
            child: Text('$hiredMerchManagers/$totalMerchCap', style: countStyle(hiredMerchManagers, totalMerchCap)),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffList(BuildContext context, List<Staff> staffList, {required bool isHiredList}) {
    if (staffList.isEmpty) {
      return EmptyState(
        icon: isHiredList ? Icons.group_off : Icons.no_accounts,
        title: isHiredList ? 'No staff hired yet.' : 'No staff available.',
        message: isHiredList
            ? 'Hire managers, coaches, and scouts to improve your academy.'
            : 'Check back later for new applicants.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: staffList.length,
      itemBuilder: (context, index) {
        final staff = staffList[index];
        return StaffCard(
          staff: staff,
          actions: isHiredList
              ? _buildHiredStaffActions(context, staff) // Use helper method
              : [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Hire'),
                    // Call GameStateManager directly to hire staff
                    onPressed: () {
                      Provider.of<GameStateManager>(context, listen: false).hireStaff(staff);
                      // Optional: Show a snackbar confirmation here as well, though Dashboard also shows one.
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(content: Text('Hired ${staff.name}')),
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
        );
      },
    );
  }

  // Helper method to build actions for hired staff cards
  List<Widget> _buildHiredStaffActions(BuildContext context, Staff staff) {
    List<Widget> actions = [];

    // Add 'Manage Assignments' button for coaches
    if (staff.role == StaffRole.Coach) {
      actions.add(
        ElevatedButton.icon(
          icon: const Icon(Icons.assignment_ind),
          label: const Text('Assign Players'),
          onPressed: () => _showAssignPlayersDialog(context, staff),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    // Add 'Fire' button
    actions.add(
      ElevatedButton.icon(
        icon: const Icon(Icons.remove_circle_outline),
        label: const Text('Fire'),
        onPressed: () {
          // Show confirmation dialog before firing
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: Text('Confirm Firing'),
                content: Text('Are you sure you want to fire ${staff.name}?'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // Close the dialog
                    },
                  ),
                  TextButton(
                    child: const Text('Fire', style: TextStyle(color: Colors.red)),
                    onPressed: () {
                      // Use Provider to call the fireStaff method
                      Provider.of<GameStateManager>(context, listen: false).fireStaff(staff);
                      Navigator.of(dialogContext).pop(); // Close the dialog
                      // Optional: Show confirmation snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Fired ${staff.name}.')),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[700], // Darker red
          foregroundColor: Colors.white,
        ),
      ),
    );

    return actions;
  }

  // Method stub to show the player assignment dialog
  void _showAssignPlayersDialog(BuildContext context, Staff coach) {
    // Ensure coach is actually a coach (redundant check, but safe)
    if (coach.role != StaffRole.Coach) return;

    // TODO: Implement the actual dialog content using GameStateManager
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { // Use a different context name
        // Use Consumer inside the dialog to access GameStateManager
        return Consumer<GameStateManager>(
          builder: (context, gameStateManager, child) {
            // Get players and coach details from gameStateManager
            final List<Player> academyPlayers = gameStateManager.academyPlayers;
            // Need to get the latest coach object from state in case assignments changed
            Staff currentCoachState;
            try {
              currentCoachState = gameStateManager.hiredStaff.firstWhere((s) => s.id == coach.id);
            } catch (e) {
              // Coach might have been fired while dialog was opening? Close dialog.
              Navigator.of(dialogContext).pop();
              return const SizedBox.shrink(); // Return empty widget while closing
            }
            final List<String> assignedIds = currentCoachState.assignedPlayerIds;
            final int maxCapacity = currentCoachState.maxPlayersTrainable;


            // Filter players: assigned to this coach, assigned to others, unassigned
            final List<Player> assignedToThisCoach = academyPlayers.where((p) => assignedIds.contains(p.id)).toList();
            final List<Player> unassignedPlayers = academyPlayers.where((p) {
              final currentCoach = gameStateManager.getCoachForPlayer(p.id);
              return currentCoach == null;
            }).toList();

            // Sort for consistent display
            assignedToThisCoach.sort((a, b) => a.name.compareTo(b.name));
            unassignedPlayers.sort((a, b) => a.name.compareTo(b.name));

            return AlertDialog(
              title: Text('Assign Players to ${currentCoachState.name} (${assignedIds.length}/$maxCapacity)'),
              content: SizedBox( // Use SizedBox to constrain dialog size
                width: double.maxFinite, // Use available width
                child: SingleChildScrollView( // Make content scrollable
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Take minimum vertical space
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (assignedToThisCoach.isNotEmpty) ...[
                        const Text('Currently Assigned:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...assignedToThisCoach.map((player) => ListTile(
                          title: Text(player.name),
                          subtitle: Text('Skill: ${player.currentSkill}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            tooltip: 'Unassign',
                            onPressed: () {
                              // Call GameStateManager to unassign
                              gameStateManager.unassignPlayerFromCoach(player.id, currentCoachState.id);
                              // Dialog will rebuild via Consumer
                            },
                          ),
                        )),
                        const Divider(),
                      ],
                      const Text('Available to Assign:', style: TextStyle(fontWeight: FontWeight.bold)),
                      if (unassignedPlayers.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('No unassigned players available.'),
                        )
                      else
                        ...unassignedPlayers.map((player) => ListTile(
                          title: Text(player.name),
                          subtitle: Text('Skill: ${player.currentSkill}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle, color: Colors.green),
                            tooltip: 'Assign',
                            // Disable button if coach is full
                            onPressed: assignedIds.length >= maxCapacity ? null : () {
                              // Call GameStateManager to assign
                              bool success = gameStateManager.assignPlayerToCoach(player.id, currentCoachState.id);
                              if (!success && context.mounted) {
                                // Show error if assignment failed (e.g., coach became full)
                                // Use the outer context for ScaffoldMessenger
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Could not assign ${player.name}. Coach might be full.'), backgroundColor: Colors.red),
                                );
                              }
                              // Dialog will rebuild via Consumer
                            },
                          ),
                        )),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Use dialogContext
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }
}
