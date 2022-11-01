// import 'package:scorecard/util/constants.dart';

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

// class BowlingStatistics {
//   int runsConceded;
//   int ballsBowled;
//   int wicketsTaken;

//   BowlingStatistics(
//       {this.runsConceded = 0, this.ballsBowled = 0, this.wicketsTaken = 0});

//   double get economy => Constants.ballsPerOver * runsConceded / ballsBowled;

//   double get strikeRate => ballsBowled / wicketsTaken;

//   double get average => runsConceded / wicketsTaken;
// }

// class _FieldingStatistics {
//   int catchesTaken;
//   int runoutsTaken;
//   int stumpingsTaken;

//   _FieldingStatistics(
//       {this.catchesTaken = 0, this.runoutsTaken = 0, this.stumpingsTaken = 0});
// }
