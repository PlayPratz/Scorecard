import 'player.dart';

class Wicket {
  final Player batter;
  final Player? bowler;
  final Player? fielder;
  final Dismissal dismissal;

  // Wicket({required this.batter});
  Wicket.bowled({required this.batter, required this.bowler})
      : dismissal = Dismissal.bowled,
        fielder = null;

  Wicket.caught(
      {required this.batter, required this.bowler, required this.fielder})
      : dismissal = Dismissal.caught;

  Wicket.stumped(
      {required this.batter, required this.bowler, required this.fielder})
      : dismissal = Dismissal.stumped;

  Wicket.runout({required this.batter, required this.fielder})
      : dismissal = Dismissal.runout,
        bowler = null;
}

enum Dismissal {
  // Bowler Wickets
  bowled,
  caught,
  lbw,
  hitWicket,
  stumped,

  // Team Wickets
  runout,
  // uncommon dimissals
  retired,
  hitTwice,
  obstructingField,
  timedOut
}

const BowlerDismissals = [
  Dismissal.bowled,
  Dismissal.caught,
  Dismissal.lbw,
  Dismissal.hitWicket,
  Dismissal.stumped
];
