import 'dart:collection';

import 'package:scorecard/modules/cricket_match/wicket_model.dart';
import 'package:scorecard/modules/player/player_model.dart';

class InningsIndex {
  final int over;
  final int ball;

  const InningsIndex(this.over, this.ball);
}

sealed class InningsEvent {
  final InningsIndex index;
  final String? comments;

  InningsEvent({required this.index, this.comments});
}

class NextBowler extends InningsEvent {
  final Player? previous;
  final Player next;

  NextBowler({
    required super.index,
    super.comments,
    required this.previous,
    required this.next,
  });
}

class BatterRetire extends InningsEvent {
  final Player batter;
  final Retired retired;

  BatterRetire({
    required super.index,
    super.comments,
    required this.batter,
    required this.retired,
  });
}

class NonStrikerRunout extends InningsEvent {
  final Player batter;
  final RunoutWicket wicket;

  NonStrikerRunout({
    required super.index,
    super.comments,
    required this.batter,
    required this.wicket,
  });
}

class NextBatter extends InningsEvent {
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

class Ball extends InningsEvent {
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

class Innings {
  List<InningsEvent> events = [];

  UnmodifiableListView<Ball> get balls =>
      UnmodifiableListView(events.whereType<Ball>());

  int get runs => balls.fold(0, (value, ball) => value + ball.runs);
  int get wickets => balls.where((ball) => ball.isWicket).length;

  List<BatterInnings> batters = [];
  List<BowlerInnings> bowlers = [];
}

class BatterInnings {}

class BowlerInnings {}
