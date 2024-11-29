import 'package:scorecard/modules/player/player_model.dart';

sealed class Wicket {
  final Player batter;

  Dismissal get dismissal;

  Wicket({required this.batter});
}

class BowledWicket extends Wicket {
  final Player bowler;

  BowledWicket({required super.batter, required this.bowler});

  @override
  Dismissal get dismissal => Dismissal.bowled;
}

class HitWicket extends Wicket {
  final Player bowler;

  HitWicket({required super.batter, required this.bowler});

  @override
  Dismissal get dismissal => Dismissal.hitWicket;
}

class LbwWicket extends Wicket {
  final Player bowler;

  LbwWicket({required super.batter, required this.bowler});

  @override
  Dismissal get dismissal => Dismissal.lbw;
}

class CaughtWicket extends Wicket {
  final Player bowler;
  final Player fielder;

  CaughtWicket(
      {required super.batter, required this.bowler, required this.fielder});

  @override
  Dismissal get dismissal => Dismissal.caught;
}

class StumpedWicket extends Wicket {
  final Player bowler;

  // According to the laws of the game, only a wicket-keeper can stump a batter.
  final Player wicketkeeper;

  StumpedWicket(
      {required super.batter,
      required this.bowler,
      required this.wicketkeeper});

  @override
  Dismissal get dismissal => Dismissal.stumped;
}

class RunoutWicket extends Wicket {
  final Player fielder;

  RunoutWicket({required super.batter, required this.fielder});

  @override
  Dismissal get dismissal => Dismissal.runOut;
}

class TimedOutWicket extends Wicket {
  TimedOutWicket({required super.batter});

  @override
  Dismissal get dismissal => Dismissal.timedOut;
}

// Retirements

sealed class Retire {
  final Player batter;

  Retire({required this.batter});

  Dismissal get dismissal;
}

class RetiredDeclared extends Retire {
  RetiredDeclared({required super.batter});

  @override
  Dismissal get dismissal => Dismissal.retired;
}

class RetiredHurt extends Retire {
  RetiredHurt({required super.batter});

  @override
  Dismissal get dismissal => Dismissal.retiredHurt;
}

// class RetiredBowler {
//   final Player bowler;
//
//   RetiredBowler({required this.bowler});
// }

enum Dismissal {
  bowled,
  hitWicket,
  lbw,
  caught,
  stumped,
  runOut,
  timedOut,
  retired,
  retiredHurt,
}
