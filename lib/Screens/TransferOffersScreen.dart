import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_state_manager.dart';
import 'package:intl/intl.dart'; // For number formatting

class TransferOffersScreen extends StatelessWidget {
  const TransferOffersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format currency
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incoming Transfer Offers'),
      ),
      body: Consumer<GameStateManager>(
        builder: (context, gameStateManager, child) {
          final offers = gameStateManager.transferOffers;

          if (offers.isEmpty) {
            return const Center(
              child: Text(
                'No transfer offers received this week.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              final String playerName = offer['playerName'] ?? 'Unknown Player';
              final String offeringClub = offer['offeringClubName'] ?? 'Unknown Club';
              final int offerAmount = offer['offerAmount'] ?? 0;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playerName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Offer from: $offeringClub',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Offer Amount: ${currencyFormat.format(offerAmount)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.green[700]),
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                            label: const Text('Reject', style: TextStyle(color: Colors.redAccent)),
                            onPressed: () {
                              // Show confirmation dialog before rejecting
                              _showConfirmationDialog(
                                context: context,
                                title: 'Reject Offer',
                                content: 'Are you sure you want to reject the offer for $playerName from $offeringClub?',
                                onConfirm: () {
                                  gameStateManager.rejectTransferOffer(offer);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Rejected offer for $playerName.'), backgroundColor: Colors.orangeAccent),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Accept'),
                            onPressed: () {
                              // Show confirmation dialog before accepting
                               _showConfirmationDialog(
                                context: context,
                                title: 'Accept Offer',
                                content: 'Are you sure you want to accept the offer for $playerName from $offeringClub for ${currencyFormat.format(offerAmount)}?\nThe player will leave the academy immediately.',
                                onConfirm: () {
                                  gameStateManager.acceptTransferOffer(offer);
                                   ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Accepted offer for $playerName! Received ${currencyFormat.format(offerAmount)}.'), backgroundColor: Colors.lightGreen),
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper method for confirmation dialogs
  void _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text(title.split(' ')[0]), // e.g., "Accept" or "Reject"
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                onConfirm(); // Execute the confirmed action
              },
            ),
          ],
        );
      },
    );
  }
}
