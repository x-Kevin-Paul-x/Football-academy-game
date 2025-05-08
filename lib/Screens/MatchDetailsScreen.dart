import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_state_manager.dart';
import '../models/ai_club.dart'; // <-- ADD: Import AIClub
import '../models/match.dart' hide GameStateManager; // Hide dummy GameStateManager
// import '../models/tournament.dart'; // Removed unused import (Analyzer warning)
import '../models/player.dart';
import '../models/rival_academy.dart'; // Import RivalAcademy
import '../models/match_event.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:collection/collection.dart'; // For firstWhereOrNull

class MatchDetailsScreen extends StatelessWidget {
  final String tournamentId;
  final String matchId;

  const MatchDetailsScreen({
    super.key,
    required this.tournamentId,
    required this.matchId,
  });

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateManager>(context);
    // Find the tournament
     final tournament = gameState.activeTournaments.firstWhereOrNull((t) => t.id == tournamentId) ??
                       gameState.completedTournaments.firstWhereOrNull((t) => t.id == tournamentId);
    // Find the match within the tournament
    final match = tournament?.matches.firstWhereOrNull((m) => m.id == matchId);

    if (tournament == null || match == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Match or Tournament not found.')),
      );
    }

    String homeTeamName = _getTeamName(match.homeTeamId, gameState);
    String awayTeamName = _getTeamName(match.awayTeamId, gameState);

    return Scaffold(
      appBar: AppBar(
        title: Text('$homeTeamName vs $awayTeamName'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMatchInfo(context, match, homeTeamName, awayTeamName),
            const SizedBox(height: 20),
            Text('Events:', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            _buildEventLog(context, match, gameState),
            const SizedBox(height: 20),
            Text('Lineups:', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            _buildLineups(context, match, gameState, homeTeamName, awayTeamName),
          ],
        ),
      ),
    );
  }

  String _getTeamName(String teamId, GameStateManager gameState) {
    if (teamId == GameStateManager.playerAcademyId) {
      return gameState.academyName;
    }
    String? name = gameState.rivalAcademyMap[teamId]?.name;
    if (name != null) return name;

    name = gameState.aiClubMap[teamId]?.name;
    if (name != null) return name;

    return teamId; // Fallback to ID if not found anywhere
  }

  Widget _buildMatchInfo(BuildContext context, Match match, String homeTeamName, String awayTeamName) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${match.isSimulated ? "Final Score" : "Scheduled"}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                match.isSimulated
                    ? '$homeTeamName ${match.homeScore} - ${match.awayScore} $awayTeamName'
                    : '$homeTeamName vs $awayTeamName',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text('Date: ${DateFormat.yMd().add_jm().format(match.matchDate)}'),
            Text('Round: ${match.round}'),
            if (match.isSimulated)
              Text('Result: ${match.result?.name ?? 'N/A'}'),
            if (!match.isSimulated)
              const Text('Status: Pending Simulation'),
          ],
        ),
      ),
    );
  }

  Widget _buildEventLog(BuildContext context, Match match, GameStateManager gameState) {
    if (!match.isSimulated || match.eventLog.isEmpty) {
      return const Text('No events recorded yet.');
    }

    // Sort events by minute
    final sortedEvents = List<MatchEvent>.from(match.eventLog)..sort((a, b) => a.minute.compareTo(b.minute));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedEvents.length,
      itemBuilder: (context, index) {
        final event = sortedEvents[index];
        String playerName = 'Unknown Player';
        String teamName = _getTeamName(event.teamId, gameState); // Get team name for context

        // Find player name (check player academy, rivals, then AI clubs)
        Player? player = gameState.academyPlayers.firstWhereOrNull((p) => p.id == event.playerId);
        if (player == null) {
          RivalAcademy? rivalAcademy = gameState.rivalAcademyMap[event.teamId];
          player = rivalAcademy?.players.firstWhereOrNull((p) => p.id == event.playerId);
        }
        if (player == null) { // --- ADDED: Check AI Clubs ---
          AIClub? aiClub = gameState.aiClubMap[event.teamId];
          player = aiClub?.players.firstWhereOrNull((p) => p.id == event.playerId);
        } // --- END ADDED ---
        playerName = player?.name ?? (event.playerId ?? 'Unknown Player'); // Use player ID if name not found

        IconData icon = Icons.info_outline; // Default icon
        Color iconColor = Colors.grey;
        String description = event.description; // Use the description from the event by default

        switch (event.type) {
          case MatchEventType.Goal:
            icon = Icons.sports_soccer;
            iconColor = Colors.green;
            description = 'Goal! ($teamName)'; // Add team context
            break;
          case MatchEventType.Assist:
            icon = Icons.assistant;
            iconColor = Colors.blue;
             description = 'Assist ($teamName)';
            break;
          case MatchEventType.YellowCard:
            icon = Icons.style; // Represents a card
            iconColor = Colors.yellow.shade700;
             description = 'Yellow Card ($teamName)';
            break;
          case MatchEventType.RedCard:
            icon = Icons.style;
            iconColor = Colors.red;
             description = 'Red Card ($teamName)';
            break;
          case MatchEventType.Substitution:
            icon = Icons.swap_horiz;
            iconColor = Colors.orange;
             description = 'Substitution ($teamName)'; // Description might need more detail from event data
            break;
          // --- Cases for event types NOT currently defined in MatchEventType enum ---
          // case MatchEventType.Injury:
          //    icon = Icons.local_hospital;
          //    iconColor = Colors.redAccent;
          //    description = 'Injury ($teamName)';
          //    break;
          // case MatchEventType.KickOff:
          //    icon = Icons.timer;
          //    iconColor = Colors.blueGrey;
          //    description = 'Kick Off';
          //    break;
          // case MatchEventType.HalfTime:
          //    icon = Icons.schedule; // Corrected icon again
          //    iconColor = Colors.blueGrey;
          //    description = 'Half Time';
          //    break;
          // case MatchEventType.FullTime:
          //    icon = Icons.timer_off;
          //    iconColor = Colors.blueGrey;
          //    description = 'Full Time';
          //    break;
          // case MatchEventType.Save:
          //    icon = Icons.shield;
          //    iconColor = Colors.lightBlue;
          //    description = 'Save ($teamName)';
          //    break;
          // case MatchEventType.Foul:
          //    icon = Icons.warning_amber_rounded;
          //    iconColor = Colors.orangeAccent;
          //    description = 'Foul ($teamName)';
          //    break;
          // case MatchEventType.ChanceMissed:
          //    icon = Icons.cancel_outlined;
          //    iconColor = Colors.grey;
          //    description = 'Chance Missed ($teamName)';
          //    break;
          // --- End undefined cases ---
          case MatchEventType.PenaltyShootout: // Added case
            icon = Icons.sports_soccer; // Use soccer ball icon
            // Color based on outcome (assuming description contains 'scored' or 'missed')
            iconColor = event.description.toLowerCase().contains('scored')
                ? Colors.green.shade600
                : Colors.red.shade600;
            description = event.description; // Use the full description from the event
            break;
          case MatchEventType.Info: // Keep default icon/color
            break;
          // No default needed if all cases are handled
        }

        return ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text("${event.minute}' - $description"),
          subtitle: Text(playerName), // Show player name in subtitle
        );
      },
    );
  }

   Widget _buildLineups(BuildContext context, Match match, GameStateManager gameState, String homeTeamName, String awayTeamName) {
     // Show lineups even if not simulated, if available (e.g., if pre-set)
     // Use match.homeLineup and match.awayLineup which store IDs
     if (match.homeLineup.isEmpty || match.awayLineup.isEmpty) {
       return const Text('Lineups not available.');
     }

     List<Player> homePlayers = _resolvePlayers(match.homeLineup, match.homeTeamId, gameState);
     List<Player> awayPlayers = _resolvePlayers(match.awayLineup, match.awayTeamId, gameState);

     return Row(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Expanded(
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(homeTeamName, style: Theme.of(context).textTheme.titleMedium),
               const Divider(),
               if (homePlayers.isNotEmpty)
                 ...homePlayers.map((p) => Text('${p.name} (Skill: ${p.currentSkill})')).toList()
               else
                 const Text('Lineup unavailable'), // Indicate if players couldn't be resolved
             ],
           ),
         ),
         const SizedBox(width: 16), // Spacer
         Expanded(
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(awayTeamName, style: Theme.of(context).textTheme.titleMedium),
               const Divider(),
                if (awayPlayers.isNotEmpty)
                 ...awayPlayers.map((p) => Text('${p.name} (Skill: ${p.currentSkill})')) // Removed .toList()
               else
                 const Text('Lineup unavailable'), // Indicate if players couldn't be resolved
             ],
           ),
         ),
       ],
     );
   }

   // Helper to get full Player objects from IDs stored in the match lineup
   List<Player> _resolvePlayers(List<String> playerIds, String teamId, GameStateManager gameState) {
     List<Player> players = [];
     if (teamId == GameStateManager.playerAcademyId) {
       players = gameState.academyPlayers.where((p) => playerIds.contains(p.id)).toList();
     } else if (gameState.rivalAcademyMap.containsKey(teamId)) { // Check Rivals
       RivalAcademy? academy = gameState.rivalAcademyMap[teamId];
       if (academy != null) {
         players = academy.players.where((p) => playerIds.contains(p.id)).toList();
       }
     } else if (gameState.aiClubMap.containsKey(teamId)) { // Check AI Clubs
       AIClub? club = gameState.aiClubMap[teamId];
       if (club != null) {
         players = club.players.where((p) => playerIds.contains(p.id)).toList();
       }
     } else {
       print("Warning: Could not resolve players for team ID $teamId in MatchDetailsScreen._resolvePlayers");
     }
     // Sort players alphabetically by name for consistent display
     players.sort((a, b) => a.name.compareTo(b.name));
     return players;
   }
}
