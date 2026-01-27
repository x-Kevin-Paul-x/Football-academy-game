import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/models/tournament.dart';
import 'package:football_academy_game/Screens/TournamentDetailsScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('TournamentDetailsScreen uses pre-calculated leagueStandings', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Initialize GameStateManager
    final gameStateManager = GameStateManager();

    // Create a dummy league tournament
    // matches is EMPTY.
    // standings has "Team A" with 1 Win (3 points).
    // This setup simulates the discrepancy where the cache (standings) is populated
    // but the source (matches) is empty. This forces the UI to reveal which source it uses.
    const tournamentId = 'test_league_id';
    const teamA = 'Team A';
    const teamB = 'Team B';

    final tournament = Tournament(
      id: tournamentId,
      name: 'Test League',
      type: TournamentType.elevenVeleven,
      format: TournamentFormat.League,
      requiredReputation: 0,
      entryFee: 0,
      prizeMoneyBase: 0,
      numberOfTeams: 2,
      rounds: 0,
      teamIds: [teamA, teamB],
      startDate: DateTime.now(),
      status: TournamentStatus.InProgress,
      matches: [], // INTENTIONALLY EMPTY to prove we are not calculating from matches
      standings: {
        teamA: LeagueStanding(teamId: teamA, wins: 1, played: 1), // Points = 3
        teamB: LeagueStanding(teamId: teamB, losses: 1, played: 1), // Points = 0
      },
    );

    // Add tournament to active tournaments
    gameStateManager.addActiveTournament(tournament);

    // Pump the widget
    await tester.pumpWidget(
      ChangeNotifierProvider<GameStateManager>.value(
        value: gameStateManager,
        child: MaterialApp(
          home: const TournamentDetailsScreen(tournamentId: tournamentId),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify "Standings:" text is present
    expect(find.text('Standings:'), findsOneWidget);

    // Verify that Team A row exists.
    // The team name might be "Unknown Team" because the IDs are not in rival/ai maps.
    // But _getTeamName falls back to 'Unknown Team'.
    // Wait, if both are 'Unknown Team', finding text might be ambiguous.
    // Let's mock _getTeamName or use valid IDs?
    // GameStateManager logic uses rivalAcademyMap/aiClubMap.
    // I can add dummy rivals to the map.

    // Add dummy rival academies to GameStateManager so names resolve
    // But I can't easily access the private map.
    // However, I can rely on the fact that if ID is not found, it returns 'Unknown Team' or checks maps.
    // Actually, `_getTeamName` in `TournamentDetailsScreen` does:
    // gameState.rivalAcademyMap[teamId]?.name ?? gameState.aiClubMap[teamId]?.name ?? 'Unknown Team';

    // I should check what is rendered.
    // If I use "Team A" as ID, and it's not found, it renders "Unknown Team".
    // That's bad for verification.

    // I can stick to checking the POINTS (3).
    // 3 points comes from 1 win.

    // Expectation:
    // Before Optimization: The table is built from matches (empty). So wins=0, points=0.
    // The test expects '3' (from standings). So it should FAIL before optimization.
    // After Optimization: It uses standings. So points=3. It should PASS.

    // Also verify '1' (Win/Played).
    // And '0' (Draw/Loss for Team A).

    // Let's verify specifically the cell with '3' exists.
    // To be safer, I'll expect it to FAIL first.

    // Note: If the ID is not found, it returns "Unknown Team".
    // Since both IDs result in "Unknown Team", we might have duplicates.
    // But that doesn't affect the points calculation for the row corresponding to that ID.
    // The DataTable displays rows based on sortedTeamIds.
    // teamA (Unknown Team) -> 3 pts.
    // teamB (Unknown Team) -> 0 pts.

    expect(find.text('3'), findsOneWidget); // Expecting 3 points
  });
}
