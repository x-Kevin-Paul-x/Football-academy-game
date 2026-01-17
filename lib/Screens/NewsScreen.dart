import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../game_state_manager.dart';
import '../models/news_item.dart';
import '../widgets/empty_state.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  // Helper function to get an icon based on news type
  IconData _getIconForNewsType(NewsItemType type) {
     switch (type) {
       case NewsItemType.MatchResult: return Icons.sports_soccer;
       case NewsItemType.Scouting: return Icons.search;
       case NewsItemType.Training: return Icons.fitness_center;
       case NewsItemType.TransferOffer: return Icons.swap_horiz;
       case NewsItemType.TransferDecision: return Icons.gavel;
       case NewsItemType.StaffChange: return Icons.person_add_alt_1; // Or person_remove
       case NewsItemType.Finance: return Icons.attach_money;
       case NewsItemType.Facility: return Icons.business;
       case NewsItemType.PlayerSigned: return Icons.person_pin_circle;
       case NewsItemType.Generic:
       default: return Icons.article;
     }
   }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to get the news items
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Feed'),
      ),
      body: Consumer<GameStateManager>(
        builder: (context, gameStateManager, child) {
          final newsItems = gameStateManager.newsItems; // Get the list

          if (newsItems.isEmpty) {
            return const EmptyState(
              icon: Icons.newspaper,
              title: 'No news yet.',
              message: 'Check back later for match results and updates.',
            );
          }

          // Display news items in a ListView
          return ListView.builder(
            itemCount: newsItems.length,
            itemBuilder: (context, index) {
              final item = newsItems[index];
              final formattedItemDate = DateFormat('MMM d, yyyy').format(item.date);
              // Determine text style based on read status
              final itemTextStyle = item.isRead
                  ? Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey) // Style for read items
                  : Theme.of(context).textTheme.bodyMedium; // Default style for unread

              return ListTile(
                leading: Icon(_getIconForNewsType(item.type), color: item.isRead ? Colors.grey : null),
                title: Text(
                  item.title,
                  style: itemTextStyle?.copyWith(fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold), // Bold if unread
                ),
                subtitle: Text(item.description, style: itemTextStyle),
                trailing: Text(
                  formattedItemDate,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: item.isRead ? Colors.grey : null),
                ),
                dense: true,
                // Optional: Add onTap to mark as read individually?
                // onTap: () {
                //   Provider.of<GameStateManager>(context, listen: false).markNewsAsRead(item.id);
                // },
              );
            },
          );
        },
      ),
    );
  }
}
