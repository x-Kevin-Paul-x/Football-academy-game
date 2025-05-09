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
import 'ScoutingScreen.dart';
import 'TransferOffersScreen.dart';
import 'NewsScreen.dart'; // Import the new NewsScreen

// Import Models
import '../models/player.dart';
import '../models/staff.dart';
// NewsItem model is no longer needed directly here
// import '../models/news_item.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  // final Random _random = Random(); // Removed unused field
  final DateFormat _dateFormatter = DateFormat('MMMM d, yyyy');

  @override
  void initState() {
    super.initState();
    // Initialization logic is handled by GameStateManager
  }

  // --- Callbacks (Simplified - No longer passing state down) ---

  void _hireStaff(Staff staffToHire) {
    Provider.of<GameStateManager>(context, listen: false).hireStaff(staffToHire);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Hired ${staffToHire.name} (${staffToHire.role.name})')),
    );
  }

   void _signPlayer(Player playerToSign) {
     Provider.of<GameStateManager>(context, listen: false).signPlayer(playerToSign);
     ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Signed ${playerToSign.name}')),
    );
  }

   void _rejectPlayer(Player playerToReject) {
     Provider.of<GameStateManager>(context, listen: false).rejectPlayer(playerToReject);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rejected ${playerToReject.name}')),
    );
  }

  // --- UI Building ---

  // Custom Dashboard Home widget - Reverted to simple layout + News Button
  Widget _buildDashboardHome() {
    return Consumer<GameStateManager>(
      builder: (context, gameStateManager, child) {
        final String formattedDate = _dateFormatter.format(gameStateManager.currentDate);
        final int unreadNewsCount = gameStateManager.newsItems.where((item) => !item.isRead).length; // Count unread news

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Academy Dashboard',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  'Current Date: $formattedDate',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  'Balance: \$${gameStateManager.balance.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, color: gameStateManager.balance >= 0 ? Colors.green : Colors.red),
                ),
                const SizedBox(height: 10),
                Text(
                  'Weekly Wages: \$${gameStateManager.totalWeeklyWages}',
                  style: const TextStyle(fontSize: 16, color: Colors.orange),
                ),
                const SizedBox(height: 10),
                Text(
                  'Academy Reputation: ${gameStateManager.academyReputation}',
                  style: const TextStyle(fontSize: 16, color: Colors.blue),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                   onPressed: () {
                     Provider.of<GameStateManager>(context, listen: false).advanceWeek();
                   },
                  icon: const Icon(Icons.fast_forward),
                  label: const Text('Advance 1 Week'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20), // Space before News button
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to the NewsScreen FIRST
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NewsScreen()),
                    ).then((_) {
                      // Mark as read AFTER returning from NewsScreen
                      // This ensures the NewsScreen initially shows unread items correctly.
                      // The badge on the dashboard will update when the dashboard rebuilds.
                      Provider.of<GameStateManager>(context, listen: false).markAllNewsAsRead();
                    });
                  },
                  icon: Badge( // Add badge to the icon
                    label: Text(unreadNewsCount.toString()),
                    isLabelVisible: unreadNewsCount > 0,
                    child: const Icon(Icons.article),
                  ),
                  label: const Text('View News Feed'),
                   style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // _getIconForNewsType is removed from here

  // Lazy initialization of screen data
  // Note: _buildScreenData is now called within build method to ensure context is available if needed later
  List<Map<String, dynamic>> _buildScreenData(BuildContext context) {
    return [
      {'title': 'Dashboard', 'screen': null, 'icon': Icons.home}, // Screen is built directly
      {'title': 'Finance', 'screen': const FinanceScreen(), 'icon': Icons.attach_money},
      {'title': 'Players', 'screen': const PlayerManagementScreen(), 'icon': Icons.people},
      {'title': 'Scouting', 'screen': ScoutingScreen(
          signPlayerCallback: _signPlayer,
          rejectPlayerCallback: _rejectPlayer,
        ), 'icon': Icons.search},
      {'title': 'Staff', 'screen': const StaffManagementScreen(), 'icon': Icons.work},
      {'title': 'Facilities', 'screen': const FacilitiesScreen(), 'icon': Icons.business},
      {'title': 'Transfers', 'screen': const TransferOffersScreen(), 'icon': Icons.swap_horiz},
      {'title': 'Tournaments', 'screen': const TournamentsScreen(), 'icon': Icons.emoji_events},
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
    // Moved _buildScreenData call here
    final List<Map<String, dynamic>> screenDataList = _buildScreenData(context);
    final currentScreenData = screenDataList[_selectedIndex];

    final Brightness brightness = Theme.of(context).brightness;
    final Color appBarBackgroundColor = Theme.of(context).appBarTheme.backgroundColor ?? (brightness == Brightness.dark ? Colors.grey[850]! : Colors.deepPurple);
    final Color appBarForegroundColor = Theme.of(context).appBarTheme.foregroundColor ?? (brightness == Brightness.dark ? Colors.white : Colors.white);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentScreenData['title'] as String),
        centerTitle: true,
        backgroundColor: appBarBackgroundColor,
        foregroundColor: appBarForegroundColor,
      ),
      body: _selectedIndex == 0
          ? _buildDashboardHome() // Build dashboard directly
          : currentScreenData['screen'] as Widget?, // Use screen from list, allowing null
      bottomNavigationBar: Consumer<GameStateManager>(
        builder: (context, gameStateManager, child) {
          // Filter offers to only count those for the player's academy
          final allOffers = gameStateManager.transferOffers;
          final relevantOffersCount = allOffers.where((offer) {
            // Ensure 'sellingClubId' exists and matches the player's academy ID
            return offer['sellingClubId'] == GameStateManager.playerAcademyId;
          }).length;
          // Potentially add unread news count badge to dashboard icon later if desired

          return BottomNavigationBar(
            items: screenDataList.map((data) {
              final String title = data['title'] as String;
              final IconData iconData = data['icon'] as IconData;
              Widget iconWidget = Icon(iconData);

              if (title == 'Transfers' && relevantOffersCount > 0) {
                iconWidget = Badge(
                  label: Text(relevantOffersCount.toString()),
                  child: iconWidget,
                );
              }
              // Example: Add badge for unread news on Dashboard icon
              // if (title == 'Dashboard' && gameStateManager.newsItems.where((n) => !n.isRead).isNotEmpty) {
              //   iconWidget = Badge(
              //     // label: Text(gameStateManager.newsItems.where((n) => !n.isRead).length.toString()), // Optional label
              //     child: iconWidget,
              //   );
              // }

              return BottomNavigationBarItem(
                icon: iconWidget,
                label: title,
              );
            }).toList(),
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.deepPurple,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
          );
        },
      ),
    );
  }
}
