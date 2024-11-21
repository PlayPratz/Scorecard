sealed class GameRules {
  final int ballsPerOver;
  // final int wicketsPerInnings; TODO

  final int noBallPenalty;
  final int widePenalty;

  final bool allowSingleBatter;
  final bool allowLastMan;

  GameRules({
    required this.ballsPerOver,
    required this.noBallPenalty,
    required this.widePenalty,
    required this.allowSingleBatter,
    required this.allowLastMan,
  });
}

class LimitedOversRules extends GameRules {
  final int oversPerInnings;
  final int oversPerBowler;

  LimitedOversRules({
    required super.ballsPerOver,
    required super.noBallPenalty,
    required super.widePenalty,
    required super.allowSingleBatter,
    required super.allowLastMan,
    required this.oversPerInnings,
    required this.oversPerBowler,
  });

  LimitedOversRules.standard()
      : this(
          ballsPerOver: 6,
          noBallPenalty: 1,
          allowLastMan: false,
          allowSingleBatter: false,
          widePenalty: 1,
          oversPerInnings: 5,
          oversPerBowler: -1,
        );
}

class UnlimitedOversRules extends GameRules {
  final int days;
  final int inningsPerSide;

  UnlimitedOversRules({
    required super.ballsPerOver,
    required super.noBallPenalty,
    required super.widePenalty,
    required super.allowSingleBatter,
    required super.allowLastMan,
    required this.days,
    required this.inningsPerSide,
  });
}
