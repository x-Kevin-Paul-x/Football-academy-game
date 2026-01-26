import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';
import 'package:football_academy_game/models/tournament.dart';
import 'package:football_academy_game/services/time_service.dart';

void main() {
  test('Benchmark advanceWeek performance with many future matches', () async {
    final gameStateManager = GameStateManager();

    // We need to bypass the normal random scheduling and inject a large tournament
    // Create a large league template
    final largeLeagueTemplate = Tournament.createTemplate(
      name: "Benchmark League",
      type: TournamentType.elevenVeleven,
      format: TournamentFormat.League,
      requiredReputation: 0,
      entryFee: 0,
      prizeMoneyBase: 0,
      numberOfTeams: 20, // 20 teams = 380 matches
      minTeamsToStart: 20,
    );

    // Generate dummy participants
    final participants = List.generate(20, (index) => 'team_$index');

    // Create the tournament instance
    // Note: This uses the current date from TimeService (default Jan 1 2025)
    // Leagues usually start July 1st.
    final tournament = Tournament.fromTemplate(largeLeagueTemplate, participants, gameStateManager.currentDate);

    // Generate matches
    tournament.generateMatchesForStart();
    tournament.status = TournamentStatus.InProgress;

    // Verify match count (20 teams -> 19 rounds * 2 halves = 38 rounds. 10 matches per round = 380 matches)
    // Actually the logic uses rounds = numTeams - 1. 19 rounds. 10 matches/round.
    // Wait, generateLeagueSchedule does 2 halves. So 380 matches.
    print('Generated ${tournament.matches.length} matches for benchmark.');

    // Inject into GameStateManager
    // Since _activeTournaments is private, we can use addActiveTournament if it accepts InProgress ones?
    // addActiveTournament checks ID.
    gameStateManager.addActiveTournament(tournament);

    // Now, let's advance week.
    // The matches start in July. Current date is Jan. So all matches are in the future.
    // advanceWeek iterates matches.

    final stopwatch = Stopwatch()..start();

    // Run multiple iterations to amplify the effect
    for (int i = 0; i < 100; i++) {
       gameStateManager.advanceWeek();
    }

    stopwatch.stop();
    print('Time taken for 100 advanceWeek calls: ${stopwatch.elapsedMilliseconds}ms');

    // With optimization, this should be faster because it breaks early instead of checking 380 matches x 100 times.
  });
}
