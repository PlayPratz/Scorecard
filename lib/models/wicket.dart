import 'player.dart';

class Wicket {
  final Player batter;
  final Player? bowler;
  final Player? fielder;
  final Dismissal dismissal;

  // Bowler Wickets
  Wicket.bowled({required this.batter, required this.bowler})
      : dismissal = Dismissal.bowled,
        fielder = null;

  Wicket.lbw({required this.batter, required this.bowler})
      : dismissal = Dismissal.lbw,
        fielder = null;

  Wicket.hitWicket({required this.batter, required this.bowler})
      : fielder = null,
        dismissal = Dismissal.hitWicket;

  // Fielder Wickets
  Wicket.caught(
      {required this.batter, required this.bowler, required this.fielder})
      : dismissal = Dismissal.caught;

  Wicket.stumped(
      {required this.batter, required this.bowler, required this.fielder})
      : dismissal = Dismissal.stumped;

  Wicket.runout({required this.batter, required this.fielder})
      : dismissal = Dismissal.runout,
        bowler = null;

  // Uncommon
  Wicket.retired({required this.batter})
      : dismissal = Dismissal.retired,
        bowler = null,
        fielder = null;

  Wicket(
      {required this.batter,
      required this.bowler,
      required this.fielder,
      required this.dismissal});
}

enum Dismissal {
  // Bowler Wickets
  bowled,
  lbw,
  hitWicket,

  // Bowler + Fielder Wickets
  caught,
  stumped,

  // Fielder Wickets
  runout,

  // uncommon dimissals
  retired,
  // hitTwice,
  // obstructingField,
  // timedOut
}
