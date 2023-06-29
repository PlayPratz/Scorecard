import 'dart:math';

import 'package:scorecard/models/statistics.dart';

import 'player.dart';
import '../util/constants.dart';

import 'ball.dart';
import 'team.dart';

class Innings {
  final Team battingTeam;
  final Team bowlingTeam;

  int? target;
  final int maxOvers;

  Innings(
      {required this.battingTeam,
      required this.bowlingTeam,
      required this.maxOvers})
      : target = null;

  Innings.target(
      {required this.battingTeam,
      required this.bowlingTeam,
      required this.target,
      required this.maxOvers});

  final List<Ball> balls = [];

  // OPERATIONS

  void pushBall(Ball ball) {
    balls.add(ball);
  }

  Ball? popBall() {
    if (balls.isNotEmpty) {
      return balls.removeLast();
    }
    return null;
  }

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

  Iterable<BowlerInnings> get bowlerInnings {
    final Map<Player, BowlerInnings> bowlerInningsMap = {};

    for (final ball in balls) {
      if (bowlerInningsMap.containsKey(ball.bowler)) {
        bowlerInningsMap[ball.bowler]!.balls.add(ball);
      } else {
        bowlerInningsMap[ball.bowler] =
            BowlerInnings(ball.bowler, innings: this);
      }
    }

    return bowlerInningsMap.values;
  }

  // Batter

  Iterable<BatterInnings> get batterInnings {
    final batterInnings = <BatterInnings>[];
    for (final ball in balls) {
      final batterInning = batterInnings.lastWhere(
        (batInn) => batInn.batter == ball.batter //&& !batInn.isOut
        ,
        orElse: () {
          final batInn = BatterInnings(ball.batter, innings: this);
          batterInnings.add(batInn);
          return batInn;
        },
      );
      batterInning.play(ball);
    }

    return batterInnings;
  }
}

class BatterInnings extends BattingStats {
  Innings innings;
  BatterInnings(super.batter, {required this.innings});

  // Wicket? wicket;

  @override
  List<Ball> get balls =>
      innings.balls.where((ball) => ball.batter == batter).toList();

  bool get isOut => wicket != null;

  void play(Ball ball) {
    balls.add(ball);
    // if (ball.isWicket && ball.wicket?.batter == batter) {
    //   wicket = ball.wicket;
    // }
  }
}

class BowlerInnings extends BowlingStats {
  Innings innings;

  BowlerInnings(super.bowler, {required this.innings});

  @override
  List<Ball> get balls =>
      innings.balls.where((ball) => ball.bowler == bowler).toList();
}
