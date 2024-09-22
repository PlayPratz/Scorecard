import 'package:scorecard/modules/player/player_model.dart';

sealed class Wicket {
  final Player batter;

  Wicket({required this.batter});
}

class BowledWicket extends Wicket {
  final Player bowler;

  BowledWicket({required super.batter, required this.bowler});
}

class HitWicket extends Wicket {
  final Player bowler;

  HitWicket({required super.batter, required this.bowler});
}

class LbwWicket extends Wicket {
  final Player bowler;

  LbwWicket({required super.batter, required this.bowler});
}

class CaughtWicket extends Wicket {
  final Player bowler;
  final Player fielder;

  CaughtWicket(
      {required super.batter, required this.bowler, required this.fielder});
}

class StumpedWicket extends Wicket {
  final Player bowler;

  // According to the laws of the game, only a wicket-keeper can stump a batter.
  final Player wicketkeeper;

  StumpedWicket(
      {required super.batter,
      required this.bowler,
      required this.wicketkeeper});
}

class RunoutWicket extends Wicket {
  final Player fielder;

  RunoutWicket({required super.batter, required this.fielder});
}

class TimedOutWicket extends Wicket {
  TimedOutWicket({required super.batter});
}

// Retirements

sealed class Retired {
  final Player batter;

  Retired({required this.batter});
}

class RetiredDeclared extends Retired {
  RetiredDeclared({required super.batter});
}

class RetiredHurt extends Retired {
  RetiredHurt({required super.batter});
}
