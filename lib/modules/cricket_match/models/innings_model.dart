import 'dart:collection';
import 'dart:math';

import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/modules/cricket_match/models/wicket_model.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/modules/team/models/team_model.dart';

/// An index which locates events on a timeline of an innings.
/// Commonly represented as `over.ball`
class PostIndex {
  final int over;
  final int ball;

  const PostIndex(this.over, this.ball);

  const PostIndex.zero()
      : over = 0,
        ball = 0;

  @override
  String toString() => "$over.$ball";
}

/// Represents an event that occurs during the progression of an innings.
/// The most common post is [Ball].
///
/// I really thought hard but could not come up with a name better than "Post".
/// It made sense because you are *posting* every event to this innings. I did
/// not want to name this InningsEvent because that sounds like a UI Event.
sealed class InningsPost {
  /// The unique identifier of this Post
  int? id; // TODO This is not final

  /// The index of this post in the innings
  final PostIndex index;

  /// Any comment that the user would like to add about this post
  final String? comment;

  /// The timestamp of this post
  final DateTime timestamp;

  InningsPost({
    this.id,
    required this.index,
    DateTime? timestamp,
    this.comment,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// A ball is the most major event in a game of cricket.
///
/// A bowler delivers the ball to a batter who then attempts to get bat on ball
/// and score runs.
class Ball extends InningsPost {
  /// The bowler who delivered this ball
  final Player bowler;

  /// The batter who faced this ball
  final Player batter;

  /// Runs off the bat/ran by the batter(s)
  final int runsScoredByBatter;

  /// A wicket, if any, that fell on this ball
  final Wicket? wicket;
  bool get isWicket => wicket != null;

  /// An extra due to the bowler or fielding team's fault
  final BowlingExtra? bowlingExtra;
  bool get isBowlingExtra => bowlingExtra != null;
  int get bowlingExtraRuns => bowlingExtra != null ? bowlingExtra!.penalty : 0;

  /// An extra when the batters score runs without the bat touching the ball
  final BattingExtra? battingExtra; // TODO Make this like BowlingExtra
  bool get isBattingExtra => battingExtra != null;
  int get battingExtraRuns => battingExtra != null ? battingExtra!.runs : 0;

  /// Total runs awarded to the Batting Team
  int get runs => runsScoredByBatter + bowlingExtraRuns + battingExtraRuns;

  Ball({
    super.id,
    required super.index,
    super.timestamp,
    super.comment,
    required this.bowler,
    required this.batter,
    required this.runsScoredByBatter,
    required this.wicket,
    required this.bowlingExtra,
    required this.battingExtra,
  });
}

/// Posted when a Bowler Retires mid-over due to an injury, being sent off, or
/// any other reason.
///
/// This post should be followed by a [NextBowler] post since another bowler
/// will have to complete the remainder of the over.
///
/// Note: Not to be posted when an over is completed.
class BowlerRetire extends InningsPost {
  /// The bowler who retires
  final Player bowler;

  /// The bowler's retirement
  // final RetiredBowler retired;

  BowlerRetire({
    super.id,
    required super.index,
    super.timestamp,
    super.comment,
    required this.bowler,
    // required this.retired,
  });
}

/// Posted whenever a Bowler starts a new over or completes an over that was
/// started by another bowler.
class NextBowler extends InningsPost {
  /// The bowler who bowled the previous delivery
  final Player? previous;

  /// The bowler who will bowl the next delivery
  final Player next;

  // final bool isMidOverChange;

  NextBowler({
    super.id,
    required super.index,
    super.timestamp,
    super.comment,
    required this.previous,
    required this.next,
    // required this.isMidOverChange
  });
}

/// Posted whenever a Batter Retires due to an injury, being sent off, or any
/// other reason.
///
/// This post should be followed by a [NextBatter] post since a new batter will
/// walk out to bat, unless the innings has ended due to this post.
class BatterRetire extends InningsPost {
  /// The batter's retirement
  final Retired retired;

  /// The batter who has retired
  Player get batter => retired.batter;

  BatterRetire({
    super.id,
    required super.index,
    super.timestamp,
    super.comment,
    // required this.batter,
    required this.retired,
  });
}

/// Posted whenever a New Batter walks out to bat.
class NextBatter extends InningsPost {
  /// The batter that was batting previously
  final Player? previous;

  /// The batter that has walked out to bat
  final Player next;

  NextBatter({
    super.id,
    required super.index,
    super.timestamp,
    super.comment,
    required this.previous,
    required this.next,
  });
}

/// Posted whenever a batter is run out before a delivery is bowled by the
/// bowler.
///
/// This is to be used for run out at the non-striker's end before the ball is
/// bowled, as sensationalized by Ravichandran Ashwin
class RunoutBeforeDelivery extends InningsPost {
  /// The run out that took place before the ball was bowled
  final RunoutWicket wicket;

  Player get batter => wicket.batter;

  RunoutBeforeDelivery({
    super.id,
    required super.index,
    super.timestamp,
    super.comment,
    required this.wicket,
  });
}

/// A simple container that conveniently packages the score of an innings.
class Score {
  final int runs;
  final int wickets;

  Score(this.runs, this.wickets);

  Score.zero()
      : runs = 0,
        wickets = 0;

  Score plus(Ball ball) {
    final runs = this.runs + ball.runs;
    if (ball.isWicket) {
      return Score(runs, wickets + 1);
    } else {
      return Score(runs, wickets);
    }
  }
}

/// Types of Bowling Extras
enum BowlingExtraType { noBall, wide }

/// A Bowling Extra is an extra due to the bowler's or the fielding team's
/// fault.
///
/// Due to a Bowling Extra, the batting team is awarded some extra runs in
/// their innings, usually one.
sealed class BowlingExtra {
  /// The amount of additional runs awarded to the Batting Team
  final int penalty;

  /// The type of Bowling Extra
  BowlingExtraType get type;

  BowlingExtra(this.penalty);
}

class NoBall extends BowlingExtra {
  NoBall(super.penalty);

  @override
  BowlingExtraType get type => BowlingExtraType.noBall;
}

class Wide extends BowlingExtra {
  Wide(super.penalty);

  @override
  BowlingExtraType get type => BowlingExtraType.wide;
}

/// Types of Batting Extras
enum BattingExtraType { bye, legBye }

/// A Batting Extra is an extra due to the striking batter's fault.
///
/// In case of a Batting Extra, the batting team is still awarded the runs, but
/// it's not accounted for in the batter's or the bowler's innings.
sealed class BattingExtra {
  /// Extra runs scored by the batting team
  final int runs;

  BattingExtraType get type;

  BattingExtra(this.runs);
}

/// A Batting Extra where the batters score runs after the striker get neither
/// bat nor body on ball.
class Bye extends BattingExtra {
  Bye(super.runs);

  @override
  BattingExtraType get type => BattingExtraType.bye;
}

/// A Batting Extra where the batters score runs after the striker gets body,
/// but not bat, on ball.
class LegBye extends BattingExtra {
  LegBye(super.runs);

  @override
  BattingExtraType get type => BattingExtraType.legBye;
}

/// An Innings is a major component of a game of cricket where one team scores
/// runs (batting team) while the other tries to take their wickets and prevent
/// the flow of runs (bowling/fielding team)
sealed class Innings {
  /// The unique identifier of the match in which this innings takes place
  final String matchId;

  /// The ordinal number of the innings in the Cricket Game
  final int inningsNumber;

  /// The team that will be scoring the runs by batting
  final Team battingTeam;
  final Lineup battingLineup;

  /// The team that will bowl and field to take wickets and prevent runs
  final Team bowlingTeam;
  final Lineup bowlingLineup;

  /// The game that this Innings is a part of
  // final CricketGame game;

  Innings({
    required this.matchId,
    required this.inningsNumber,
    required this.battingTeam,
    required this.battingLineup,
    required this.bowlingTeam,
    required this.bowlingLineup,
  }) : target = null;

  Innings.target({
    required this.matchId,
    required this.inningsNumber,
    required this.battingTeam,
    required this.battingLineup,
    required this.bowlingTeam,
    required this.bowlingLineup,
    required this.target,
  });

  /// A set of rules that determines how this innings will proceed
  GameRules get rules;

  /// List of posts that happen throughout
  List<InningsPost> posts = [];

  UnmodifiableListView<Ball> get balls =>
      UnmodifiableListView(posts.whereType<Ball>());

  /// Total runs awarded to the batting team
  int get runs => balls.fold(0, (value, ball) => value + ball.runs);

  /// Total wickets taken by the bowling team
  int get wickets => wicketBalls.length;
  Iterable<Ball> get wicketBalls => balls.where((ball) => ball.isWicket);

  /// All batters that walk out to the pitch
  ///
  /// Since a player can bat only once in an innings, a map is used.
  /// The given literal produces a [LinkedHashMap], so insertion order is
  /// preserved.
  Map<Player, BatterInnings> batters = {};

  /// All bowlers that roll their arms
  Map<Player, BowlerInnings> bowlers = {};

  /// A batter who is on the pitch
  BatterInnings? batter1;

  /// A batter who is on the pitch
  BatterInnings? batter2;

  /// The batter who is on strike, facing the upcoming delivery.
  ///
  /// Must be either [batter1] or [batter2]
  BatterInnings? striker;

  /// The batter who is on the pitch but not on strike, i.e. at the
  /// non-striker's end.
  ///
  /// Must be either [batter1] or [batter2]
  BatterInnings? get nonStriker => batter1 == striker ? batter2 : batter1;

  /// The bowler who is bowling the current over
  BowlerInnings? bowler;

  bool get isComplete;
  bool isForfeited = false;
  bool isDeclared = false;

  bool get isEnded => isComplete || isForfeited || isDeclared;

  int? target;
  bool get hasTarget => target != null;
  bool get isTargetAchieved => hasTarget && runs >= target!;

  Score get score => calculateScore();

  Score calculateScore({Ball? from, Ball? at}) {
    if (balls.isEmpty) {
      return Score.zero();
    }

    from ??= balls.first;
    at ??= balls.last;

    final start = balls.indexOf(from);
    final end = balls.indexOf(at, start) + 1;

    final score = balls
        .getRange(start, end)
        .fold(Score.zero(), (prevScore, ball) => prevScore.plus(ball));

    return score;
  }

  // List<Partnership> get partnerships {
  //   if (rules.onlySingleBatter) return [];
  //
  //   final batters = this.batters.values.toList();
  //
  //   List<Partnership> partnerships = [
  //     Partnership(batter1: batters[0].player, batter2: batters[1].player),
  //   ];
  //   for (final post in posts) {
  //     if (post is Ball && (post.isWicket)) {}
  //   }
  // }

  Map<int, Iterable<InningsPost>> get overs {
    if (posts.isEmpty) return {};

    final map = <int, List<InningsPost>>{};
    for (final post in posts) {
      final overIndex = post.index.over + 1;
      if (!map.containsKey(overIndex)) {
        map[overIndex] = [];
      }
      map[overIndex]!.add(post);
    }

    return map;
  }
}

class UnlimitedOversInnings extends Innings {
  final UnlimitedOversRules _rules;
  UnlimitedOversInnings({
    required super.matchId,
    required super.inningsNumber,
    required super.battingTeam,
    required super.battingLineup,
    required super.bowlingTeam,
    required super.bowlingLineup,
    required UnlimitedOversRules rules,
  }) : _rules = rules;

  @override
  UnlimitedOversRules get rules => _rules;

  @override
  // TODO: implement isInningsComplete
  bool get isComplete => throw UnimplementedError();
}

class LimitedOversInnings extends Innings {
  final LimitedOversRules _rules;
  LimitedOversInnings({
    required super.matchId,
    required super.inningsNumber,
    required super.battingTeam,
    required super.battingLineup,
    required super.bowlingTeam,
    required super.bowlingLineup,
    required LimitedOversRules rules,
  }) : _rules = rules;

  // LimitedOversInnings.of(LimitedOversGame game): this(rules: game.rules, battingSquad: game.)

  @override
  LimitedOversRules get rules => _rules;

  int get ballsBowled => balls.where((ball) => !ball.isBowlingExtra).length;
  int get ballsToBeBowled => rules.oversPerInnings * rules.ballsPerOver;
  int get ballsLeft => max(ballsToBeBowled - ballsBowled, 0);

  bool get isBowlingComplete => ballsLeft == 0;

  @override
  bool get isComplete => isTargetAchieved || isBowlingComplete;
}

abstract class PlayerInnings {
  final posts = <InningsPost>[];
}

class BowlerInnings extends PlayerInnings with BowlingCalculations {
  final Player player;

  @override
  Iterable<Ball> get balls => posts.whereType<Ball>();

  @override
  final int ballsPerOver;

  BowlerInnings(this.player, {required this.ballsPerOver});
}

class BatterInnings extends PlayerInnings with BattingCalculations {
  final Player player;
  BatterInnings(this.player);

  Wicket? wicket;
  Retired? retired;

  @override
  Iterable<Ball> get balls => posts.whereType<Ball>();

  bool get isOut => wicket != null;
  bool get isRetired => retired != null;
}

class BatterScore {
  final int runsScored;
  final int ballsFaced;

  BatterScore(this.runsScored, this.ballsFaced);
}

class Partnership {
  final Player batter1;
  final Player batter2;

  Partnership({required this.batter1, required this.batter2});

  BatterScore get batter1Contribution => _getBatterScore(batter1);
  BatterScore get batter2Contribution => _getBatterScore(batter2);

  BatterScore _getBatterScore(Player batter) {
    return calculateBatterScore(balls.where((b) => b.batter == batter));
  }

  List<InningsPost> posts = [];
  UnmodifiableListView<Ball> get balls =>
      UnmodifiableListView(posts.whereType<Ball>());
}

// TODO Move to a better place
BatterScore calculateBatterScore(Iterable<Ball> balls) {
  final int runsScored =
      balls.fold(0, (runs, ball) => runs + ball.runsScoredByBatter);
  final int ballsFaced =
      balls.where((ball) => ball.bowlingExtra is! Wide).length;
  return BatterScore(runsScored, ballsFaced);
}

mixin BattingCalculations {
  Iterable<Ball> get balls;

  int get runsScored =>
      balls.fold(0, (runs, ball) => runs + ball.runsScoredByBatter);

  int get ballsFaced =>
      balls.where((ball) => ball.bowlingExtra is! Wide).length;

  BatterScore get batterScore => BatterScore(runsScored, ballsFaced);

  double get strikeRate => 100 * runsScored / ballsFaced;
}

mixin BowlingCalculations {
  Iterable<Ball> get balls;
  int get ballsPerOver;

  int get runsConceded => balls.fold(
      0, (sum, ball) => sum + ball.runsScoredByBatter + ball.bowlingExtraRuns);

  int get ballsBowled => balls.where((b) => !b.isBowlingExtra).length;

  int get maidensBowled => -1; //TODO

  double get economy => runsConceded / ballsBowled * ballsPerOver;
  double get average => runsConceded / wicketsTaken;
  double get strikeRate => ballsBowled / wicketsTaken;

  Iterable<Ball> get wickets =>
      balls.where((ball) => _isBowlerWicket(ball.wicket));
  int get wicketsTaken => wickets.length;

  bool _isBowlerWicket(Wicket? wicket) => switch (wicket) {
        BowledWicket() ||
        HitWicket() ||
        LbwWicket() ||
        CaughtWicket() ||
        StumpedWicket() =>
          true,
        null || RunoutWicket() || TimedOutWicket() => false
      };
}
