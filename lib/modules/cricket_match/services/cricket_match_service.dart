import 'package:scorecard/handlers/ulid.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/team/models/team_model.dart';
import 'package:scorecard/modules/venue/models/venue_model.dart';
import 'package:scorecard/repositories/cricket_match_repository.dart';
import 'package:scorecard/repositories/provider/repository_provider.dart';

class CricketMatchService {
  ScheduledCricketMatch createCricketMatch({
    required Team team1,
    required Team team2,
    required Venue venue,
    required GameRules rules,
  }) {
    final match = ScheduledCricketMatch(
      id: ULID.generate(),
      team1: team1,
      team2: team2,
      startsAt: DateTime.now(),
      venue: venue,
      rules: rules,
    );

    // Add match to repository
    _repository.scheduleCricketMatch(match);

    return match;
  }

  InitializedCricketMatch initializeCricketMatch(
    ScheduledCricketMatch scheduledMatch, {
    required Toss toss,
    required Lineup lineup1,
    required Lineup lineup2,
  }) {
    final match = InitializedCricketMatch.fromScheduled(scheduledMatch,
        toss: toss, lineup1: lineup1, lineup2: lineup2);

    // Update match in repository
    _repository.initializeCricketMatch(match);

    return match;
  }

  OngoingCricketMatch commenceCricketMatch(
      InitializedCricketMatch initializedMatch) {
    final rules = initializedMatch.rules;
    final CricketGame game = switch (rules) {
      LimitedOversRules() => LimitedOversGame(
          rules: rules,
          team1: initializedMatch.team1,
          lineup1: initializedMatch.lineup1,
          team2: initializedMatch.team2,
          lineup2: initializedMatch.lineup2,
        ),
      UnlimitedOversRules() => UnlimitedOversGame(
          rules: rules,
          team1: initializedMatch.team1,
          lineup1: initializedMatch.lineup1,
          team2: initializedMatch.team2,
          lineup2: initializedMatch.lineup2,
        )
    };

    final match =
        OngoingCricketMatch.fromInitialized(initializedMatch, game: game);

    if (match.toss.winner == match.team1 &&
            match.toss.choice == TossChoice.bat ||
        match.toss.winner == match.team2 &&
            match.toss.choice == TossChoice.field) {
      nextInnings(
        game,
        battingTeam: match.team1,
        battingLineup: match.lineup1,
        bowlingTeam: match.team2,
        bowlingLineup: match.lineup2,
      );
    } else {
      nextInnings(
        game,
        battingTeam: match.team2,
        battingLineup: match.lineup2,
        bowlingTeam: match.team1,
        bowlingLineup: match.lineup1,
      );
    }

    _repository.commenceCricketMatch(match);

    return match;
  }

  void nextInnings(
    CricketGame game, {
    required Team battingTeam,
    required Lineup battingLineup,
    required Team bowlingTeam,
    required Lineup bowlingLineup,
  }) {
    final Innings innings = switch (game) {
      LimitedOversGame() => LimitedOversInnings(
          rules: game.rules,
          battingTeam: battingTeam,
          battingLineup: battingLineup,
          bowlingTeam: bowlingTeam,
          bowlingLineup: bowlingLineup,
        ),
      UnlimitedOversGame() => UnlimitedOversInnings(
          rules: game.rules,
          battingTeam: battingTeam,
          battingLineup: battingLineup,
          bowlingTeam: bowlingTeam,
          bowlingLineup: bowlingLineup,
        ),
    };
    game.innings.add(innings);
  }

  CricketMatchRepository get _repository =>
      RepositoryProvider().getCricketMatchRepository();
}
