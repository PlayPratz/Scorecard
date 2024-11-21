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
}

sealed class InningsPost {
  final InningsIndex index;
  final String? comments;

  InningsPost({required this.index, this.comments});
}

class NextBowler extends InningsPost {
  final Player? previous;
  final Player next;

  NextBowler({
    required super.index,
    super.comments,
    required this.previous,
    required this.next,
  });
}

class BatterRetire extends InningsPost {
  final Player batter;
  final Retired retired;

  BatterRetire({
    required super.index,
    super.comments,
    required this.batter,
    required this.retired,
  });
}

class NonStrikerRunout extends InningsPost {
  final RunoutWicket wicket;

  NonStrikerRunout({
    required super.index,
    super.comments,
    required this.wicket,
  });
}

class NextBatter extends InningsPost {
  final Player? previous;
  final Player next;

  NextBatter({
    required super.index,
    super.comments,
    required this.previous,
    required this.next,
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

  int get runs => balls.fold(0, (value, ball) => value + ball.runs);
  int get wickets => balls.where((ball) => ball.isWicket).length;

  int get oversBowled {
    if (balls.isEmpty) return 0;
    return balls.last.index.over + 1;
  }

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

  @override
  bool get isInningsComplete => oversBowled == rules.oversPerInnings;
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

class BatterInnings extends PlayerInnings with BasicCalculations {
  final Player batter;
  BatterInnings(this.batter);

  @override
  Iterable<InningsPost> get _posts => posts;

  int get ballCount =>
      balls.where((ball) => ball.bowlingExtra != BowlingExtra.wide).length;
}

class BowlerInnings extends PlayerInnings with BasicCalculations {
  final Player bowler;

  BowlerInnings(this.bowler);

  @override
  Iterable<InningsPost> get _posts => posts;

  Iterable<Ball> get wickets =>
      balls.where((ball) => isBowlerWicket(ball.wicket));
  int get wicketCount => wickets.length;

  bool isBowlerWicket(Wicket? wicket) => switch (wicket) {
        BowledWicket() ||
        HitWicket() ||
        LbwWicket() ||
        CaughtWicket() ||
        StumpedWicket() =>
          true,
        null || RunoutWicket() || TimedOutWicket() => false
      };
}

mixin BasicCalculations {
  Iterable<InningsPost> get _posts;
  Iterable<Ball> get balls => _posts.whereType<Ball>();

  int get runs => balls.fold(0, (runs, ball) => runs + ball.runs);
}
