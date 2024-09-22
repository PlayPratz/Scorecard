import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/team/team_model.dart';

abstract class CricketMatch {}

class ScheduledCricketMatch extends CricketMatch {
  final Team team1;
  final Team team2;

  final GameRules rules;

  ScheduledCricketMatch(
      {required this.team1, required this.team2, required this.rules});
}

class InitializedCricketMatch extends ScheduledCricketMatch {
  final Toss toss;

  final Squad squad1;
  final Squad squad2;

  InitializedCricketMatch({
    required super.team1,
    required super.team2,
    required super.rules,
    required this.toss,
    required this.squad1,
    required this.squad2,
  });

  InitializedCricketMatch.fromScheduled(
    ScheduledCricketMatch match, {
    required Toss toss,
    required Squad squad1,
    required Squad squad2,
  }) : this(
          team1: match.team1,
          team2: match.team2,
          rules: match.rules,
          toss: toss,
          squad1: squad1,
          squad2: squad2,
        );
}

class OngoingCricketMatch extends InitializedCricketMatch {
  final List<Innings> innings = [];

  final CricketGame game;

  OngoingCricketMatch({
    required super.team1,
    required super.team2,
    required super.rules,
    required super.toss,
    required super.squad1,
    required super.squad2,
    required this.game,
  });

  OngoingCricketMatch.fromInitialized(
    InitializedCricketMatch match, {
    required CricketGame game,
  }) : this(
          team1: match.team1,
          team2: match.team2,
          rules: match.rules,
          toss: match.toss,
          squad1: match.squad1,
          squad2: match.squad2,
          game: game,
        );
}

class CompletedCricketMatch extends OngoingCricketMatch {
  CompletedCricketMatch(
      {required super.team1,
      required super.team2,
      required super.rules,
      required super.toss,
      required super.squad1,
      required super.squad2,
      required super.game});
  // final MatchResult result;
  //
  // CompletedCricketMatch() {
  //   result
  // }
}

class MatchResult {}

sealed class CricketGame {
  final Squad squad1;
  final Squad squad2;

  GameRules get rules;

  final List<Innings> innings = [];

  int get team1runs => _getTeamRuns(squad1.team);
  int get team2runs => _getTeamRuns(squad2.team);

  int _getTeamRuns(Team team) {
    return innings.fold(0, (value, innings) {
      if (innings.battingSquad.team == team) {
        return value + innings.runs;
      } else {
        return value;
      }
    });
  }

  CricketGame({required this.squad1, required this.squad2});
}

enum TossChoice { bat, field }

class Toss {
  final Team winner;
  final TossChoice choice;

  Toss({required this.winner, required this.choice});
}

class LimitedOversGame extends CricketGame {
  final LimitedOversRules _rules;
  @override
  LimitedOversRules get rules => _rules;

  LimitedOversGame({
    required super.squad1,
    required super.squad2,
    required LimitedOversRules rules,
  }) : _rules = rules;
}

class UnlimitedOversGame extends CricketGame {
  final UnlimitedOversRules _rules;
  @override
  UnlimitedOversRules get rules => _rules;

  UnlimitedOversGame({
    required super.squad1,
    required super.squad2,
    required UnlimitedOversRules rules,
  }) : _rules = rules;
}
