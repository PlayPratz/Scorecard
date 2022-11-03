import 'player.dart';
import 'wicket.dart';
import 'package:scorecard/util/constants.dart';

class Ball {
  /// The bowler who bowled the delivery
  Player bowler;

  /// The batter who faced the delivery
  Player batter;

  /// Runs awarded to the batting team by facing this [Ball].
  /// <br/> Note: Do not specify the runs due to a bowling extra.
  int runsScored;

  /// The type of [BowlingExtra] if applicable
  BowlingExtra? bowlingExtra;

  /// The type of [BattingExtra] if applicable
  BattingExtra? battingExtra;

  /// The [Wicket], if any, which was taken on this [Ball]
  Wicket? wicket;

  bool _shouldCountBall = true;

  Ball(
      {required this.bowler,
      required this.batter,
      required this.runsScored,
      this.wicket,
      this.battingExtra,
      this.bowlingExtra});

  /// Creates a ball that does not constitute a wicket and is not an extra of any kind
  Ball.runs(
      {required this.bowler, required this.batter, required this.runsScored});

  /// Creates a ball that is a wicket of type [Wicket] with the specified number of [runsScored].
  Ball.wicket(
      {required this.bowler,
      required this.batter,
      this.runsScored = 0,
      required this.wicket,
      this.bowlingExtra,
      this.battingExtra});

  /// Creates a ball that is not bowled, but a runout is recorded
  Ball.runoutBeforeDelivery({
    required this.bowler,
    required this.batter,
  })  : runsScored = 0,
        wicket = Wicket.runout(batter: batter, fielder: bowler),
        _shouldCountBall = false;

  int get totalRuns => runsScored + bowlingExtraRuns;
  int get bowlingExtraRuns => isBowlingExtra ? 1 : 0;
  int get batterRuns => isBattingExtra ? 0 : runsScored;

  bool get isWicket => wicket != null;
  bool get isBowlerWicket =>
      (isWicket && Dismissal.values.take(5).contains(wicket!.dismissal));
  bool get isBowlingExtra => bowlingExtra != null;
  bool get isBattingExtra => battingExtra != null;
  bool get shouldCount => _shouldCountBall && !isBowlingExtra;
}

class Over {
  Player bowler;
  List<Ball> balls = [];
  // BowlingStatistics statistics = BowlingStatistics();

  Over(this.bowler);

  List<Ball> get legalBalls => balls.where((ball) => ball.shouldCount).toList();

  List<Ball> get bowlingExtraBalls =>
      balls.where((ball) => ball.isBowlingExtra).toList();

  List<Ball> get wicketBalls => balls.where((ball) => ball.isWicket).toList();

  int get numOfLegalBalls => legalBalls.length;
  int get numOfBowlingExtras => bowlingExtraBalls.length;
  int get numOfBallsLeft => Constants.ballsPerOver - numOfLegalBalls;
  int get numOfBallsBowled => balls.length;
  bool get isCompleted => numOfBallsLeft == 0;

  // int get totalRuns => statistics.runsConceded;
  int get totalRuns => balls.fold(0, (runs, ball) => runs + ball.totalRuns);
  int get bowlerWickets => balls.where((ball) => ball.isBowlerWicket).length;
  int get totalWickets => wicketBalls.length;

  void addBall(Ball ball) {
    if (isCompleted) {
      // Exception
      return;
    }
    balls.add(ball);
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
