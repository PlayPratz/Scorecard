import 'package:scorecard/modules/cricket_match/models/wicket_model.dart';

class Stringify {
  static String wicket(Wicket? wicket,
          {RetiredBatter? retired, String ifNone = "not out"}) =>
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
}
