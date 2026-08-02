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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            match.isSimulated ? "FINAL" : "UPCOMING",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  homeTeamName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  match.isSimulated ? '${match.homeScore} - ${match.awayScore}' : 'vs',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  awayTeamName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ], // children
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildMetaChip(context, Icons.calendar_month, DateFormat.yMMMd().format(match.matchDate)),
              _buildMetaChip(context, Icons.format_list_numbered, 'Round ${match.round}'),
              if (match.isSimulated)
                _buildMetaChip(context, Icons.people_alt, '${NumberFormat("#,##0").format(match.viewership)} fans'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEventLog(BuildContext context, Match match, GameStateManager gameState) {
    if (!match.isSimulated || match.eventLog.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('No events recorded.', style: TextStyle(fontWeight: FontWeight.bold))),
      );
    }

    final sortedEvents = List<MatchEvent>.from(match.eventLog)..sort((a, b) => a.minute.compareTo(b.minute));

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sortedEvents.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3)),
        itemBuilder: (context, index) {
          final event = sortedEvents[index];
          String playerName = 'Unknown';
          String teamName = _getTeamName(event.teamId, gameState);

          Player? player = gameState.academyPlayers.firstWhereOrNull((p) => p.id == event.playerId);
          if (player == null) {
            RivalAcademy? rivalAcademy = gameState.rivalAcademyMap[event.teamId];
            player = rivalAcademy?.players.firstWhereOrNull((p) => p.id == event.playerId);
          }
          if (player == null) {
            AIClub? aiClub = gameState.aiClubMap[event.teamId];
            player = aiClub?.players.firstWhereOrNull((p) => p.id == event.playerId);
          }
          playerName = player?.name ?? event.playerId;

          IconData icon = Icons.info_outline;
          Color iconColor = Colors.grey;
          String description = event.description;

          switch (event.type) {
            case MatchEventType.Goal:
              icon = Icons.sports_soccer;
              iconColor = Colors.green;
              description = 'Goal!';
              break;
            case MatchEventType.Assist:
              icon = Icons.assistant;
              iconColor = Colors.blue;
              description = 'Assist';
              break;
            case MatchEventType.YellowCard:
              icon = Icons.rectangle;
              iconColor = Colors.yellow.shade700;
              description = 'Yellow Card';
              break;
            case MatchEventType.RedCard:
              icon = Icons.rectangle;
              iconColor = Colors.red;
              description = 'Red Card';
              break;
            case MatchEventType.Substitution:
              icon = Icons.swap_horiz;
              iconColor = Colors.orange;
              description = 'Substitution';
              break;
            case MatchEventType.PenaltyShootout:
              icon = Icons.sports_soccer;
              iconColor = event.description.toLowerCase().contains('scored') ? Colors.green : Colors.red;
              break;
            case MatchEventType.Info:
              break;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    "${event.minute}'",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(description, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('$playerName • $teamName', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
