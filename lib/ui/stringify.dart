import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/cricket_match/models/wicket_model.dart';

class Stringify {
  static String score(Score score) => "${score.runs}-${score.wickets}";

  static String wicket(Wicket? wicket,
          {Retire? retired, String ifNone = "not out"}) =>
      switch (wicket) {
        null => switch (retired) {
            null => ifNone,
            RetiredDeclared() => "retired",
            RetiredHurt() => "retired hurt",
          },
        BowledWicket() => "b ${wicket.bowler.name}",
        HitWicket() => "hit-wicket b ${wicket.bowler.name}",
        LbwWicket() => "lbw b ${wicket.bowler.name}",
        CaughtWicket() => wicket.fielder == wicket.bowler
            ? "c&b ${wicket.bowler.name}"
            : "c ${wicket.fielder.name} b ${wicket.bowler.name}",
        StumpedWicket() =>
          "st ${wicket.wicketkeeper.name} b ${wicket.bowler.name}",
        RunoutWicket() => "run out (${wicket.fielder.name})",
        TimedOutWicket() => "timed-out",
      };

  static String ballCount(int ballCount, int ballsPerOver) =>
      "${ballCount ~/ ballsPerOver}.${ballCount % ballsPerOver}";

  static String postIndex(PostIndex index) => "${index.over}.${index.ball}";

  static String economy(double economy) =>
      economy == double.infinity ? '∞' : economy.toStringAsFixed(2);
}
