import 'team.dart';

abstract class Result {
  VictoryType getVictoryType();
}

class ResultWinByDefending extends Result {
  final Team winner;
  final Team loser;
  final int runsWonBy;

  ResultWinByDefending(
      {required this.winner, required this.loser, required this.runsWonBy});

  @override
  VictoryType getVictoryType() {
    return VictoryType.defending;
  }
}

class ResultWinByChasing extends Result {
  final Team winner;
  final Team loser;
  final int ballsLeft;
  final int wicketsLeft;

  ResultWinByChasing(
      {required this.winner,
      required this.loser,
      required this.ballsLeft,
      required this.wicketsLeft});

  @override
  VictoryType getVictoryType() {
    return VictoryType.chasing;
  }
}

class ResultTie extends Result {
  final Team homeTeam;
  final Team awayTeam;

  ResultTie({required this.homeTeam, required this.awayTeam});

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
