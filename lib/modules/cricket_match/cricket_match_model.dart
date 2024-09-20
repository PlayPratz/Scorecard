import 'package:scorecard/modules/cricket_match/innings_model.dart';
import 'package:scorecard/modules/team/team_model.dart';

enum TossChoice { bat, field }

class Toss {
  final Team winner;
  final TossChoice choice;

  Toss({required this.winner, required this.choice});
}

class MatchRules {
  final int ballsPerOver;
  // final int wicketsPerInnings; TODO

  final int widePenalty;
  final int noBallPenalty;

  MatchRules(
      {required this.ballsPerOver,
      required this.widePenalty,
      required this.noBallPenalty});
}

class ScheduledCricketMatch {
  final Team team1;
  final Team team2;

  final MatchRules rules;

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
          toss: toss,
          squad1: squad1,
          squad2: squad2,
        );
}

class OngoingCricketMatch extends InitializedCricketMatch {
  final List<Innings> innings = [];
}
