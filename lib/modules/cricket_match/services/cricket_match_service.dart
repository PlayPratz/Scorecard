import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/modules/team/team_model.dart';

class CricketMatchService {
  static final _instance = CricketMatchService._();

  CricketMatchService._();

  factory CricketMatchService() => _instance;

  ScheduledCricketMatch createCricketMatch(
      {required Team team1, required Team team2, required GameRules rules}) {
    final match =
        ScheduledCricketMatch(team1: team1, team2: team2, rules: rules);
    return match;
  }

  InitializedCricketMatch initializeCricketMatch(
      ScheduledCricketMatch scheduledMatch,
      {required Toss toss,
      required Squad squad1,
      required Squad squad2}) {
    final match = InitializedCricketMatch.fromScheduled(scheduledMatch,
        toss: toss, squad1: squad1, squad2: squad2);
    return match;
  }

  OngoingCricketMatch commenceCricketMatch(
      InitializedCricketMatch initializedMatch) {
    late final CricketGame game;

    switch (initializedMatch.rules) {
      case LimitedOversRules():
        game = LimitedOversGame(
          rules: initializedMatch.rules as LimitedOversRules,
          squad1: initializedMatch.squad1,
          squad2: initializedMatch.squad2,
        );
      case UnlimitedOversRules():
        game = UnlimitedOversGame(
          rules: initializedMatch.rules as UnlimitedOversRules,
          squad1: initializedMatch.squad1,
          squad2: initializedMatch.squad2,
        );
    }

    final match =
        OngoingCricketMatch.fromInitialized(initializedMatch, game: game);
    return match;
  }
}
