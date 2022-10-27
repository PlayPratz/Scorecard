import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/statistics.dart';
import 'package:scorecard/models/wicket.dart';
import 'package:scorecard/util/constants.dart';

class Ball {
  int battingRuns;
  Wicket? wicket;
  BowlingExtra? bowlingExtra;
  BattingExtra? battingExtra;

  Player playedBy;

  Ball(this.battingRuns, this.playedBy);

  /// Creates a ball that is a wicket of type [wicket] with the specified number of [runs].
  Ball.wicket(this.battingRuns, this.playedBy, this.wicket);

  /// Creates a ball that is a bowling extra of type [bowlingExtra] with the specified number of [runs].
  ///
  /// DO NOT specify the number of runs due to the extra. That will be added automatically.
  Ball.bowlingExtra(this.battingRuns, this.playedBy, this.bowlingExtra);

  int get totalRuns => battingRuns + bowlingExtraRuns;
  int get bowlingExtraRuns => isBowlingExtra ? 1 : 0;
  int get batterRuns => isBattingExtra ? 0 : battingRuns;

  bool get isWicket => wicket != null;
  bool get isBowlingExtra => bowlingExtra != null;
  bool get isBattingExtra => battingExtra != null;
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

  int get numOfLegalBalls => legalBalls.length;
  int get numOfBowlingExtras => bowlingExtraBalls.length;
  int get numOfBallsLeft => Constants.ballsPerOver - numOfLegalBalls;
  int get numOfBallsBowled => legalBalls.length;
  bool get isCompleted => numOfBallsLeft == 0;
  int get totalRuns => statistics.runsConceded;

  void addBall(Ball ball) {
    if (isCompleted) {
      // Exception
      return;
    }
    balls.add(ball);

    // Statistics
    statistics.ballsBowled++;
    statistics.runsConceded += ball.totalRuns;
    if (ball.isWicket) {
      statistics.wicketsTaken++;
    }
  }
}

enum BattingExtra {
  bye,
  legBye,
}

enum BowlingExtra {
  noBall,
  wide,
}
