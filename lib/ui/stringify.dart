import 'package:scorecard/modules/quick_match/post_ball_and_extras_model.dart';
import 'package:scorecard/modules/quick_match/quick_match_model.dart';
import 'package:scorecard/modules/quick_match/wicket_model.dart';

class Stringify {
  static String score(Score score) => "${score.runs}/${score.wickets}";

  static String wicket(Wicket? wicket,
          {Retired? retired,
          String ifNone = "not out",
          required String Function(String) getPlayerName}) =>
      switch (wicket) {
        null => switch (retired) {
            null => ifNone,
            RetiredDeclared() => "retired",
            RetiredHurt() => "retired hurt",
          },
        BowledWicket() => "b ${getPlayerName(wicket.bowlerId)}",
        HitWicket() => "hit-wicket b ${getPlayerName(wicket.bowlerId)}",
        LbwWicket() => "lbw b ${getPlayerName(wicket.bowlerId)}",
        CaughtWicket() => wicket.fielderId == wicket.bowlerId
            ? "c&b ${getPlayerName(wicket.bowlerId)}"
            : "c ${getPlayerName(wicket.fielderId)} b ${getPlayerName(wicket.bowlerId)}",
        StumpedWicket() =>
          "st ${getPlayerName(wicket.wicketkeeperId)} b ${getPlayerName(wicket.bowlerId)}",
        RunoutWicket() => "run out (${getPlayerName(wicket.fielderId)})",
        TimedOutWicket() => "timed-out",
      };

  static String ballCount(int ballCount, int ballsPerOver) =>
      "${ballCount ~/ ballsPerOver}.${ballCount % ballsPerOver}";

  static String postIndex(PostIndex index) => "${index.over}.${index.ball}";

  static String economy(double economy) =>
      economy.isNaN || economy.isInfinite ? '∞' : economy.toStringAsFixed(2);

  static String inningsHeading(int inningsNumber) => switch (inningsNumber) {
        1 => "First Innings",
        2 => "Second Innings",
        _ => "Innings $inningsNumber"
      };
}
