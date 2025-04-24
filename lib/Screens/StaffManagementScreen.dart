import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../game_state_manager.dart'; // Import GameStateManager
import '../models/staff.dart';
import '../widgets/staff_card.dart'; // Assuming a StaffCard widget exists

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
          flexibleSpace: const Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TabBar(
                tabs: [
                  Tab(text: 'Hired Staff'),
                  Tab(text: 'Available for Hire'),
                ],
              )
            ],
          ),
          // Remove the default AppBar title to avoid overlap
          title: const Text(''), 
          // Ensure the AppBar doesn't take extra height if not needed
          toolbarHeight: 48, // Adjust as needed for TabBar height
        ),
        // Wrap TabBarView with Consumer
        body: Consumer<GameStateManager>(
          builder: (context, gameStateManager, child) {
            // Access staff lists from gameStateManager
            final List<Staff> hiredStaff = gameStateManager.hiredStaff;
            final List<Staff> availableStaff = gameStateManager.availableStaff;

            // Return the TabBarView within the builder
            return TabBarView(
              children: [
                // Pass lists from gameStateManager
                _buildStaffList(context, hiredStaff, isHiredList: true),
                _buildStaffList(context, availableStaff, isHiredList: false),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStaffList(BuildContext context, List<Staff> staffList, {required bool isHiredList}) {
    if (staffList.isEmpty) {
      return Center(
        child: Text(
          isHiredList ? 'No staff hired yet.' : 'No staff currently available for hire.',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
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
              ? [/* Add actions for hired staff later, e.g., Fire */]
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
}
