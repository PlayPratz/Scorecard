// import 'package:scorecard/util/constants.dart';

// TODO bring these classses back to life

// class Statistics {
//   _BattingStatistics battingStatistics;
//   BowlingStatistics bowlingStatistics;
//   _FieldingStatistics fieldingStatistics;

//   Statistics(
//       this.battingStatistics, this.bowlingStatistics, this.fieldingStatistics);

//   Statistics.createEmpty()
//       : battingStatistics = _BattingStatistics(),
//         bowlingStatistics = BowlingStatistics(),
//         fieldingStatistics = _FieldingStatistics();
// }

// class _BattingStatistics {
//   int runsScored;
//   int ballsFaced;
//   int wicketsGiven;

//   _BattingStatistics(
//       {this.runsScored = 0, this.ballsFaced = 0, this.wicketsGiven = 0});

//   double get strikeRate => 100 * runsScored / ballsFaced;

//   double get average => runsScored / wicketsGiven;
// }
//

import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/util/constants.dart';

// TODO solve Jugaad
class BattingStatistics {
  final Player batter;
  final List<Ball> balls = [];

  BattingStatistics(this.batter);

  // TODO JUGAAD COPIED FROM BATTERINNINGS
  int get runsScored =>
      balls.fold(0, (runsScored, ball) => runsScored + ball.batterRuns);

  int get numBallsFaced => balls
      .where((ball) => ball.isLegal || ball.bowlingExtra == BowlingExtra.noBall)
      .length;

  int get wicketsFallen => balls.where((ball) => ball.isWicket).length;

  double get strikeRate => 100 * runsScored / numBallsFaced;
  double get average => runsScored / wicketsFallen;
}

class BowlingStatistics {
  final Player bowler;
  final List<Ball> balls = [];

  BowlingStatistics(this.bowler);

  // TODO Jugaad copied from BowlerInnings
  int get runsConceded => balls.fold(0, (runs, ball) => runs + ball.totalRuns);
  int get wicketsTaken => balls.where((ball) => ball.isBowlerWicket).length;
  int get ballsBowled => balls.where((ball) => ball.isLegal).length;

  double get economy => Constants.ballsPerOver * runsConceded / ballsBowled;
  double get strikeRate => ballsBowled / wicketsTaken;
  double get average => runsConceded / wicketsTaken;

  String get oversBowled =>
      (ballsBowled ~/ 6).toString() + '.' + (ballsBowled % 6).toString();
}

// class _FieldingStatistics {
//   int catchesTaken;
//   int runoutsTaken;
//   int stumpingsTaken;

//   _FieldingStatistics(
//       {this.catchesTaken = 0, this.runoutsTaken = 0, this.stumpingsTaken = 0});
// }
