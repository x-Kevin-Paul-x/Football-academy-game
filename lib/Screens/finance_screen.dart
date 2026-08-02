import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/staff.dart';
import 'package:intl/intl.dart'; // For currency formatting
import 'package:provider/provider.dart'; // Import Provider
import '../game_state_manager.dart'; // Import GameStateManager

class FinanceScreen extends StatelessWidget {
  // REMOVED constructor parameters - data will come from GameStateManager via Consumer
  // final double balance;
  // final int weeklyIncome;
  // final List<Staff> hiredStaff;
  // final List<Player> academyPlayers;

  const FinanceScreen({
    Key? key,
    // required this.balance, // REMOVED
    // required this.weeklyIncome, // REMOVED
    // required this.hiredStaff, // REMOVED
    // required this.academyPlayers, // REMOVED
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      // Wrap the body with Consumer
      body: Consumer<GameStateManager>(
        builder: (context, gameStateManager, child) {
          // Access data from gameStateManager
          final double balance = gameStateManager.balance;
          final int weeklyIncome = gameStateManager.weeklyIncome;
          final List<Staff> hiredStaff = gameStateManager.hiredStaff;
          final List<Player> academyPlayers = gameStateManager.academyPlayers;
          final int totalWeeklyWages = gameStateManager.totalWeeklyWages; // Use pre-calculated value

          // Calculate derived values
          final int totalStaffWages = hiredStaff.fold(0, (sum, staff) => sum + staff.weeklyWage); // Still useful for breakdown
          final int totalPlayerWages = academyPlayers.fold(0, (sum, player) => sum + player.weeklyWage); // Still useful for breakdown
          final int weeklyNet = weeklyIncome - totalWeeklyWages;

          // Return the ListView within the builder
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Pass data from gameStateManager/calculations
              _buildFinanceSummaryCard(context, currencyFormat, balance, weeklyIncome, weeklyNet, totalWeeklyWages),
              const SizedBox(height: 20),
              _buildWageBreakdownCard(context, currencyFormat, totalStaffWages, totalPlayerWages, totalWeeklyWages),
              const SizedBox(height: 20),
              _buildStaffWagesList(context, currencyFormat, hiredStaff), // Pass hiredStaff
              const SizedBox(height: 20),
              _buildPlayerWagesList(context, currencyFormat, academyPlayers), // Pass academyPlayers
              const SizedBox(height: 20),
              _buildTransferOffersCard(context, currencyFormat, gameStateManager), // Add Transfer Offers section
            ],
          );
        },
      ),
    );
  }

  // Update signature to accept balance and weeklyIncome
  Widget _buildFinanceSummaryCard(BuildContext context, NumberFormat currencyFormat, double balance, int weeklyIncome, int weeklyNet, int totalWeeklyWages) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Overview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1),
            _buildSummaryRow(
              context,
              icon: Icons.account_balance_wallet,
              label: 'Current Balance:',
              value: currencyFormat.format(balance),
              valueColor: balance >= 0 ? Colors.green.shade700 : Colors.red.shade700,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              context,
              icon: Icons.arrow_upward,
              label: 'Est. Weekly Income:',
              value: currencyFormat.format(weeklyIncome),
              valueColor: Colors.blue.shade700,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              context,
              icon: Icons.arrow_downward,
              label: 'Total Weekly Wages:',
              value: currencyFormat.format(totalWeeklyWages),
              valueColor: Colors.orange.shade800,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              context,
              icon: weeklyNet >= 0 ? Icons.trending_up : Icons.trending_down,
              label: 'Est. Weekly Net:',
              value: currencyFormat.format(weeklyNet),
              valueColor: weeklyNet >= 0 ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, {required IconData icon, required String label, required String value, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(label, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
              ),
        ),
      ],
    );
  }

  Widget _buildWageBreakdownCard(BuildContext context, NumberFormat currencyFormat, int staffWages, int playerWages, int totalWages) {
     return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              'Weekly Wage Breakdown',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1),
             _buildSummaryRow(
              context,
              icon: Icons.work_outline,
              label: 'Staff Wages:',
              value: currencyFormat.format(staffWages),
              valueColor: Colors.orange.shade800,
            ),
            const SizedBox(height: 12),
             _buildSummaryRow(
              context,
              icon: Icons.person_outline,
              label: 'Player Wages:',
              value: currencyFormat.format(playerWages),
              valueColor: Colors.orange.shade800,
            ),
             const SizedBox(height: 12),
             _buildSummaryRow(
              context,
              icon: Icons.summarize_outlined,
              label: 'Total Wages:',
              value: currencyFormat.format(totalWages),
              valueColor: Colors.orange.shade800,
            ),
          ],
        ),
      ),
    );
  }

  // Update signature to accept hiredStaff list
  Widget _buildStaffWagesList(BuildContext context, NumberFormat currencyFormat, List<Staff> hiredStaff) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ExpansionTile(
        title: Text('Hired Staff Wages (${hiredStaff.length})', style: Theme.of(context).textTheme.titleLarge),
        leading: const Icon(Icons.work_history_outlined),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: hiredStaff.isEmpty
            ? [const ListTile(title: Text('No staff hired.'))]
            : hiredStaff.map((staff) => ListTile( // Use the passed list
                  title: Text(staff.name),
                  subtitle: Text(staff.role.name),
                  trailing: Text(currencyFormat.format(staff.weeklyWage)),
                )).toList(),
      ),
    );
  }

   // Update signature to accept academyPlayers list
   Widget _buildPlayerWagesList(BuildContext context, NumberFormat currencyFormat, List<Player> academyPlayers) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ExpansionTile(
        title: Text('Academy Player Wages (${academyPlayers.length})', style: Theme.of(context).textTheme.titleLarge),
        leading: const Icon(Icons.sports_soccer),
         childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: academyPlayers.isEmpty
            ? [const ListTile(title: Text('No players signed to the academy.'))]
            : academyPlayers.map((player) => ListTile( // Use the passed list
                  title: Text(player.name),
                  subtitle: Text('${player.positionString}, Age: ${player.age}'),
                  trailing: Text(currencyFormat.format(player.weeklyWage)),
                )).toList(),
      ),
    );
  }

  // --- Transfer Offers Section ---
  Widget _buildTransferOffersCard(BuildContext context, NumberFormat currencyFormat, GameStateManager gameStateManager) {
    final offers = gameStateManager.transferOffers;

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Incoming Transfer Offers (${offers.length})',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1),
            if (offers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: Text('No current transfer offers.')),
              )
            else
              ListView.builder(
                shrinkWrap: true, // Important inside a ListView
                physics: const NeverScrollableScrollPhysics(), // Disable scrolling for the inner list
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  final offer = offers[index];
                  return ListTile(
                    title: Text('Offer for ${offer['playerName']}'),
                    subtitle: Text('From: ${offer['offeringClubName']}\nAmount: ${currencyFormat.format(offer['offerAmount'])}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          tooltip: 'Accept Offer',
                          onPressed: () {
                            // Show confirmation dialog before accepting
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  title: const Text('Confirm Transfer'),
                                  content: Text('Are you sure you want to sell ${offer['playerName']} to ${offer['offeringClubName']} for ${currencyFormat.format(offer['offerAmount'])}?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop(); // Close the dialog
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Accept'),
                                      onPressed: () {
                                        gameStateManager.acceptTransferOffer(offer);
                                        Navigator.of(dialogContext).pop(); // Close the dialog
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Accepted offer for ${offer['playerName']}')),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          tooltip: 'Reject Offer',
                          onPressed: () {
                             gameStateManager.rejectTransferOffer(offer);
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content: Text('Rejected offer for ${offer['playerName']}')),
                             );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
  // --- End Transfer Offers Section ---
}
