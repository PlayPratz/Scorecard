import 'dart:html';

import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/statistics.dart';
import 'package:scorecard/models/wicket.dart';
import 'package:scorecard/util/constants.dart';

class Ball {
  int runs;
  Wicket? wicket;
  BowlingExtra? bowlingExtra;

  Ball(this.runs);

  /// Creates a ball that is a wicket of type [wicket] with the specified number of [runs].
  Ball.wicket(this.runs, this.wicket);

  /// Creates a ball that is a bowling extra of type [bowlingExtra] with the specified number of [runs].
  ///
  /// DO NOT specify the number of runs due to the extra. That will be added automatically.
  Ball.bowlingExtra(this.runs, this.bowlingExtra) {
    switch (bowlingExtra) {
      case BowlingExtra.noBall:
      case BowlingExtra.wide:
        runs = runs + 1;
        break;
      default:
    }
  }

  bool get isWicket => wicket != null;
  bool get isBowlingExtra => bowlingExtra != null;
}

class Over {
  Player bowler;
  List<Ball> balls = [];
  BowlingStatistics statistics = BowlingStatistics();

  Over(this.bowler);

  List<Ball> get legalBalls =>
      balls.where((ball) => !ball.isBowlingExtra).toList();

  List<Ball> get bowlingExtraBalls =>
      balls.where((ball) => ball.isBowlingExtra).toList();

  List<Ball> get wicketBalls => balls.where((ball) => ball.isWicket).toList();

  int get numOfLegalsBalls => legalBalls.length;

  int get numOfBowlingExtras => bowlingExtraBalls.length;

  int get numOfBallsLeft => Constants.ballsPerOver - numOfLegalsBalls;

  bool get isCompleted => numOfBallsLeft == 0;

  int get runs => statistics.runsConceded;

  void addBall(Ball ball) {
    if (isCompleted) {
      // Exception
      return;
    }
    balls.add(ball);

    // Statistics
    statistics.ballsBowled++;
    statistics.runsConceded += ball.runs;
    if (ball.isWicket) {
      statistics.wicketsTaken++;
    }
  }
}

// enum LegalDelivery {
//   normal,
//   bye,
//   legBye,
// }

enum BowlingExtra {
  legal,
  noBall,
  wide,
  dead,
}
