import 'dart:collection';

import 'package:scorecard/models/ball.dart';
import 'package:scorecard/util/constants.dart';
import 'package:scorecard/util/utils.dart';

/// An abstraction of all handy methods used to calculate statistics of a batter
/// ranging from runs and balls to strike-rate, average, etc.
abstract mixin class BattingCalculations {
  UnmodifiableListView<Ball> get balls;

  int get runs => balls.fold(0, (runs, ball) => runs + ball.batterRuns);

  UnmodifiableListView<Ball> get legalBalls =>
      UnmodifiableListView(balls.where((ball) => ball.isLegal));

  int get ballsFaced => balls
      .where((ball) => ball.isLegal || ball.bowlingExtra == BowlingExtra.noBall)
      .length;

  int get wicketsFallen => balls
      .where((ball) => ball.isWicket && ball.wicket!.batter == ball.batter)
      .length;

  double get strikeRate =>
      Utils.handleDivideByZero(100 * runs, ballsFaced, fallback: 0);
  double get average =>
      Utils.handleDivideByZero(runs, wicketsFallen, fallback: runs);
  int get fours => balls.where((ball) => ball.runsScored == 4).length;
  int get sixes => balls.where((ball) => ball.runsScored == 6).length;
}

/// An abstraction of all handy methods used to calculate statistics of a bowler
/// ranging from runs conceded and balls bowled to strike-rate, average, etc.
abstract mixin class BowlingCalculations {
  UnmodifiableListView<Ball> get balls;

  UnmodifiableListView<Ball> get legalBalls =>
      UnmodifiableListView(balls.where((ball) => ball.isLegal));

  UnmodifiableListView<Ball> get wicketBalls =>
      UnmodifiableListView(balls.where((ball) => ball.isBowlerWicket));

  UnmodifiableListView<Ball> get bowlingExtraBalls =>
      UnmodifiableListView(balls.where((ball) => ball.isBowlingExtra));

  int get runsConceded => balls.fold(0, (runs, ball) => runs + ball.totalRuns);
  int get wicketsTaken => balls.where((ball) => ball.isBowlerWicket).length;

  int get legalBallsBowled => legalBalls.length;
  int get bowlingExtrasBowled => bowlingExtraBalls.length;
  int get allBallsBowled => balls.length;

  // TODO
  // int get maidensBowled => overs.where((over) => over.totalRuns == 0).length;

  double get economy => Utils.handleDivideByZero(
      Constants.ballsPerOver * runsConceded, allBallsBowled);
  double get strikeRate =>
      Utils.handleDivideByZero(allBallsBowled, wicketsTaken);
  double get average => Utils.handleDivideByZero(runsConceded, wicketsTaken);
}

// TODO
// class _FieldingStatistics {
//   int catchesTaken;
//   int runoutsTaken;
//   int stumpingsTaken;

//   _FieldingStatistics(
//       {this.catchesTaken = 0, this.runoutsTaken = 0, this.stumpingsTaken = 0});
// }
