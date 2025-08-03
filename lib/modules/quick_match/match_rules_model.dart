class QuickMatchRules {
  final int ballsPerOver;
  final int maxBalls;

  final int noBallPenalty;
  final int widePenalty;

  final bool onlySingleBatter;
  final bool lastWicketBatter;

  QuickMatchRules({
    required this.ballsPerOver,
    required this.maxBalls,
    required this.noBallPenalty,
    required this.widePenalty,
    required this.onlySingleBatter,
    required this.lastWicketBatter,
  });
}
