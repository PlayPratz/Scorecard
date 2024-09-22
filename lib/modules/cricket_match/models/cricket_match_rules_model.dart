sealed class GameRules {
  final int ballsPerOver;
  // final int wicketsPerInnings; TODO

  final int widePenalty;
  final int noBallPenalty;

  GameRules(
      {required this.ballsPerOver,
      required this.widePenalty,
      required this.noBallPenalty});
}

class LimitedOversRules extends GameRules {
  final int oversPerInnings;
  final int oversPerBowler;

  LimitedOversRules({
    required super.ballsPerOver,
    required super.widePenalty,
    required super.noBallPenalty,
    required this.oversPerInnings,
    required this.oversPerBowler,
  });

  LimitedOversRules.standard()
      : this(
          ballsPerOver: 6,
          oversPerInnings: 5,
          oversPerBowler: -1,
          noBallPenalty: 1,
          widePenalty: 1,
        );
}

class UnlimitedOversRules extends GameRules {
  final int days;
  final int inningsPerSide;

  UnlimitedOversRules({
    required super.ballsPerOver,
    required super.widePenalty,
    required super.noBallPenalty,
    required this.days,
    required this.inningsPerSide,
  });
}
