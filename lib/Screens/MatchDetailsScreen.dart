import 'package:flutter/material.dart';
import '../models/match.dart';
import '../models/match_event.dart';
import '../models/ai_club.dart'; // To get team names/colors
import '../models/player.dart'; // To potentially get player names from IDs later

class MatchDetailsScreen extends StatelessWidget {
  final Match match;
  final Map<String, AIClub> aiClubMap; // To look up AI club names/colors
  final String playerAcademyId; // To identify player's academy
  // TODO: Pass player map if needed to show player names for events

  const MatchDetailsScreen({
    Key? key,
    required this.match,
    required this.aiClubMap,
    required this.playerAcademyId,
  }) : super(key: key);

  // Helper to get team name
  String _getTeamName(String teamId) {
    if (teamId == playerAcademyId) {
      // TODO: Get actual academy name from GameStateManager or settings
      return "My Academy";
    }
    return aiClubMap[teamId]?.name ?? 'Unknown Club';
  }

  // Helper to get team color (optional)
  Color _getTeamColor(String teamId) {
    if (teamId == playerAcademyId) {
      // TODO: Get actual academy color
      return Colors.blue; // Placeholder
    }
    return aiClubMap[teamId]?.primaryColor ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    String homeTeamName = _getTeamName(match.homeTeamId);
    String awayTeamName = _getTeamName(match.awayTeamId);

    return Scaffold(
      appBar: AppBar(
        title: Text('$homeTeamName vs $awayTeamName'),
        // Display final score in AppBar subtitle
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Final Score: ${match.homeScore} - ${match.awayScore}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.8) ?? Colors.white70,
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: match.eventLog.length,
        itemBuilder: (context, index) {
          final event = match.eventLog[index];
          return _buildEventTile(context, event);
        },
      ),
    );
  }

  Widget _buildEventTile(BuildContext context, MatchEvent event) {
    IconData icon = Icons.info_outline; // Default icon
    Color? iconColor = Theme.of(context).colorScheme.secondary;
    String title = event.description;
    String subtitle = "${event.minute}'";

    switch (event.type) {
      case MatchEventType.KickOff:
        icon = Icons.sports_soccer;
        iconColor = Colors.green;
        break;
      case MatchEventType.Goal:
        icon = Icons.sports_soccer; // Could use a specific goal icon
        iconColor = _getTeamColor(event.teamId); // Color based on scoring team
        // TODO: If playerId is available, look up player name
        break;
      case MatchEventType.HalfTime:
        icon = Icons.timer;
        iconColor = Colors.orange;
        break;
      case MatchEventType.FullTime:
        icon = Icons.timer_off;
        iconColor = Colors.red;
        break;
      // Add cases for other event types (Save, Foul, Card, etc.)
      default:
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 30),
        title: Text(title),
        trailing: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}
