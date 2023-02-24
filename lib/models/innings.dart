import 'package:scorecard/util/strings.dart';

import 'player.dart';
import 'wicket.dart';
import '../util/constants.dart';

import 'ball.dart';
import 'team.dart';

class Innings {
  final Team battingTeam;
  final Team bowlingTeam;

  final int? target;
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

  void popBall() {
    if (balls.isNotEmpty) {
      balls.removeLast();
    }
  }

  // Score

  int get runs => balls.fold(0, (runs, ball) => runs + ball.totalRuns);

  int get wickets => balls.where((ball) => ball.isWicket).length;

  int get ballsBowled => balls.where((ball) => ball.isLegal).length;

  String get strScore => "$runs/$wickets";
  String get strOvers => "${ballsBowled ~/ 6}.${ballsBowled % 6}";

  // Bowler

  Iterable<BowlerInnings> get bowlerInnings {
    final Map<Player, BowlerInnings> bowlerInningsMap = {};

    for (final ball in balls) {
      if (bowlerInningsMap.containsKey(ball.bowler)) {
        bowlerInningsMap[ball.bowler]!.balls.add(ball);
      } else {
        bowlerInningsMap[ball.bowler] =
            BowlerInnings(bowler: ball.bowler, innings: this);
      }
    }

    return bowlerInningsMap.values;
  }

  // Batter

  Iterable<BatterInnings> get batterInnings {
    final batterInnings = <BatterInnings>[];
    for (final ball in balls) {
      final batterInning = batterInnings.lastWhere(
        (batInn) => batInn.batter == ball.batter && !batInn.isOut,
        orElse: () {
          final batInn = BatterInnings(batter: ball.batter, innings: this);
          batterInnings.add(batInn);
          return batInn;
        },
      );
      batterInning.play(ball);
    }

    return batterInnings;
  }
}

class BatterInnings {
  Player batter;
  Innings innings;
  BatterInnings({required this.batter, required this.innings});

  Wicket? wicket;

  List<Ball> get balls =>
      innings.balls.where((ball) => ball.batter == batter).toList();

  int get runsScored =>
      balls.fold(0, (runsScored, ball) => runsScored + ball.batterRuns);
  int get numBallsFaced => balls.where((ball) => ball.shouldCount).length;

  double get strikeRate => 100 * runsScored / numBallsFaced;

  bool get isOut => wicket != null;

  String get score =>
      runsScored.toString() + Strings.scoreIn + numBallsFaced.toString();

  void play(Ball ball) {
    balls.add(ball);
    if (ball.isWicket && ball.wicket?.batter == batter) {
      wicket = ball.wicket;
    }
  }
}

class BowlerInnings {
  Player bowler;
  Innings innings;
  BowlerInnings({required this.bowler, required this.innings});

  List<Ball> get balls =>
      innings.balls.where((ball) => ball.bowler == bowler).toList();

  int get runsConceded => balls.fold(0, (runs, ball) => runs + ball.totalRuns);

  int get wicketsTaken => balls.where((ball) => ball.isBowlerWicket).length;

  // TODO
  // int get maidensBowled => overs.where((over) => over.totalRuns == 0).length;

  int get ballsBowled => balls.where((ball) => ball.isLegal).length;

  String get oversBowled =>
      (ballsBowled ~/ 6).toString() + '.' + (ballsBowled % 6).toString();

  double get economy => ballsBowled == 0
      ? 0
      : Constants.ballsPerOver * runsConceded / ballsBowled;

  String get score =>
      wicketsTaken.toString() +
      Strings.seperatorHyphen +
      runsConceded.toString();

  // void bowl(Over over) {
  //   overs.add(over);
  // }
}
