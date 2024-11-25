import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/repository/service/repository_service.dart';
import 'package:scorecard/modules/team/models/team_model.dart';
import 'package:scorecard/modules/venue/models/venue_model.dart';
import 'package:scorecard/repositories/generic_repository.dart';
import 'package:scorecard/util/ulid.dart';

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
      datetime: DateTime.now(),
      venue: venue,
      rules: rules,
    );

    // Add match to repository
    _repository.create(match);

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
    _repository.update(match);

    return match;
  }

  OngoingCricketMatch commenceCricketMatch(
      InitializedCricketMatch initializedMatch) {
    final rules = initializedMatch.rules;
    final CricketGame game = switch (rules) {
      LimitedOversRules() => LimitedOversGame(
          rules: rules,
          lineup1: initializedMatch.lineup1,
          lineup2: initializedMatch.lineup2,
        ),
      UnlimitedOversRules() => UnlimitedOversGame(
          rules: rules,
          lineup1: initializedMatch.lineup1,
          lineup2: initializedMatch.lineup2,
        )
    };

    final match =
        OngoingCricketMatch.fromInitialized(initializedMatch, game: game);

    if (match.toss.winner == match.lineup1.team &&
            match.toss.choice == TossChoice.bat ||
        match.toss.winner == match.lineup2.team &&
            match.toss.choice == TossChoice.field) {
      nextInnings(game,
          battingLineup: match.lineup1, bowlingLineup: match.lineup2);
    } else {
      nextInnings(game,
          battingLineup: match.lineup2, bowlingLineup: match.lineup1);
    }

    return match;
  }

  void nextInnings(
    CricketGame game, {
    required Lineup battingLineup,
    required Lineup bowlingLineup,
  }) {
    final Innings innings = switch (game) {
      LimitedOversGame() => LimitedOversInnings(
          rules: game.rules,
          battingLineup: battingLineup,
          bowlingLineup: bowlingLineup,
        ),
      UnlimitedOversGame() => UnlimitedOversInnings(
          rules: game.rules,
          battingLineup: battingLineup,
          bowlingLineup: bowlingLineup,
        ),
    };
    game.innings.add(innings);
  }

  IRepository<CricketMatch> get _repository =>
      RepositoryService().getCricketMatchRepository();
}
