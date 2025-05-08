import 'package:json_annotation/json_annotation.dart';
import 'match.dart';
import 'dart:math';
import 'package:uuid/uuid.dart'; // For generating unique IDs
import 'package:collection/collection.dart'; // For firstWhereOrNull

part 'tournament.g.dart';

enum TournamentType {
  threeVthree,
  fiveVfive,
  sevenVseven,
  elevenVeleven,
}

// --- NEW: Tournament Format ---
enum TournamentFormat {
  Knockout,
  League,
}
// --- END NEW ---

enum TournamentStatus {
  Scheduled, // Newly created, matches not yet generated or started
  InProgress, // Matches are being played
  Completed, // All matches finished, winner determined
  Cancelled, // Not enough participants or other reason
}

// --- NEW: League Standing Entry ---
@JsonSerializable()
class LeagueStanding {
  final String teamId;
  int played;
  int wins;
  int draws;
  int losses;
  int goalsFor;
  int goalsAgainst;

  LeagueStanding({
    required this.teamId,
    this.played = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
  });

  int get points => (wins * 3) + draws;
  int get goalDifference => goalsFor - goalsAgainst;

  factory LeagueStanding.fromJson(Map<String, dynamic> json) => _$LeagueStandingFromJson(json);
  Map<String, dynamic> toJson() => _$LeagueStandingToJson(this);
}
// --- END NEW ---

@JsonSerializable(explicitToJson: true)
class Tournament {
  // --- Template Properties (used for creating instances) ---
  final String? baseId; // ID of the template this was created from
  final String name;
  final TournamentType type;
  final TournamentFormat format; // NEW: Format (Knockout/League)
  final int requiredReputation;
  final int entryFee;
  final int prizeMoneyBase; // Base prize, can be adjusted
  final int numberOfTeams; // Target number of teams
  final int rounds; // For knockout format (ignored for League)
  final int minTeamsToStart; // Minimum teams required for the tournament to actually start
  final bool isAIClubFocusedLeague; // NEW: Flag for AI club priority leagues
  final int? youthAcademyMinReputation; // NEW: Optional separate rep req for youth teams in AI leagues

  // --- Instance Properties ---
  final String id; // Unique ID for this specific instance
  final List<String> teamIds; // List of academy IDs participating in *this* instance
  final DateTime startDate; // Date the tournament instance is scheduled to begin matches
  TournamentStatus status;
  List<Match> matches;
  String? winnerId; // ID of the winning academy
  int currentRound; // Track current round for knockout
  String? currentByeTeamId; // Tracks the team getting a bye in the *current* round being generated
  Map<String, LeagueStanding> leagueStandings; // For league format
  Map<int, List<String>> roundByes; // Tracks teams that received a bye in a specific round

  Tournament({
    required this.id,
    required this.name,
    required this.type,
    required this.format, // Added format
    required this.requiredReputation,
    required this.entryFee,
    required this.prizeMoneyBase,
    required this.numberOfTeams,
    required this.rounds,
    required this.teamIds,
    required this.startDate,
    this.status = TournamentStatus.Scheduled, // Default status for new instance
    this.matches = const [],
    this.winnerId,
    this.baseId,
    int? minTeams, // Optional override for min teams when creating instance directly
    this.currentRound = 1, // Default to round 1
    Map<String, LeagueStanding>? standings,
    Map<int, List<String>>? byes,
    this.currentByeTeamId, // Add constructor parameter
    this.isAIClubFocusedLeague = false, // Default to false
    this.youthAcademyMinReputation, // Add constructor parameter
  }) : minTeamsToStart = minTeams ?? (numberOfTeams ~/ 2).clamp(2, numberOfTeams),
       leagueStandings = standings ?? {},
       roundByes = byes ?? {}; // Initialize byes map

  // --- Factory for creating templates ---
  factory Tournament.createTemplate({
    required String name,
    required TournamentType type,
    required TournamentFormat format, // Added format
    required int requiredReputation,
    required int entryFee,
    required int prizeMoneyBase,
    required int numberOfTeams,
    int rounds = 0, // Optional for knockout, ignored for league
    int? minTeamsToStart, // Optional min teams for template
    String? templateId, // Optional specific ID for the template
    bool isAIClubFocused = false, // NEW: Template parameter
    int? youthRepReq, // NEW: Template parameter
  }) {
    int actualMinTeams = minTeamsToStart ?? (numberOfTeams ~/ 2).clamp(2, numberOfTeams);
    // Calculate rounds for knockout if not provided (log base 2)
    int calculatedRounds = (format == TournamentFormat.Knockout && rounds == 0)
        ? (log(numberOfTeams) / log(2)).ceil()
        : rounds;

    return Tournament(
      id: templateId ?? Uuid().v4(),
      baseId: null,
      name: name,
      type: type,
      format: format, // Use provided format
      requiredReputation: requiredReputation,
      entryFee: entryFee,
      prizeMoneyBase: prizeMoneyBase,
      numberOfTeams: numberOfTeams,
      rounds: calculatedRounds, // Use calculated or provided rounds
      minTeams: actualMinTeams,
      isAIClubFocusedLeague: isAIClubFocused, // NEW: Set from template param
      youthAcademyMinReputation: youthRepReq, // NEW: Set from template param
      // --- Dummy values for instance fields (not used by template logic) ---
      teamIds: [],
      startDate: DateTime.now(),
      status: TournamentStatus.Scheduled,
    );
  }

  // --- Factory to create an instance from a template ---
  factory Tournament.fromTemplate(Tournament template, List<String> participants, DateTime gameCurrentDate) {
    // Schedule the tournament start based on format
    DateTime instanceStartDate;
    if (template.format == TournamentFormat.League) {
      // Leagues start at the beginning of the next season (e.g., July 1st)
      int startYear = gameCurrentDate.month >= 7 ? gameCurrentDate.year + 1 : gameCurrentDate.year;
      instanceStartDate = DateTime(startYear, 7, 1);
    } else {
      // Knockouts start two weeks from now (Monday)
      int daysUntilNextMonday = (7 - gameCurrentDate.weekday + 1);
      if (gameCurrentDate.weekday == DateTime.monday) daysUntilNextMonday = 7;
      instanceStartDate = gameCurrentDate.add(Duration(days: daysUntilNextMonday + 7));
      instanceStartDate = DateTime(instanceStartDate.year, instanceStartDate.month, instanceStartDate.day);
    }

    // Initialize league standings if it's a league
    Map<String, LeagueStanding> initialStandings = {};
    if (template.format == TournamentFormat.League) {
      for (String teamId in participants) {
        initialStandings[teamId] = LeagueStanding(teamId: teamId);
      }
    }

    Tournament newInstance = Tournament(
      id: Uuid().v4(),
      baseId: template.id,
      name: template.name,
      type: template.type,
      format: template.format, // Inherit format
      requiredReputation: template.requiredReputation,
      entryFee: template.entryFee,
      prizeMoneyBase: template.prizeMoneyBase,
      numberOfTeams: template.numberOfTeams,
      rounds: template.rounds,
      minTeams: template.minTeamsToStart,
      teamIds: List.from(participants),
      startDate: instanceStartDate, // Use calculated start date
      status: TournamentStatus.Scheduled,
      matches: [],
      currentRound: 1, // Start at round 1
      standings: initialStandings, // Add initial standings
      isAIClubFocusedLeague: template.isAIClubFocusedLeague, // Inherit flag
      youthAcademyMinReputation: template.youthAcademyMinReputation, // Inherit rep req
    );

    return newInstance;
  }

  // Helper to determine the tier of an AI Club Focused League from its name
  int getLeagueTier() {
    if (!isAIClubFocusedLeague) return 0; // Not an AI league
    if (name.contains("Tier 1")) return 1;
    if (name.contains("Tier 2")) return 2;
    if (name.contains("Tier 3")) return 3;
    return 0; // Unknown tier
  }

  // --- Match Generation Logic (Called when tournament starts) ---
  void generateMatchesForStart() {
    if (teamIds.length < minTeamsToStart) {
      print("Cannot generate matches for ${name}: Not enough teams (${teamIds.length}/${minTeamsToStart}). Cancelling.");
      status = TournamentStatus.Cancelled;
      matches.clear();
      leagueStandings.clear();
      return;
    }
    if (matches.isNotEmpty) {
      print("Matches already generated for ${name}. Skipping generation.");
      return; // Don't regenerate if already done
    }

    matches.clear();
    currentRound = 1; // Reset round counter
    roundByes.clear(); // Clear any previous bye data
    currentByeTeamId = null; // Reset current bye team ID

    if (format == TournamentFormat.Knockout) {
      _generateKnockoutRound(List.from(teamIds), currentRound);
    } else if (format == TournamentFormat.League) {
      print("Generating league schedule with ${teamIds.length} teams"); // Fix: Use teamIds
      _generateLeagueSchedule(List.from(teamIds));
      // Initialize standings again just in case participants changed before start
      leagueStandings.clear();
      for (String teamId in teamIds) {
         leagueStandings[teamId] = LeagueStanding(teamId: teamId);
       }
    }

    print("-> [Tournament ${id}] generateMatchesForStart: Generated ${matches.length} initial matches for ${name} (${format.name})."); // DEBUG
  }

  // --- Knockout Round Generation ---
  void _generateKnockoutRound(List<String> roundTeams, int roundNumber) {
    roundTeams.shuffle(Random()); // Randomize seeding for the round
    DateTime matchDate = _getNextAvailableMatchDate(roundNumber);
    int matchesInRound = 0;

    print("Generating matches for Round $roundNumber (${roundTeams.length} teams) starting around $matchDate");

    // Reset current bye ID for this generation attempt
    currentByeTeamId = null;
    // Ensure the map entry exists for the current round in the historical record
    roundByes[roundNumber] = [];

    if (roundTeams.length % 2 != 0) {
      // Handle bye for odd number of teams
      currentByeTeamId = roundTeams.removeLast(); // Assign to the instance field
      roundByes[roundNumber]!.add(currentByeTeamId!); // Record the bye historically
      print("Info: $currentByeTeamId gets a bye in Round $roundNumber.");
    }

    for (int i = 0; i < roundTeams.length; i += 2) {
      String homeTeamId = roundTeams[i];
      String awayTeamId = roundTeams[i + 1];

      matches.add(Match(
        id: Uuid().v4(),
        tournamentId: id,
        round: roundNumber,
        matchDate: matchDate,
        homeTeamId: homeTeamId,
        awayTeamId: awayTeamId,
      ));
      matchesInRound++;

      // Simple scheduling: advance date for next match in the round
      matchDate = matchDate.add(const Duration(days: 1)); // One match per day
    }
    print(" -> Generated $matchesInRound matches for Round $roundNumber.");
  }

  // --- Generate Next Knockout Round (Called by GameStateManager) ---
  bool generateNextKnockoutRound() {
    if (format != TournamentFormat.Knockout || status != TournamentStatus.InProgress) {
      print("Cannot generate next round: format=${format.name}, status=${status.name}"); // Use .name for enums
      return false;
    }

    print("Generating next knockout round for ${name}, current round completed: $currentRound");

    // Find winners from the current round's simulated matches
    List<Match> currentRoundMatches = matches.where((m) => m.round == currentRound && m.isSimulated).toList();
    print("Simulated matches in round $currentRound: ${currentRoundMatches.length}");

    // Check if ALL matches for the current round are simulated
    int expectedMatchesThisRound = matches.where((m) => m.round == currentRound).length;
    print("Expected matches this round: ${expectedMatchesThisRound}");
    if (expectedMatchesThisRound > 0 && currentRoundMatches.length < expectedMatchesThisRound) {
        print("Info: Round $currentRound of ${name} not fully simulated yet (${currentRoundMatches.length}/$expectedMatchesThisRound). Cannot generate next round.");
        return false;
    }
    // Handle case where round 1 might have only byes (e.g., 1 team tournament - unlikely but possible)
    if (expectedMatchesThisRound == 0 && currentRound == 1 && teamIds.length == 1) {
        // Special case: Only one team, they are the winner by default.
        print("Only one team in tournament, winner determined.");
        winnerId = teamIds.first;
        status = TournamentStatus.Completed;
        return false; // No next round needed
    }
    // If no matches were expected and it's not round 1 with a single team, something is wrong or the round only had byes.
    if (expectedMatchesThisRound == 0 && !(currentRound == 1 && teamIds.length == 1)) {
         print("Warning: No matches expected or found for round $currentRound, but it's not a single-team tournament start. Checking for byes.");
         // Proceed to check byes, maybe the round consisted only of byes advancing.
    }


    List<String> winners = [];
    for (var match in currentRoundMatches) {
      // Use winnerId getter from Match model
      String? winner = match.winnerId;
      if (winner != null) {
        winners.add(winner);
      } else if (match.result != MatchResult.draw) {
         print("Warning: Match ${match.id} is simulated but has no winner and is not a draw.");
      } else {
         print("Warning: Draw occurred in knockout match ${match.id}. Draw handling not implemented. Team will not advance.");
         // TODO: Implement draw handling (e.g., penalties) if required by game rules.
      }
    }
    print("Found ${winners.length} winners in round $currentRound: ${winners.join(', ')}");

    // Get teams that received a bye in the *current* round
    List<String> currentRoundByes = roundByes[currentRound] ?? [];
    if (currentRoundByes.isNotEmpty) {
      print("Teams with byes in round $currentRound: ${currentRoundByes.join(', ')}");
    }

    // Combine winners and byes for the next round
    List<String> nextRoundParticipants = [...winners, ...currentRoundByes];
    print("Total participants for next round (${nextRoundParticipants.length}): ${nextRoundParticipants.join(', ')}");

    // Check if the tournament is over
    if (nextRoundParticipants.length <= 1) {
      if (nextRoundParticipants.length == 1) {
        winnerId = nextRoundParticipants.first;
        print("Tournament ${name} completed. Winner: $winnerId");
      } else {
        // This might happen if the last round had a draw and no winner advanced
        print("Tournament ${name} completed. No single winner determined from the last round.");
        // Decide how to handle this - maybe leave winnerId null?
      }
      status = TournamentStatus.Completed;
      return false; // No next round to generate
    }

    // Check if we exceeded the expected number of rounds
    int nextRoundNumber = currentRound + 1;
    if (nextRoundNumber > rounds) {
         print("Error: Trying to generate round $nextRoundNumber but tournament only has $rounds rounds based on initial calculation.");
         // This could indicate an issue with bye logic or round calculation.
         // Let's complete the tournament anyway if there are participants left.
         // Consider setting status to Completed if only one participant remains.
         if (nextRoundParticipants.length == 1) {
             winnerId = nextRoundParticipants.first;
             status = TournamentStatus.Completed;
             print("Correcting: Final round completed. Winner: $winnerId");
             return false;
         } else {
             // If more than 1 participant left but rounds exceeded, maybe recalculate rounds or handle error?
             print("Warning: More than 1 participant left but calculated rounds exceeded. Proceeding with round $nextRoundNumber.");
             // Optionally, update the 'rounds' property if dynamic rounds are allowed.
         }
    }

    // Generate the next round
    currentRound = nextRoundNumber; // Advance to the next round *before* generating
    _generateKnockoutRound(nextRoundParticipants, currentRound);
    print("Generated round $currentRound with ${nextRoundParticipants.length} teams");
    return true; // New round generated
  }

  // --- League Schedule Generation ---
  void _generateLeagueSchedule(List<String> leagueTeams) {
    print("Generating league schedule with ${leagueTeams.length} teams");
    if (leagueTeams.length < 2) return;

    List<String> teams = List.from(leagueTeams);
    bool addGhostTeam = false;
    if (teams.length % 2 != 0) {
      teams.add("ghost"); // Add dummy team for scheduling if odd number
      addGhostTeam = true;
    }

    int numTeams = teams.length;
    int numRounds = numTeams - 1;
    int matchesPerRound = numTeams ~/ 2;
    DateTime currentMatchDate = DateTime(startDate.year, startDate.month, startDate.day);

    List<Match> firstHalfMatches = [];
    List<Map<String, String>> secondHalfFixtures = []; // Store { 'home': teamId, 'away': teamId }

    // --- Schedule First Half (July to ~December) ---
    int firstHalfMatchCount = numRounds * matchesPerRound;
    // Target ~150 days for first half (July 1st to end of Nov)
    int daysBetweenFirstHalf = (150 ~/ firstHalfMatchCount).clamp(1, 5); // Compress slightly, max 5 days apart
    DateTime firstHalfDate = DateTime(startDate.year, startDate.month, startDate.day);

    List<String> currentTeams = List.from(teams); // Use a copy for rotation

    for (int round = 0; round < numRounds; round++) {
      for (int match = 0; match < matchesPerRound; match++) {
        String home = currentTeams[match];
        String away = currentTeams[numTeams - 1 - match];

        if (home != "ghost" && away != "ghost") {
          // Create first half match
          firstHalfMatches.add(Match(
            id: Uuid().v4(),
            tournamentId: id,
            round: round + 1, // Logical round for first half
            matchDate: firstHalfDate,
            homeTeamId: home,
            awayTeamId: away,
          ));
          // Store fixture for second half
          secondHalfFixtures.add({'home': away, 'away': home});

          // Advance date for next first-half match
          firstHalfDate = firstHalfDate.add(Duration(days: daysBetweenFirstHalf));
          // Occasionally add extra day to spread more evenly
          if (firstHalfMatches.length % 5 == 0) {
             firstHalfDate = firstHalfDate.add(const Duration(days: 1));
          }
        }
      }
      // Rotate teams for next round (excluding the first team)
      currentTeams.insert(1, currentTeams.removeLast());
    }

    // --- Schedule Second Half (~December to April) ---
    List<Match> secondHalfMatches = [];
    // Start second half around early December, ensuring it's after the last first-half match
    DateTime secondHalfStartDate = firstHalfDate.isAfter(DateTime(firstHalfDate.year, 12, 1))
                                     ? firstHalfDate.add(const Duration(days: 3)) // If first half ran late, add small gap
                                     : DateTime(firstHalfDate.year, 12, 1); // Target Dec 1st start
    // Target ~120 days for second half (Dec to end of April)
    int daysBetweenSecondHalf = (120 ~/ secondHalfFixtures.length).clamp(1, 4); // Compress more, max 4 days apart
    DateTime secondHalfDate = secondHalfStartDate;

    // Shuffle fixtures for variety in second half schedule order
    secondHalfFixtures.shuffle(Random());

    for (int i = 0; i < secondHalfFixtures.length; i++) {
      var fixture = secondHalfFixtures[i];
      secondHalfMatches.add(Match(
        id: Uuid().v4(),
        tournamentId: id,
        round: numRounds + i + 1, // Logical round for second half (ensures uniqueness)
        matchDate: secondHalfDate,
        homeTeamId: fixture['home']!,
        awayTeamId: fixture['away']!,
      ));

      // Advance date for next second-half match
      secondHalfDate = secondHalfDate.add(Duration(days: daysBetweenSecondHalf));
       // Occasionally add extra day
      if (i % 5 == 0) {
           secondHalfDate = secondHalfDate.add(const Duration(days: 1));
      }
    }

    // --- Combine and Sort ---
    matches.addAll(firstHalfMatches);
    matches.addAll(secondHalfMatches);
    matches.sort((a, b) => a.matchDate.compareTo(b.matchDate)); // Sort by actual date

    if (addGhostTeam) teams.remove("ghost"); // Remove dummy team if it was added initially
  }

  // --- Helper Methods ---

  // Find the next available date for a match, considering existing matches
  DateTime _getNextAvailableMatchDate(int roundNumber) {
    DateTime date;
    if (matches.isEmpty) {
      date = DateTime(startDate.year, startDate.month, startDate.day);
    } else {
      // Start scheduling after the latest scheduled match, plus a gap between rounds
      DateTime latestMatchDate = matches.map((m) => m.matchDate).reduce((a, b) => a.isAfter(b) ? a : b);
      // Add a gap (e.g., 3 days) between rounds
      int gapDays = (roundNumber > 1) ? 3 : 0;
      date = latestMatchDate.add(Duration(days: 1 + gapDays));
    }
    // Ensure matches don't happen too close together (simple check)
    while (matches.any((m) => m.matchDate.year == date.year && m.matchDate.month == date.month && m.matchDate.day == date.day)) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  // Helper to get required players based on type
  @JsonKey(includeFromJson: false, includeToJson: false)
  int get requiredPlayers {
     switch (type) {
      case TournamentType.threeVthree: return 3;
      case TournamentType.fiveVfive: return 5;
      case TournamentType.sevenVseven: return 7;
      case TournamentType.elevenVeleven: return 11;
      default: return 11;
    }
  }

  // Helper to get a display name for the type
  @JsonKey(includeFromJson: false, includeToJson: false)
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get typeDisplay {
    switch (type) {
      case TournamentType.threeVthree: return '3v3';
      case TournamentType.fiveVfive: return '5v5';
      case TournamentType.sevenVseven: return '7v7';
      case TournamentType.elevenVeleven: return '11v11';
      default: return 'Unknown';
    }
  }

  factory Tournament.fromJson(Map<String, dynamic> json) => _$TournamentFromJson(json);
  Map<String, dynamic> toJson() => _$TournamentToJson(this);
}
