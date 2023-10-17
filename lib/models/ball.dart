import 'dart:collection';

import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/statistics.dart';
import 'package:scorecard/models/wicket.dart';
import 'package:scorecard/util/constants.dart';

class Ball {
  /// The bowler who bowled the delivery
  final Player bowler;

  /// The batter who faced the delivery
  final Player batter;

  /// Runs awarded to the batting team by facing this [Ball]
  ///
  /// This does not include runs awarded due to an illegal delivery.
  ///
  ///  _Note: **DO NOT** specify the runs awarded to the batting team due_
  /// _to a bowling extra such as a no-ball or a wide._
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
  ///
  /// For every legal delivery, 1 <= index <= 6
  /// For every illegal delivery, 0 <= index <= 5
  int ballIndex;

  /// The timestamp at which this ball was bowled.
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

  bool get isWicket => wicket != null && wicket!.dismissal != Dismissal.retired;
  bool get isBatterRetired =>
      wicket != null && wicket!.dismissal == Dismissal.retired;
  bool get isBowlerWicket =>
      (isWicket && Dismissal.values.take(5).contains(wicket!.dismissal));
  bool get isBowlingExtra => bowlingExtra != null;
  bool get isBattingExtra => battingExtra != null;
  bool get isLegal => !isBowlingExtra && !isEventOnly;
}

class Over with BowlingCalculations {
  final List<Ball> _balls = [];
  @override
  UnmodifiableListView<Ball> get balls => UnmodifiableListView(_balls);

  UnmodifiableListView<Ball> get allWicketBalls =>
      UnmodifiableListView(balls.where((ball) => ball.isWicket));

  int get ballsLeft => Constants.ballsPerOver - legalBallsBowled;
  bool get isCompleted => ballsLeft == 0;

  void addBall(Ball ball) {
    if (isCompleted) {
      throw UnsupportedError("Attempted to add ball to completed over");
    }
    _balls.add(ball);
  }

  void removeBall(Ball ball) {
    if (balls.lastOrNull != ball) {
      throw UnsupportedError(
          "Attempted to remove a ball other than the last ball of the over");
    }
    _balls.removeLast();
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
