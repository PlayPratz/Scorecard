class BattingStats {
  final int playerId;
  final String playerName;

  final int matchesPlayed;
  final int inningsPlayed;

  final int runsScored;
  final int ballsFaced;

  final int notOuts;
  final int outs;

  final int foursScored;
  final int sixesScored;

  final int highScore;

  final double strikeRate;
  final double average;

  BattingStats({
    required this.playerId,
    required this.playerName,
    required this.matchesPlayed,
    required this.inningsPlayed,
    required this.runsScored,
    required this.ballsFaced,
    required this.notOuts,
    required this.outs,
    required this.foursScored,
    required this.sixesScored,
    required this.highScore,
    required this.strikeRate,
    required this.average,
  });
}

class BowlingStats {
  final int playerId;
  final String playerName;

  final int matchesPlayed;
  final int inningsPlayed;

  final int ballsBowled;
  final int oversBowled;
  final int oversBallsBowled;

  final int runsConceded;
  final int wicketsTaken;

  final int noBallsBowled;
  final int widesBowled;

  final double economy;
  final double average;
  final double strikeRate;

  BowlingStats({
    required this.playerId,
    required this.playerName,
    required this.matchesPlayed,
    required this.inningsPlayed,
    required this.ballsBowled,
    required this.oversBowled,
    required this.oversBallsBowled,
    required this.runsConceded,
    required this.wicketsTaken,
    required this.noBallsBowled,
    required this.widesBowled,
    required this.economy,
    required this.average,
    required this.strikeRate,
  });
}
