import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/util/constants.dart';

abstract class BattingStats {
  final Player batter;

  BattingStats(this.batter);

  List<Ball> get balls;

  int get runs =>
      balls.fold(0, (runsScored, ball) => runsScored + ball.batterRuns);

  int get ballsFaced => balls
      .where((ball) => ball.isLegal || ball.bowlingExtra == BowlingExtra.noBall)
      .length;

  int get wicketsFallen => balls.where((ball) => ball.isWicket).length;

  double get strikeRate => 100 * runs / ballsFaced;
  double get average => runs / wicketsFallen;
  int get fours => balls.where((ball) => ball.runsScored == 4).length;
  int get sixes => balls.where((ball) => ball.runsScored == 6).length;
}

abstract class BowlingStats {
  final Player bowler;

  BowlingStats(this.bowler);

  List<Ball> get balls;

  int get runsConceded => balls.fold(0, (runs, ball) => runs + ball.totalRuns);
  int get wicketsTaken => balls.where((ball) => ball.isBowlerWicket).length;
  int get ballsBowled => balls.where((ball) => ball.isLegal).length;

  // TODO
  // int get maidensBowled => overs.where((over) => over.totalRuns == 0).length;

  double get economy => Constants.ballsPerOver * runsConceded / ballsBowled;
  double get strikeRate => ballsBowled / wicketsTaken;
  double get average => runsConceded / wicketsTaken;
}

// TODO
// class _FieldingStatistics {
//   int catchesTaken;
//   int runoutsTaken;
//   int stumpingsTaken;

//   _FieldingStatistics(
//       {this.catchesTaken = 0, this.runoutsTaken = 0, this.stumpingsTaken = 0});
// }
