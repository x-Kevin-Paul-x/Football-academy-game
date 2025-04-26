import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'dart:math'; // Import for random generation
import 'package:provider/provider.dart'; // Import Provider
import '../game_state_manager.dart'; // Import GameStateManager

// Import Screens
import 'FinanceScreen.dart';
import 'PlayerManagementScreen.dart';
import 'StaffManagementScreen.dart';
import 'FacilitiesScreen.dart';
import 'TournamentsScreen.dart';
import 'SettingsScreen.dart';
import 'ScoutingScreen.dart'; // Import the new Scouting Screen
import 'TransferOffersScreen.dart'; // Import Transfer Offers Screen

// Import Models
import '../models/player.dart';
import '../models/staff.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  final Random _random = Random(); // Random number generator

  // Game State Variables - Date is now managed by GameStateManager
  // DateTime _currentGameDate = DateTime(2025, 1, 1); // <<< REMOVED
  final DateFormat _dateFormatter = DateFormat('MMMM d, yyyy'); // Keep formatter

  // --- REMOVED Local State Variables ---
  // Player/Staff/Finance state is now managed by GameStateManager
  // List<Player> _academyPlayers = [];
  // List<Staff> _hiredStaff = [];
  // List<Player> _scoutedPlayers = []; // ScoutingScreen uses Consumer directly
  // List<Staff> _availableStaff = [];
  // double _balance = 50000.0;
  // int _weeklyIncome = 1000; // TODO: Make this part of GameStateManager too? Or keep as config?
  // int _totalWeeklyWages = 0;
  // ---

  @override
  void initState() {
    super.initState();
    // Initialization logic (like generating staff) is now handled within GameStateManager constructor
    // _generateInitialAvailableStaff();
    // _calculateWeeklyWages();
  }

  // --- REMOVED Local State Methods ---
  // void _generateInitialAvailableStaff() { ... }
  // void _calculateWeeklyWages() { ... }
  // ---

  // Advance time by one week: process finances, scouting, etc.
  // void _advanceTimeByOneWeek() { ... } // <<< REMOVED - Logic moved to GameStateManager

  // --- State Modification Callbacks ---
  // TODO: These callbacks should interact with GameStateManager or services

  // Hire a staff member - Now calls GameStateManager
  void _hireStaff(Staff staffToHire) {
    // Call the correct method in GameStateManager
    Provider.of<GameStateManager>(context, listen: false).hireStaff(staffToHire);

    // Local state updates are no longer needed here
    // setState(() { ... });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Hired ${staffToHire.name} (${staffToHire.roleString})')), // Keep feedback
    );
  }

   // Sign a scouted player
   void _signPlayer(Player playerToSign) {
     // Call the correct method in GameStateManager
     Provider.of<GameStateManager>(context, listen: false).signPlayer(playerToSign);

     // Local state updates are no longer needed here, GameStateManager handles it
     // setState(() {
     //   playerToSign.isScouted = false; // No longer just a scouted prospect
     //   _academyPlayers.add(playerToSign);
     //   _calculateWeeklyWages(); // Update wages immediately
     // });

     // Show feedback (could also be triggered by listening to GameStateManager changes)
     ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Signed ${playerToSign.name}')),
    );
  }

   // Reject a scouted player
   void _rejectPlayer(Player playerToReject) {
     // Call the correct method in GameStateManager
     Provider.of<GameStateManager>(context, listen: false).rejectPlayer(playerToReject);

     // No local state update needed here anymore
     // setState(() {
      // _scoutedPlayers.removeWhere((p) => p.id == playerToReject.id); // REMOVED
    // });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rejected ${playerToReject.name}')),
    );
  }

  // --- UI Building ---

  // Custom Dashboard Home widget
  Widget _buildDashboardHome() {
    // Use Consumer to listen to GameStateManager for date changes
    return Consumer<GameStateManager>(
      builder: (context, gameStateManager, child) { // Builder starts
        // Get the current date from the manager
        final String formattedDate = _dateFormatter.format(gameStateManager.currentDate);

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Academy Dashboard',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Current Date: $formattedDate', // Display date from GameStateManager
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              // Display balance/wages directly from GameStateManager
              Text(
                'Balance: \$${gameStateManager.balance.toStringAsFixed(2)}', // Use gameStateManager.balance
                style: TextStyle(fontSize: 18, color: gameStateManager.balance >= 0 ? Colors.green : Colors.red),
              ),
              const SizedBox(height: 10),
              Text(
                'Weekly Wages: \$${gameStateManager.totalWeeklyWages}', // Use gameStateManager.totalWeeklyWages
                style: const TextStyle(fontSize: 16, color: Colors.orange),
              ),
              const SizedBox(height: 10), // Add some space
              // Display Academy Reputation
              Text(
                'Academy Reputation: ${gameStateManager.academyReputation}',
                style: const TextStyle(fontSize: 16, color: Colors.blue), // Example style
              ),
              const SizedBox(height: 30), // Adjust spacing before button
              ElevatedButton.icon(
                // Call GameStateManager's advanceWeek method
                 onPressed: () {
                    // Access GameStateManager without listening (for actions)
                    // advanceWeek now uses internal state, no argument needed
                   Provider.of<GameStateManager>(context, listen: false).advanceWeek();
                   // TODO: Update scouting/finance based on GameStateManager results if needed
                   // Finance and scouting are now handled within advanceWeek
                 },
                icon: const Icon(Icons.fast_forward), // Changed Icon
                label: const Text('Advance 1 Week'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ], // children list ends
          ), // Center ends
        ); // Builder return ends
      }, // Builder ends
    ); // Consumer ends
  }

  // Lazy initialization of screen data to pass state down
  late final List<Map<String, dynamic>> _screenData = _buildScreenData();

  List<Map<String, dynamic>> _buildScreenData() {
    // TODO: Remove state passing to child screens - they should use Consumer
    return [
      {'title': 'Dashboard', 'screen': _buildDashboardHome(), 'icon': Icons.home},
      // FinanceScreen needs refactoring to use Consumer
      {'title': 'Finance', 'screen': const FinanceScreen(
        // balance: _balance, // REMOVED
        // weeklyIncome: _weeklyIncome, // REMOVED (or get from GSM if moved there)
        // hiredStaff: _hiredStaff, // REMOVED
        // academyPlayers: _academyPlayers, // REMOVED
      ), 'icon': Icons.attach_money},
      // PlayerManagementScreen needs refactoring to use Consumer
      {'title': 'Players', 'screen': const PlayerManagementScreen(
        // academyPlayers: _academyPlayers // REMOVED
        ), 'icon': Icons.people},
      // ScoutingScreen already uses Consumer for players, just pass callbacks
      {'title': 'Scouting', 'screen': ScoutingScreen(
        signPlayerCallback: _signPlayer, // Keep callbacks
        rejectPlayerCallback: _rejectPlayer, // Keep callbacks
      ), 'icon': Icons.search},
      // StaffManagementScreen now uses Consumer and calls GameStateManager directly
      {'title': 'Staff', 'screen': const StaffManagementScreen(
        // hiredStaff: _hiredStaff, // REMOVED
        // availableStaff: _availableStaff, // REMOVED
        // hireStaffCallback: _hireStaff, // REMOVED
      ), 'icon': Icons.work},
      {'title': 'Facilities', 'screen': const FacilitiesScreen(), 'icon': Icons.business},
      // Add Transfer Offers Screen
      {'title': 'Transfers', 'screen': const TransferOffersScreen(), 'icon': Icons.swap_horiz},
      // TournamentsScreen already uses Consumer
      {'title': 'Tournaments', 'screen': const TournamentsScreen(/* academyPlayerCount: _academyPlayers.length REMOVED */), 'icon': Icons.emoji_events},
      {'title': 'Settings', 'screen': const SettingsScreen(), 'icon': Icons.settings},
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color appBarBackgroundColor = Theme.of(context).appBarTheme.backgroundColor ?? (brightness == Brightness.dark ? Colors.grey[850]! : Colors.deepPurple);
    final Color appBarForegroundColor = Theme.of(context).appBarTheme.foregroundColor ?? (brightness == Brightness.dark ? Colors.white : Colors.white);

    // Get the current screen data based on the selected index
    final currentScreenData = _buildScreenData()[_selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentScreenData['title'] as String),
        centerTitle: true,
        backgroundColor: appBarBackgroundColor,
        foregroundColor: appBarForegroundColor,
      ),
      // Display the selected screen's widget
      // Special handling for Dashboard Home to ensure it rebuilds with latest data
      body: _selectedIndex == 0 ? _buildDashboardHome() : currentScreenData['screen'] as Widget,
      // Use Consumer here to access GameStateManager for the badge count
      bottomNavigationBar: Consumer<GameStateManager>(
        builder: (context, gameStateManager, child) {
          final screenDataList = _buildScreenData(); // Get screen data
          final transferOffersCount = gameStateManager.transferOffers.length;

          return BottomNavigationBar(
            items: screenDataList.map((data) {
              final String title = data['title'] as String;
              final IconData iconData = data['icon'] as IconData;
              Widget iconWidget = Icon(iconData); // Default icon

              // Add badge specifically for the 'Transfers' item
              if (title == 'Transfers' && transferOffersCount > 0) {
                iconWidget = Badge(
                  label: Text(transferOffersCount.toString()),
                  child: iconWidget,
                );
              }

              return BottomNavigationBarItem(
                icon: iconWidget, // Use the potentially badged icon
                label: title,
              );
            }).toList(), // Dynamically create items
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.deepPurple, // Or use Theme.of(context).colorScheme.primary
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed, // Ensure all labels are visible
            showUnselectedLabels: true, // Show labels for unselected items
          ); // End of BottomNavigationBar
        }, // End of Consumer builder
      ), // End of Consumer
    ); // End of Scaffold
  }
}
