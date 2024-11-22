import 'dart:collection';

import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/modules/cricket_match/models/wicket_model.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/modules/team/models/team_model.dart';

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

sealed class InningsPost {
  final InningsIndex index;
  final String? comment;

  InningsPost({required this.index, this.comment});
}

class BowlerRetire extends InningsPost {
  final Player bowler;
  final RetiredBowler retired;

  BowlerRetire({
    required super.index,
    required this.bowler,
    required this.retired,
  });
}

class NextBowler extends InningsPost {
  final Player? previous;
  final Player next;

  NextBowler({
    required super.index,
    super.comment,
    required this.previous,
    required this.next,
  });
}

class BatterRetire extends InningsPost {
  final Player batter;
  final RetiredBatter retired;

  BatterRetire({
    required super.index,
    super.comment,
    required this.batter,
    required this.retired,
  });
}

class NextBatter extends InningsPost {
  final Player? previous;
  final Player next;

  NextBatter({
    required super.index,
    super.comment,
    required this.previous,
    required this.next,
  });
}

class RunoutBeforeDelivery extends InningsPost {
  final RunoutWicket wicket;

  RunoutBeforeDelivery({
    required super.index,
    super.comment,
    required this.wicket,
  });
}

enum BowlingExtra { noBall, wide }

enum BattingExtra { bye, legBye }

class Ball extends InningsPost {
  final Player bowler;
  final Player batter;

  final int runsScored;

  final Wicket? wicket;
  bool get isWicket => wicket != null;

  final BowlingExtra? bowlingExtra;
  bool get isBowlingExtra => bowlingExtra != null;

  final BattingExtra? battingExtra;
  bool get isBattingExtra => battingExtra != null;

  int get runs => runsScored; // TODO URGENT include Extra Runs

  Ball({
    required super.index,
    required this.bowler,
    required this.batter,
    required this.runsScored,
    required this.wicket,
    required this.bowlingExtra,
    required this.battingExtra,
  });
}

sealed class Innings {
  final Lineup battingLineup;
  final Lineup bowlingLineup;

  Innings({required this.battingLineup, required this.bowlingLineup});

  GameRules get rules;

  List<InningsPost> posts = [];

  UnmodifiableListView<Ball> get balls =>
      UnmodifiableListView(posts.whereType<Ball>());

  /// Total runs awarded to the batting team
  int get runs => balls.fold(0, (value, ball) => value + ball.runs);

  /// Total wickets taken by the bowling team
  int get wickets => balls.where((ball) => ball.isWicket).length;

  /// Are all wickets lost by the batting team
  // bool get isAllDown => wickets >= rules.wicketsPerSide; TODO

  // int get oversBowled {
  //   if (balls.isEmpty) return 0;
  //   return balls.last.index.over + 1;
  // }

  bool get isInningsComplete;

  List<BatterInnings> batters = [];
  List<BowlerInnings> bowlers = [];

  BatterInnings? batter1;
  BatterInnings? batter2;
  BatterInnings? striker;
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
  Iterable<InningsPost> get _posts => posts;

  int get ballCount =>
      balls.where((ball) => ball.bowlingExtra != BowlingExtra.wide).length;

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
  Iterable<InningsPost> get _posts;
  Iterable<Ball> get balls => _posts.whereType<Ball>();
  int get runs => balls.fold(0, (runs, ball) => runs + ball.runs);
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
