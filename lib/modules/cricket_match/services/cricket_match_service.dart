import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/modules/repository/service/repostiory_service.dart';
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
      ScheduledCricketMatch scheduledMatch,
      {required Toss toss,
      required Lineup squad1,
      required Lineup squad2}) {
    final match = InitializedCricketMatch.fromScheduled(scheduledMatch,
        toss: toss, squad1: squad1, squad2: squad2);

    // Update match in repository
    _repository.update(match);

    return match;
  }

  OngoingCricketMatch commenceCricketMatch(
      InitializedCricketMatch initializedMatch) {
    late final CricketGame game;
    final rules = initializedMatch.rules;
    switch (rules) {
      case LimitedOversRules():
        game = LimitedOversGame(
          rules: rules,
          lineup1: initializedMatch.lineup1,
          lineup2: initializedMatch.lineup2,
        );
      case UnlimitedOversRules():
        game = UnlimitedOversGame(
          rules: rules,
          lineup1: initializedMatch.lineup1,
          lineup2: initializedMatch.lineup2,
        );
    }

    final match =
        OngoingCricketMatch.fromInitialized(initializedMatch, game: game);
    return match;
  }

  IRepository<CricketMatch> get _repository =>
      RepositoryService().getCricketMatchRepository();
}
