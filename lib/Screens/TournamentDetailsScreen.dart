import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import '../models/tournament.dart';
import '../models/match.dart';
import '../models/ai_club.dart'; // To display club names/details
import 'MatchDetailsScreen.dart'; // Import the new screen

class TournamentDetailsScreen extends StatelessWidget {
  final Tournament tournament;
  final List<Match> matches;
  final Map<String, AIClub> aiClubMap; // Pass the map for easy name lookup
  final String playerAcademyId; // To identify player's matches/team

  const TournamentDetailsScreen({
    Key? key,
    required this.tournament,
    required this.matches,
    required this.aiClubMap,
    required this.playerAcademyId,
  }) : super(key: key);

  // Helper to get team name
  String _getTeamName(String teamId) {
    if (teamId == playerAcademyId) {
      return "My Academy"; // Replace with actual academy name later
    } else {
      return aiClubMap[teamId]?.name ?? 'Unknown Club';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tournament.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text('Type: ${tournament.typeDisplay}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Prize: ${tournament.prize}', style: Theme.of(context).textTheme.titleMedium),
          // const SizedBox(height: 8), // Removed spacing for startDate
          // Text('Starts: ${tournament.startDate.toLocal().toString().split(' ')[0]}', style: Theme.of(context).textTheme.titleMedium), // REMOVED Start Date Display
          const SizedBox(height: 16),
          Text('Participants (${tournament.participants.length}):', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap( // Use Wrap for better layout of participant names
            spacing: 8.0,
            runSpacing: 4.0,
            children: tournament.participants.map((id) {
              final name = _getTeamName(id);
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
                final homeTeamName = _getTeamName(match.homeTeamId);
                final awayTeamName = _getTeamName(match.awayTeamId);
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
                            match: match,
                            aiClubMap: aiClubMap, // Pass the map
                            playerAcademyId: playerAcademyId, // Pass player ID
                          ),
                        ),
                      );
                    } : null, // Disable tap if not simulated
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 24),
          Text('Standings:', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _buildStandingsTable(context),
        ],
      ),
    );
  }

  // Calculate and build standings table
  Widget _buildStandingsTable(BuildContext context) {
    // Calculate points: 3 for win, 1 for draw, 0 for loss
    Map<String, int> points = {};
    Map<String, int> goalsFor = {};
    Map<String, int> goalsAgainst = {};
    Map<String, int> matchesPlayed = {};

    // Initialize maps for all unique participants to avoid issues with potential duplicates in the source list
    Set<String> uniqueParticipants = tournament.participants.toSet(); // Ensure uniqueness
    for (var teamId in uniqueParticipants) { // Iterate over unique IDs
      points[teamId] = 0;
      goalsFor[teamId] = 0;
      goalsAgainst[teamId] = 0;
      matchesPlayed[teamId] = 0;
    }

    // Tally results from matches
    for (var match in matches) {
      if (match.result == null) continue; // Skip unplayed/unsimulated matches

      // Increment matches played
      matchesPlayed[match.homeTeamId] = (matchesPlayed[match.homeTeamId] ?? 0) + 1;
      matchesPlayed[match.awayTeamId] = (matchesPlayed[match.awayTeamId] ?? 0) + 1;

      // Add goals
      goalsFor[match.homeTeamId] = (goalsFor[match.homeTeamId] ?? 0) + match.homeScore;
      goalsAgainst[match.homeTeamId] = (goalsAgainst[match.homeTeamId] ?? 0) + match.awayScore;
      goalsFor[match.awayTeamId] = (goalsFor[match.awayTeamId] ?? 0) + match.awayScore;
      goalsAgainst[match.awayTeamId] = (goalsAgainst[match.awayTeamId] ?? 0) + match.homeScore;


      // Award points
      switch (match.result!) {
        case MatchResult.homeWin:
          points[match.homeTeamId] = (points[match.homeTeamId] ?? 0) + 3;
          break;
        case MatchResult.awayWin:
          points[match.awayTeamId] = (points[match.awayTeamId] ?? 0) + 3;
          break;
        case MatchResult.draw:
          points[match.homeTeamId] = (points[match.homeTeamId] ?? 0) + 1;
          points[match.awayTeamId] = (points[match.awayTeamId] ?? 0) + 1;
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
        String teamName = _getTeamName(teamId);
        int mp = matchesPlayed[teamId] ?? 0;
        int gf = goalsFor[teamId] ?? 0;
        int ga = goalsAgainst[teamId] ?? 0;
        int gd = gf - ga;
        int pts = points[teamId] ?? 0;
        bool isPlayer = teamId == playerAcademyId;

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
