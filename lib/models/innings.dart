import 'dart:math';

import 'package:scorecard/models/statistics.dart';
import 'package:scorecard/models/wicket.dart';

import 'player.dart';
import '../util/constants.dart';

import 'ball.dart';
import 'team.dart';

class Innings {
  final Team battingTeam;
  final Team bowlingTeam;

  int? target;
  final int maxOvers;

  Innings({
    required this.battingTeam,
    required this.bowlingTeam,
    required this.maxOvers,
    // this.bowlerInnings = const [],
  }) : target = null;

  Innings.target({
    required this.battingTeam,
    required this.bowlingTeam,
    required this.target,
    required this.maxOvers,
    // this.bowlerInnings = const [],
  });

  final List<Ball> balls = [];

  // OPERATIONS

  void playBall(Ball ball) {
    balls.add(ball);
  }

  Ball? unPlayBall() {
    if (balls.isEmpty) {
      return null;
    }
    final ball = balls.removeLast();
    return ball;
  }

  bool get isInitialized => batterInnings.isNotEmpty;
  // && bowlerInnings.isNotEmpty; TODO

  // Score

  int get runs => balls.fold(0, (runs, ball) => runs + ball.totalRuns);
  int get wickets => balls.where((ball) => ball.isWicket).length;
  int get ballsBowled => balls.where((ball) => ball.isLegal).length;
  bool get areOversCompleted =>
      maxOvers * Constants.ballsPerOver == ballsBowled;

  // Calculations

  double get currentRunRate =>
      ballsBowled == 0 ? 0 : (runs / ballsBowled) * Constants.ballsPerOver;
  int get projectedRuns => (currentRunRate * maxOvers).floor();
  int get requiredRuns => target != null ? max(0, (target! - runs)) : 0;
  int get ballsLeft => maxOvers * Constants.ballsPerOver - ballsBowled;
  double get requiredRunRate =>
      target != null ? (requiredRuns / ballsLeft) * Constants.ballsPerOver : 0;

  // Bowler

  // final List<BowlerInnings> bowlerInnings;
  final Map<Player, BowlerInnings> bowlerInnings = {};
  List<BowlerInnings> get bowlerInningsList => bowlerInnings.values.toList();

  BowlerInnings addBowler(Player bowler) {
    final bowlInn = BowlerInnings(bowler, innings: this);
    bowlerInnings[bowler] = bowlInn; //TODO Check containsKey?
    return bowlInn;
  }

  BowlerInnings? getBowlerInnings(Player bowler) {
    return bowlerInnings[bowler];
  }

  void removeBowler(BowlerInnings bowlInn) {
    bowlerInnings.remove(bowlInn);
  }

  // Iterable<BowlerInnings> get bowlerInnings {
  //   final Map<Player, BowlerInnings> bowlerInningsMap = {};
  //
  //   for (final ball in balls) {
  //     if (bowlerInningsMap.containsKey(ball.bowler)) {
  //       bowlerInningsMap[ball.bowler]!.balls.add(ball);
  //     } else {
  //       bowlerInningsMap[ball.bowler] =
  //           BowlerInnings(ball.bowler, innings: this);
  //     }
  //   }
  //
  //   return bowlerInningsMap.values;
  // }

  // Batter

  // final List<BatterInnings> batterInnings = [];
  final Map<Player, BatterInnings> batterInnings = {};
  List<BatterInnings> get batterInningsList => batterInnings.values.toList();

  Iterable<BatterInnings> get battersOnPitch =>
      batterInnings.values.where((batInn) => !batInn.isOut).take(2);

  BatterInnings addBatter(Player batter) {
    final batInn = BatterInnings(batter, innings: this);
    batterInnings[batter] = batInn; //TODO check containsKey?
    return batInn;
  }

  BatterInnings? getBatterInnings(Player batter) {
    return batterInnings[batter];
  }

  void removeBatter(BatterInnings batInn) {
    batterInnings.remove(batInn);
  }
}

class BatterInnings extends BattingStats {
  Innings innings;
  BatterInnings(super.batter, {required this.innings});
  Wicket? wicket;

  @override
  List<Ball> get balls =>
      innings.balls.where((ball) => ball.batter == batter).toList();

  bool get isOut => wicket != null;

  // bool isRetired = false;
  // bool get isPlaying => !isOut && !isRetired;

  void play(Ball ball) {
    if (ball.isWicket && ball.wicket!.batter == batter) {
      wicket = ball.wicket;
    }
  }

  void undo(Ball ball) {
    if (ball.isWicket && ball.wicket!.batter == batter) {
      wicket = null;
    }
  }

  void retire() {
    wicket = Wicket.retired(batter: batter);
  }
}

class BowlerInnings extends BowlingStats {
  Innings innings;

  BowlerInnings(super.bowler, {required this.innings});

  @override
  List<Ball> get balls =>
      innings.balls.where((ball) => ball.bowler == bowler).toList();
}

class FallOfWicket {
  Ball ball;
  BatterInnings inBatter;
  BatterInnings outBatter;

  FallOfWicket(
      {required this.ball, required this.inBatter, required this.outBatter});
}
