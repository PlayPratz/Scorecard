import 'package:scorecard/util/constants.dart';

import 'player.dart';
import 'wicket.dart';

class Ball {
  /// The bowler who bowled the delivery
  final Player bowler;

  /// The batter who faced the delivery
  final Player batter;

  /// Runs awarded to the batting team by facing this [Ball].
  /// <br/> Note: Do not specify the runs due to a bowling extra.
  final int runsScored;

  /// The type of [BowlingExtra] if applicable
  final BowlingExtra? bowlingExtra;

  /// The type of [BattingExtra] if applicable
  final BattingExtra? battingExtra;

  /// The [Wicket], if any, which was taken on this [Ball]
  final Wicket? wicket;

  final bool isEventOnly;

  /// Zero-based index of the over this ball is bowled in
  int overIndex;

  /// One-based index of this ball in its over
  /// It could be zero if the first ball is a bowling extra
  int ballIndex;

  final DateTime timestamp;

  Ball({
    required this.bowler,
    required this.batter,
    required this.runsScored,
    required this.wicket,
    required this.battingExtra,
    required this.bowlingExtra,
    required this.overIndex,
    required this.ballIndex,
    required this.isEventOnly,
    required this.timestamp,
  });

  Ball.create({
    required this.bowler,
    required this.batter,
    required this.runsScored,
    required this.wicket,
    required this.battingExtra,
    required this.bowlingExtra,
    required this.isEventOnly,
  })  : timestamp = DateTime.timestamp(),
        overIndex = 0,
        ballIndex = 0;

  int get totalRuns => runsScored + bowlingExtraRuns;
  int get bowlingExtraRuns => isBowlingExtra ? 1 : 0;
  int get batterRuns => isBattingExtra ? 0 : runsScored;

  bool get isWicket => wicket != null;
  bool get isBowlerWicket =>
      (isWicket && Dismissal.values.take(5).contains(wicket!.dismissal));
  bool get isBowlingExtra => bowlingExtra != null;
  bool get isBattingExtra => battingExtra != null;
  bool get isLegal => !isBowlingExtra && !isEventOnly;
}

class Over {
  List<Ball> balls = [];
  // BowlingStatistics statistics = BowlingStatistics();

  Over();

  List<Ball> get legalBalls => balls.where((ball) => ball.isLegal).toList();

  // List<Ball> get bowlingExtraBalls =>
  //     balls.where((ball) => ball.isBowlingExtra).toList();
  //
  List<Ball> get wicketBalls => balls.where((ball) => ball.isWicket).toList();

  int get numOfLegalBalls => legalBalls.length;
  // int get numOfBowlingExtras => bowlingExtraBalls.length;
  int get numOfBallsLeft => Constants.ballsPerOver - numOfLegalBalls;
  // int get numOfBallsBowled => balls.length;
  bool get isCompleted => numOfBallsLeft == 0;

  // int get totalRuns => statistics.runsConceded;
  int get totalRuns => balls.fold(0, (runs, ball) => runs + ball.totalRuns);
  // int get bowlerWickets => balls.where((ball) => ball.isBowlerWicket).length;
  int get totalWickets => wicketBalls.length;

  void addBall(Ball ball) {
    if (isCompleted) {
      throw StateError("Attempted to add ball to completed over");
    }
    balls.add(ball);
  }

  void removeBall(Ball ball) {
    if (balls.lastOrNull != ball) {
      throw StateError("Attempted to add ball to completed over");
    }
    balls.remove(ball);
  }
}

/// Possible types of extras by the batting team
enum BattingExtra {
  bye,
  legBye,
}

/// Possible types of extras by the bowling team
enum BowlingExtra {
  noBall,
  wide,
}
