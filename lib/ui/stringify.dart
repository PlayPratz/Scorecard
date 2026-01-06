import 'package:scorecard/modules/quick_match/post_ball_and_extras_model.dart';
import 'package:scorecard/modules/quick_match/quick_match_model.dart';
import 'package:scorecard/modules/quick_match/wicket_model.dart';

class Stringify {
  static String score(Score score) => "${score.runs}/${score.wickets}";

  static String battingScore(BattingScore battingScore) => _batterScore(
      battingScore.runsScored, battingScore.ballsFaced, battingScore.isNotOut!);

  static String _batterScore(int runs, int numBalls, bool isNotOut) =>
      "$runs ($numBalls)";

  static String wicket(Wicket? wicket,
          {String ifNone = "not out",
          required String Function(int) getPlayerName}) =>
      switch (wicket) {
        Bowled() => "b ${getPlayerName(wicket.bowlerId)}",
        HitWicket() => "hit wicket b ${getPlayerName(wicket.bowlerId)}",
        Lbw() => "lbw b ${getPlayerName(wicket.bowlerId)}",
        Caught() =>
          "c ${getPlayerName(wicket.fielderId)} b ${getPlayerName(wicket.bowlerId)}",
        CaughtAndBowled() => "c&b ${getPlayerName(wicket.bowlerId)}",
        Stumped() =>
          "st ${getPlayerName(wicket.wicketkeeperId)} b ${getPlayerName(wicket.bowlerId)}",
        RunOut() => "run out (${getPlayerName(wicket.fielderId)})",
        TimedOut() => "timed out",
        RetiredOut() => "retired - out",
        RetiredNotOut() => "retired - not out",
        ObstructingTheField() => "obstructing the field",
        HitTheBallTwice() => "hit the ball twice",
        null => ifNone,
      };

  static String ballCount(int ballCount, int ballsPerOver) =>
      "${ballCount ~/ ballsPerOver}.${ballCount % ballsPerOver}";

  static String postIndex(PostIndex index) => "${index.over}.${index.ball}";

  static String economy(double economy) =>
      economy.isNaN || economy.isInfinite ? '∞' : economy.toStringAsFixed(2);

  static String quickInningsHeading(int inningsNumber) =>
      switch (inningsNumber) {
        1 => "First Innings",
        2 => "Second Innings",
        _ => "Super Over ${_getSuperOverString(inningsNumber)}"
      };

  static String _getSuperOverString(int inningsNumber) {
    final identifier = inningsNumber % 2 == 1 ? 'A' : 'B';
    return "${1 + (inningsNumber - 3) ~/ 2}$identifier";
  }

  static String quickMatchResult(QuickMatchResult result) => switch (result) {
        QuickMatchDefendedResult() => "Won by ${result.runs} runs",
        QuickMatchChasedResult() =>
          "Won with ${result.ballsToSpare} balls to spare",
        QuickMatchTieResult() => "Match tied",
      };
}
