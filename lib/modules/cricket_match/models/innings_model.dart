import 'dart:collection';

import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/modules/cricket_match/models/wicket_model.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/modules/team/models/team_model.dart';

/// An index which locates events on a timeline of an innings.
/// Commonly represented as `over.ball`
class InningsIndex {
  final int over;
  final int ball;

  const InningsIndex(this.over, this.ball);

  const InningsIndex.zero()
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
  /// The index of this post
  final InningsIndex index;

  /// Any comment that the user would like to add about this post
  final String? comment;

  InningsPost({required this.index, this.comment});
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
  final RetiredBowler retired;

  BowlerRetire({
    required super.index,
    required this.bowler,
    required this.retired,
  });
}

/// Posted whenever a Bowler starts a new over or completes an over that was
/// started by another bowler.
class NextBowler extends InningsPost {
  /// The bowler who bowled the previous delivery
  final Player? previous;

  /// The bowler who will bowl the next delivery
  final Player next;

  NextBowler({
    required super.index,
    super.comment,
    required this.previous,
    required this.next,
  });
}

/// Posted whenever a Batter Retires due to an injury, being sent off, or any
/// other reason.
///
/// This post should be followed by a [NextBatter] post since a new batter will
/// walk out to bat, unless the innings has ended due to this post.
class BatterRetire extends InningsPost {
  /// The batter who has retired
  final Player batter;

  /// The batter's retirement
  final RetiredBatter retired;

  BatterRetire({
    required super.index,
    super.comment,
    required this.batter,
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
    required super.index,
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

  RunoutBeforeDelivery({
    required super.index,
    super.comment,
    required this.wicket,
  });
}

/// The types of Bowling Extras
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

enum BattingExtraType { bye, legBye }

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
  final int runsScoredByBattingTeam;

  /// A wicket, if any, that fell on this ball
  final Wicket? wicket;
  bool get isWicket => wicket != null;

  /// An extra due to the bowler or fielding team's fault
  final BowlingExtra? bowlingExtra;
  bool get isBowlingExtra => bowlingExtra != null;

  /// An extra when the batters score runs without the bat touching the ball
  final BattingExtraType? battingExtraType;
  bool get isBattingExtra => battingExtraType != null;

  /// Total runs awarded to the Batting Team
  int get runs {
    // Runs due to extra, if any
    if (isBowlingExtra) {
      return runsScoredByBattingTeam + bowlingExtra!.penalty;
    }
    return runsScoredByBattingTeam;
  }

  Ball({
    required super.index,
    required this.bowler,
    required this.batter,
    required this.runsScoredByBattingTeam,
    required this.wicket,
    required this.bowlingExtra,
    required this.battingExtraType,
  });
}

/// An Innings is a major component of a game of cricket where one team scores
/// runs (batting team) while the other tries to take their wickets and prevent
/// the flow of runs (bowling/fielding team)
sealed class Innings {
  /// The lineup that will be scoring the runs by batting
  final Lineup battingLineup;

  /// The lineup that will bowl and field to take wickets and prevent runs
  final Lineup bowlingLineup;

  Innings({required this.battingLineup, required this.bowlingLineup});

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

  /// Are all wickets lost by the batting team
  // bool get isAllDown => wickets >= rules.wicketsPerSide; TODO

  // int get oversBowled {
  //   if (balls.isEmpty) return 0;
  //   return balls.last.index.over + 1;
  // }

  bool get isInningsComplete;

  /// All batters that walk out to the pitch
  List<BatterInnings> batters = [];

  /// All bowlers that roll their arms
  List<BowlerInnings> bowlers = [];

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

  bool isForfeited = false;
}

class LimitedOversInnings extends Innings {
  final LimitedOversRules _rules;
  LimitedOversInnings({
    required super.battingLineup,
    required super.bowlingLineup,
    required LimitedOversRules rules,
  }) : _rules = rules;

  // LimitedOversInnings.of(LimitedOversGame game): this(rules: game.rules, battingSquad: game.)

  @override
  LimitedOversRules get rules => _rules;

  bool get isBowlingComplete =>
      balls.isNotEmpty &&
      balls.last.index.over + 1 == rules.oversPerInnings &&
      balls.last.index.ball == rules.ballsPerOver;

  @override
  bool get isInningsComplete => isBowlingComplete;
}

class LimitedOversInningsWithTarget extends LimitedOversInnings {
  /// Runs required by the batting team to win the game
  final int target;

  LimitedOversInningsWithTarget({
    required super.battingLineup,
    required super.bowlingLineup,
    required super.rules,
    required this.target,
  });

  bool get isTargetAchieved => runs >= target;

  @override
  bool get isInningsComplete => isTargetAchieved || isBowlingComplete;
}

class UnlimitedOversInnings extends Innings {
  final UnlimitedOversRules _rules;
  UnlimitedOversInnings({
    required super.battingLineup,
    required super.bowlingLineup,
    required UnlimitedOversRules rules,
  }) : _rules = rules;

  @override
  UnlimitedOversRules get rules => _rules;

  @override
  // TODO: implement isInningsComplete
  bool get isInningsComplete => throw UnimplementedError();
}

abstract class PlayerInnings {
  final posts = <InningsPost>[];
}

class BatterInnings extends PlayerInnings with BattingCalculations {
  final Player player;
  BatterInnings(this.player);

  Wicket? wicket;
  RetiredBatter? retired;

  @override
  Iterable<Ball> get balls => posts.whereType<Ball>();

  bool get isOut => wicket != null;
  bool get isRetired => retired != null;
}

class BowlerInnings extends PlayerInnings with BowlingCalculations {
  final Player player;

  @override
  Iterable<Ball> get balls => posts.whereType<Ball>();

  @override
  final int ballsPerOver;

  BowlerInnings(this.player, {required this.ballsPerOver});
}

mixin BattingCalculations {
  Iterable<Ball> get balls;
  int get runs =>
      balls.fold(0, (runs, ball) => runs + ball.runsScoredByBattingTeam);

  int get ballCount => balls.where((ball) => ball.bowlingExtra is! Wide).length;

  double get strikeRate => 100 * runs / ballCount;
}

mixin BowlingCalculations {
  Iterable<Ball> get balls;
  int get ballsPerOver;

  int get runsConceded => balls
      .where((b) => !b.isBattingExtra)
      .fold(0, (sum, ball) => sum + ball.runs);

  int get ballCount => balls.where((b) => !b.isBowlingExtra).length;

  double get economy => runsConceded / ballCount * ballsPerOver;

  double get average => runsConceded / wicketCount;

  Iterable<Ball> get wickets =>
      balls.where((ball) => _isBowlerWicket(ball.wicket));
  int get wicketCount => wickets.length;

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
