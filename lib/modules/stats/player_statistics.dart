import 'package:scorecard/util/number_utils.dart';

class PlayerBattingStatistics {
  final String id;
  final String name;

  final int runs;
  final int numBalls;
  final int numWickets;

  double get strikeRate => handleDivideByZero(runs * 100, numBalls.toDouble());

  PlayerBattingStatistics(
      {required this.id,
      required this.name,
      required this.runs,
      required this.numBalls,
      required this.numWickets});
}

class PlayerBowlingStatistics {
  final String id;
  final String name;

  final int runs;

  final int numWickets;
  final int numBalls;
  final int numWides;
  final int numNoBalls;

  double get economy =>
      handleDivideByZero(runs.toDouble(), numBalls.toDouble());

  PlayerBowlingStatistics(
      {required this.id,
      required this.name,
      required this.runs,
      required this.numWickets,
      required this.numBalls,
      required this.numWides,
      required this.numNoBalls});
}
