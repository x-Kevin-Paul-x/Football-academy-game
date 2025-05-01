import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:provider/provider.dart'; // Import Provider
import '../game_state_manager.dart'; // Import GameStateManager
import '../models/tournament.dart';
import '../models/match.dart' hide GameStateManager; // Hide dummy GameStateManager
import '../models/rival_academy.dart'; // Use RivalAcademy instead of AIClub
import '../models/player.dart'; // Import Player
import 'MatchDetailsScreen.dart'; // Import the new screen

class TournamentDetailsScreen extends StatelessWidget {
  // Removed constructor arguments that are now fetched via Provider
  final String tournamentId; // Pass only the ID

  const TournamentDetailsScreen({
    Key? key,
    required this.tournamentId,
  }) : super(key: key);

  // Helper to get team name - Uses GameStateManager
  String _getTeamName(BuildContext context, String teamId, GameStateManager gameState) {
    if (teamId == GameStateManager.playerAcademyId) {
      return gameState.academyName;
    } else {
      // Use rivalAcademyMap from GameStateManager
      return gameState.rivalAcademyMap[teamId]?.name ?? 'Unknown Rival';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to get the specific tournament and related data
    return Consumer<GameStateManager>(
      builder: (context, gameStateManager, child) {
        // Find the tournament instance (active or completed)
        final Tournament? tournament = gameStateManager!.activeTournaments.firstWhereOrNull((t) => t.id == tournamentId) ??
                                        gameStateManager!.completedTournaments.firstWhereOrNull((t) => t.id == tournamentId);

        if (tournament == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Tournament not found.')),
          );
        }

        // Get matches for this tournament (already part of the Tournament object)
        final List<Match> matches = tournament.matches;
        final String playerAcademyId = GameStateManager.playerAcademyId;
        final String academyName = gameStateManager!.academyName;
        final Map<String, Player> academyPlayersMap = {
          for (var player in gameStateManager!.academyPlayers) player.id: player
        };
        final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

        return Scaffold(
          appBar: AppBar(
            title: Text(tournament.name),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text('Type: ${tournament.typeDisplay}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Prize (Base): ${currencyFormat.format(tournament.prizeMoneyBase)}', style: Theme.of(context).textTheme.titleMedium), // Use prizeMoneyBase
              const SizedBox(height: 8),
              Text('Status: ${tournament.status.toString().split('.').last}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Starts: ${DateFormat.yMMMd().format(tournament.startDate)}', style: Theme.of(context).textTheme.titleMedium),
              if (tournament.status == TournamentStatus.Completed && tournament.winnerId != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Winner: ${_getTeamName(context, tournament.winnerId!, gameStateManager)}', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 16)),
                ),
              const SizedBox(height: 16),
              Text('Participants (${tournament.teamIds.length}):', style: Theme.of(context).textTheme.titleLarge), // Use teamIds
              const SizedBox(height: 8),
              Wrap( // Use Wrap for better layout of participant names
                spacing: 8.0,
                runSpacing: 4.0,
                children: tournament.teamIds.map((id) { // Use teamIds
                  final name = _getTeamName(context, id, gameStateManager); // Pass gameStateManager
                  final isPlayer = id == playerAcademyId;
                  return Chip(
                    label: Text(name),
                    backgroundColor: isPlayer ? Theme.of(context).colorScheme.primaryContainer : null,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text('Matches:', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (matches.isEmpty)
                const Text('No matches generated yet.')
              else
                Column(
                  children: matches.map((match) {
                    final homeTeamName = _getTeamName(context, match.homeTeamId, gameStateManager); // Pass gameStateManager
                    final awayTeamName = _getTeamName(context, match.awayTeamId, gameStateManager); // Pass gameStateManager
                    final DateFormat dateFormatter = DateFormat('MMM d, yyyy'); // Date formatter
                    final String matchDateString = dateFormatter.format(match.matchDate); // Format the date

                    // Determine display text based on simulation status
                    String subtitleText;
                    String trailingText;
                    if (match.isSimulated) {
                      subtitleText = 'Result: ${match.homeScore} - ${match.awayScore}';
                      trailingText = matchDateString; // Show date as trailing text for results
                    } else {
                      subtitleText = 'Scheduled';
                      trailingText = matchDateString; // Show date as trailing text for scheduled
                    }

                    final isPlayerMatch = match.homeTeamId == playerAcademyId || match.awayTeamId == playerAcademyId;

                    // Determine text style based on simulation status and result for player team
                    TextStyle trailingStyle = TextStyle(
                      fontWeight: FontWeight.bold,
                      // Use context to get theme color for pending matches
                      color: match.isSimulated ? Theme.of(context).textTheme.bodyLarge?.color : Colors.grey,
                    );
                    if (match.isSimulated && isPlayerMatch) { // Only color if player involved
                       if ((match.homeTeamId == playerAcademyId && match.result == MatchResult.homeWin) ||
                           (match.awayTeamId == playerAcademyId && match.result == MatchResult.awayWin)) {
                         trailingStyle = trailingStyle.copyWith(color: Colors.green[700]); // Player Win
                       } else if ((match.homeTeamId == playerAcademyId && match.result == MatchResult.awayWin) ||
                                  (match.awayTeamId == playerAcademyId && match.result == MatchResult.homeWin)) {
                         trailingStyle = trailingStyle.copyWith(color: Colors.red[700]); // Player Loss
                       }
                       // Keep default theme color for draw
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        title: Text('$homeTeamName vs $awayTeamName'),
                        subtitle: Text('Date: $matchDateString'), // Show date in subtitle
                        trailing: Text(
                          match.isSimulated ? '${match.homeScore} - ${match.awayScore}' : 'Pending',
                          style: trailingStyle, // Apply dynamic style
                        ),
                        tileColor: isPlayerMatch ? Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3) : null,
                        onTap: match.isSimulated ? () {
                          // Navigate to MatchDetailsScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MatchDetailsScreen(
                                // Pass IDs instead of full objects
                                tournamentId: tournament.id,
                                matchId: match.id,
                                // No need to pass maps/names, MatchDetailsScreen will use Provider
                              ),
                            ),
                          );
                        } : null, // Disable tap if not simulated
                      ),
                    );
                  }).toList(),
                ),

              // --- Conditional Standings/Bracket ---
              if (tournament.format == TournamentFormat.League) ...[
                const SizedBox(height: 24),
                Text('Standings:', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                _buildStandingsTable(context, tournament, matches, gameStateManager), // Pass context, tournament, matches, gameState
              ] else if (tournament.format == TournamentFormat.Knockout) ...[
                 const SizedBox(height: 24),
                 Text('Knockout Progress', style: Theme.of(context).textTheme.titleLarge),
                 const SizedBox(height: 8),
                 // TODO: Implement a proper knockout bracket visualization
                 const Center(child: Padding(
                   padding: EdgeInsets.all(16.0),
                   child: Text("Knockout Bracket display coming soon!", style: TextStyle(fontStyle: FontStyle.italic)),
                 )),
                 // Optionally, still show matches grouped by round here later
              ],
              // --- End Conditional ---

            ],
          ),
        );
      },
    );
  }

  // Calculate and build standings table
  Widget _buildStandingsTable(BuildContext context, Tournament tournament, List<Match> matches, GameStateManager gameState) { // Accept context, tournament, matches, gameState
    // Calculate points: 3 for win, 1 for draw, 0 for loss
    Map<String, int> points = {};
    Map<String, int> goalsFor = {};
    Map<String, int> goalsAgainst = {};
    Map<String, int> matchesPlayed = {};

    // Initialize maps for all unique participants to avoid issues with potential duplicates in the source list
    Set<String> uniqueParticipants = tournament.teamIds.toSet(); // Use teamIds, Ensure uniqueness
    for (var teamId in uniqueParticipants) { // Iterate over unique IDs
      points[teamId] = 0;
      goalsFor[teamId] = 0;
      goalsAgainst[teamId] = 0;
      matchesPlayed[teamId] = 0;
    }

    // Tally results from matches
    for (var match in matches) {
      if (match.result == null) continue; // Skip unplayed/unsimulated matches

      // Increment matches played only if team exists in the map (safety check)
      if (matchesPlayed.containsKey(match.homeTeamId)) {
        matchesPlayed[match.homeTeamId] = matchesPlayed[match.homeTeamId]! + 1;
      }
      if (matchesPlayed.containsKey(match.awayTeamId)) {
        matchesPlayed[match.awayTeamId] = matchesPlayed[match.awayTeamId]! + 1;
      }


      // Add goals (safety check)
      if (goalsFor.containsKey(match.homeTeamId)) {
        goalsFor[match.homeTeamId] = goalsFor[match.homeTeamId]! + match.homeScore;
        goalsAgainst[match.homeTeamId] = goalsAgainst[match.homeTeamId]! + match.awayScore;
      }
      if (goalsFor.containsKey(match.awayTeamId)) {
        goalsFor[match.awayTeamId] = goalsFor[match.awayTeamId]! + match.awayScore;
        goalsAgainst[match.awayTeamId] = goalsAgainst[match.awayTeamId]! + match.homeScore;
      }


      // Award points (safety check)
      switch (match.result!) {
        case MatchResult.homeWin:
          if (points.containsKey(match.homeTeamId)) {
            points[match.homeTeamId] = points[match.homeTeamId]! + 3;
          }
          break;
        case MatchResult.awayWin:
           if (points.containsKey(match.awayTeamId)) {
            points[match.awayTeamId] = points[match.awayTeamId]! + 3;
           }
          break;
        case MatchResult.draw:
          if (points.containsKey(match.homeTeamId)) {
            points[match.homeTeamId] = points[match.homeTeamId]! + 1;
          }
          if (points.containsKey(match.awayTeamId)) {
            points[match.awayTeamId] = points[match.awayTeamId]! + 1;
          }
          break;
      }
    }

    // Sort unique teams by points (descending), then goal difference, then goals for
    List<String> sortedTeamIds = uniqueParticipants.toList(); // Sort the unique list
    sortedTeamIds.sort((a, b) {
      int pointsComparison = (points[b] ?? 0).compareTo(points[a] ?? 0);
      if (pointsComparison != 0) return pointsComparison;

      int gdA = (goalsFor[a] ?? 0) - (goalsAgainst[a] ?? 0);
      int gdB = (goalsFor[b] ?? 0) - (goalsAgainst[b] ?? 0);
      int gdComparison = gdB.compareTo(gdA);
      if (gdComparison != 0) return gdComparison;

      return (goalsFor[b] ?? 0).compareTo(goalsFor[a] ?? 0);
    });

    // Build the table widget
    return DataTable(
      columnSpacing: 15.0, // Adjust spacing
      columns: const [
        DataColumn(label: Text('Pos')),
        DataColumn(label: Text('Team')),
        DataColumn(label: Text('MP')),
        DataColumn(label: Text('GF')),
        DataColumn(label: Text('GA')),
        DataColumn(label: Text('GD')),
        DataColumn(label: Text('Pts')),
      ],
      rows: sortedTeamIds.asMap().entries.map((entry) {
        int index = entry.key;
        String teamId = entry.value;
        String teamName = _getTeamName(context, teamId, gameState); // Pass gameState
        int mp = matchesPlayed[teamId] ?? 0;
        int gf = goalsFor[teamId] ?? 0;
        int ga = goalsAgainst[teamId] ?? 0;
        int gd = gf - ga;
        int pts = points[teamId] ?? 0;
        bool isPlayer = teamId == GameStateManager.playerAcademyId;

        return DataRow(
          color: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              return isPlayer ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3) : null;
            },
          ),
          cells: [
            DataCell(Text('${index + 1}')),
            DataCell(Text(teamName, overflow: TextOverflow.ellipsis)),
            DataCell(Text('$mp')),
            DataCell(Text('$gf')),
            DataCell(Text('$ga')),
            DataCell(Text('$gd')),
            DataCell(Text('$pts', style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        );
      }).toList(),
    );
  }
}
