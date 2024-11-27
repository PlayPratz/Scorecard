import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/modules/team/models/team_model.dart';
import 'package:scorecard/modules/venue/models/venue_model.dart';

/// A [CricketMatch] is divided into various stages. This class is the super
/// class which must never be instantiated. It serves as a common parent for
/// every other stage.
abstract class CricketMatch {
  final String id;

  CricketMatch({required this.id});
}

/// A [CricketMatch] is said to be *scheduled* when a match has been set up
/// between two teams at a given datetime and venue, but the lineups are not yet
/// revealed.
///
/// For example, an India v Australia T20 match is scheduled at Darren Sammy
/// Cricket Ground on 24 June 2024. We don't know the playing eleven yet.
class ScheduledCricketMatch extends CricketMatch {
  /// The first team that will be playing the match. Usually represents the
  /// Home team, but not in case of a tournament/friendly turf match.
  final Team team1;

  /// The second team that will be playing the match against the first. Usually
  /// represents the Away team.
  final Team team2;

  /// The stadium, ground or turf at which the match is to be played.
  final Venue venue;

  /// The format and rules that will be followed for this match.
  final GameRules rules;

  /// The date and time at which play will commence.
  final DateTime startsAt;

  ScheduledCricketMatch({
    required super.id,
    required this.team1,
    required this.team2,
    required this.startsAt,
    required this.venue,
    required this.rules,
  });
}

/// A [CricketMatch] is set to be *initialized* once the [Toss] is completed and
/// both the playing eleven of both sides are revealed.
///
/// Continuing the previous example, Mitch Marsh won the toss and chose to
/// field. Rohit Sharma and he revealed their respective lineups.
class InitializedCricketMatch extends ScheduledCricketMatch {
  /// The toss that takes place right before the match/
  final Toss toss;

  /// The first team's lineup
  final Lineup lineup1;

  /// The second team's lineup
  final Lineup lineup2;

  InitializedCricketMatch({
    required super.id,
    required super.team1,
    required super.team2,
    required super.startsAt,
    required super.venue,
    required super.rules,
    required this.toss,
    required this.lineup1,
    required this.lineup2,
  });

  InitializedCricketMatch.fromScheduled(
    ScheduledCricketMatch match, {
    required Toss toss,
    required Lineup lineup1,
    required Lineup lineup2,
  }) : this(
          id: match.id,
          team1: match.team1,
          team2: match.team2,
          startsAt: match.startsAt,
          venue: match.venue,
          rules: match.rules,
          lineup1: lineup1,
          lineup2: lineup2,
          toss: toss,
        );
}

/// Once a match commences, it is said to be *ongoing* until it's completed.
///
/// Continuing our example, as long as Rohit Sharma smacks Starc or Bumrah
/// contains Head, it's an ongoing match. No, I'm not salty about 19 Nov 2023!
class OngoingCricketMatch extends InitializedCricketMatch {
  /// The game that is played between the two teams, as it happens.
  final CricketGame game;

  OngoingCricketMatch({
    required super.id,
    required super.team1,
    required super.team2,
    required super.startsAt,
    required super.venue,
    required super.rules,
    required super.toss,
    required super.lineup1,
    required super.lineup2,
    required this.game,
  });

  OngoingCricketMatch.fromInitialized(
    InitializedCricketMatch match, {
    required CricketGame game,
  }) : this(
          id: match.id,
          team1: match.team1,
          team2: match.team2,
          startsAt: match.startsAt,
          venue: match.venue,
          rules: match.rules,
          toss: match.toss,
          lineup1: match.lineup1,
          lineup2: match.lineup2,
          game: game,
        );
}

/// Once we have a result, or the match gets cancelled due to rain or any other
/// reason, the match is said to be *completed*.
///
/// This is when the scorecard reads *India won by 24 runs* :-).
///
/// (19 Nov still hurts).
class CompletedCricketMatch extends OngoingCricketMatch {
  final CricketMatchResult result;
  final Player? playerOfTheMatch;

  CompletedCricketMatch({
    required super.id,
    required super.team1,
    required super.team2,
    required super.startsAt,
    required super.venue,
    required super.rules,
    required super.toss,
    required super.lineup1,
    required super.lineup2,
    required super.game,
    required this.result,
    required this.playerOfTheMatch,
  });
}

enum TossChoice { bat, field }

/// Represents the toss that takes place right before play commences.
class Toss {
  /// The team, or captain, that wins the toss.
  final Team winner;

  /// The choice made by the winning side.
  final TossChoice choice;

  Toss({required this.winner, required this.choice});
}

sealed class CricketMatchResult {}

sealed class UnlimitedOversMatchResult extends CricketMatchResult {}

sealed class LimitedOversMatchResult extends CricketMatchResult {}

class WinByChasingResult extends LimitedOversMatchResult {
  final Team winner;
  final Team loser;

  // final int wicketsMargin; TODO
  final int ballsToSpare;

  WinByChasingResult(
      {required this.winner, required this.loser, required this.ballsToSpare});
}

class WinByDefendingResult extends LimitedOversMatchResult {
  final Team winner;
  final Team loser;

  final int runsMargin;

  WinByDefendingResult(
      {required this.winner, required this.loser, required this.runsMargin});
}

class TieResult extends LimitedOversMatchResult {
  final Team team1;
  final Team team2;

  TieResult({required this.team1, required this.team2});
}

/// This might be confusing -- what's the difference between a [CricketMatch]
/// and a [CricketGame]?
///
/// A [CricketMatch] is all about the "match up", the "big event" and not about
/// the actual, ball-by-ball progression of the game. The latter is what
/// [CricketGame] handles.
///
/// Once a match becomes an [OngoingCricketMatch], it contains a `game` object
/// that represents the ball-by-ball, moment-by-moment progression of a
/// Cricket Match.
///
/// The idea is that [CricketMatch] doesn't really have anything to do with
/// Cricket, it's more of a Match between two teams. They could technically
/// play any sport. The name might be misleading for now, but if this app
/// expands and starts to cater to multiple sports, it might make more sense.
sealed class CricketGame {
  final Team team1;
  final Lineup lineup1;

  final Team team2;
  final Lineup lineup2;

  GameRules get rules;

  List<Innings> get innings;
  Innings get currentInnings => innings.last;

  // int get team1runs => _getTeamRuns(lineup1.team);
  // int get team2runs => _getTeamRuns(lineup2.team);
  //
  // int _getTeamRuns(Team team) {
  //   return innings.fold(0, (value, innings) {
  //     if (innings.battingTeam.team == team) {
  //       return value + innings.runs;
  //     } else {
  //       return value;
  //     }
  //   });
  // }

  CricketGame({
    required this.team1,
    required this.lineup1,
    required this.team2,
    required this.lineup2,
  });
}

/// Represents an Unlimited Overs game where both teams play across a
/// pre-defined number of days before the match is called a draw unless one
/// team manages to win.
class UnlimitedOversGame extends CricketGame {
  final UnlimitedOversRules _rules;
  @override
  UnlimitedOversRules get rules => _rules;

  @override
  List<UnlimitedOversInnings> innings = [];

  UnlimitedOversGame({
    required super.team1,
    required super.lineup1,
    required super.team2,
    required super.lineup2,
    required UnlimitedOversRules rules,
  }) : _rules = rules;
}

/// Represents a Limited Overs game where each team bowls a pre-defined number
/// of overs before an Innings comes to an end assuming they do not take
/// all wickets.
///
/// Examples: T20, ODI
class LimitedOversGame extends CricketGame {
  final LimitedOversRules _rules;
  @override
  LimitedOversRules get rules => _rules;

  @override
  final List<LimitedOversInnings> innings = [];

  @override
  LimitedOversInnings get currentInnings => innings.last;

  LimitedOversGame({
    required super.team1,
    required super.lineup1,
    required super.team2,
    required super.lineup2,
    required LimitedOversRules rules,
  }) : _rules = rules;
}
