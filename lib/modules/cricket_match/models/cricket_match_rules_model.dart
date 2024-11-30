sealed class GameRules {
  final int? id; // TODO

  final int ballsPerOver;
  // final int wicketsPerInnings; TODO

  final int noBallPenalty;
  final int widePenalty;

  final bool onlySingleBatter;
  final bool lastWicketBatter;

  GameRules({
    required this.id,
    required this.ballsPerOver,
    required this.noBallPenalty,
    required this.widePenalty,
    required this.onlySingleBatter,
    required this.lastWicketBatter,
  });
}

class UnlimitedOversRules extends GameRules {
  final int daysOfPlay;
  final int sessionsPerDay;
  final int inningsPerSide;

  UnlimitedOversRules({
    required super.id,
    required super.ballsPerOver,
    required super.noBallPenalty,
    required super.widePenalty,
    required super.onlySingleBatter,
    required super.lastWicketBatter,
    required this.daysOfPlay,
    required this.sessionsPerDay,
    required this.inningsPerSide,
  });
}

class LimitedOversRules extends GameRules {
  final int oversPerInnings;
  final int oversPerBowler;

  LimitedOversRules({
    required super.id,
    required super.ballsPerOver,
    required super.noBallPenalty,
    required super.widePenalty,
    required super.onlySingleBatter,
    required super.lastWicketBatter,
    required this.oversPerInnings,
    required this.oversPerBowler,
  });

  LimitedOversRules.custom({
    super.id,
    required super.ballsPerOver,
    required super.noBallPenalty,
    required super.widePenalty,
    required super.onlySingleBatter,
    required super.lastWicketBatter,
    required this.oversPerInnings,
    required this.oversPerBowler,
  });

  // LimitedOversRules.standard()
  //     : this(
  //         ballsPerOver: 6,
  //         noBallPenalty: 1,
  //         allowLastMan: false,
  //         lastWicketBatter: false,
  //         widePenalty: 1,
  //         oversPerInnings: 5,
  //         oversPerBowler: -1,
  //       );
}
