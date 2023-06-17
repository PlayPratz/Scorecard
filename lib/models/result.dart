import 'team.dart';

abstract class Result {
  final Team winner;
  final Team loser;

  Result({required this.winner, required this.loser});

  VictoryType getVictoryType();
}

class ResultWinByDefending extends Result {
  final int runsWonBy;

  ResultWinByDefending(
      {required super.winner, required super.loser, required this.runsWonBy});

  @override
  VictoryType getVictoryType() {
    return VictoryType.defending;
  }
}

class ResultWinByChasing extends Result {
  final int ballsLeft;
  // final int wicketsLeft;

  ResultWinByChasing({
    required super.winner,
    required super.loser,
    required this.ballsLeft,
  });

  @override
  VictoryType getVictoryType() {
    return VictoryType.chasing;
  }
}

class ResultTie extends Result {
  ResultTie({required super.winner, required super.loser});

  @override
  VictoryType getVictoryType() {
    return VictoryType.tie;
  }
}

enum VictoryType {
  defending,
  chasing,
  tie,
  draw, // For future use
}
