import 'package:scorecard/modules/player/player_model.dart';

sealed class Wicket {
  int? id;

  final String batterId;

  Dismissal get dismissal;

  Wicket({required this.batterId});
}

class BowledWicket extends Wicket with BowlerWicket {
  @override
  final String bowlerId;

  BowledWicket({required super.batterId, required this.bowlerId});

  @override
  Dismissal get dismissal => Dismissal.bowled;
}

class HitWicket extends Wicket with BowlerWicket {
  @override
  final String bowlerId;

  HitWicket({required super.batterId, required this.bowlerId});

  @override
  Dismissal get dismissal => Dismissal.hitWicket;
}

class LbwWicket extends Wicket with BowlerWicket {
  @override
  final String bowlerId;

  LbwWicket({required super.batterId, required this.bowlerId});

  @override
  Dismissal get dismissal => Dismissal.lbw;
}

class CaughtWicket extends Wicket with BowlerWicket, FielderWicket {
  @override
  final String bowlerId;
  @override
  final String fielderId;

  CaughtWicket(
      {required super.batterId,
      required this.bowlerId,
      required this.fielderId});

  @override
  Dismissal get dismissal => Dismissal.caught;
}

class StumpedWicket extends Wicket with BowlerWicket, FielderWicket {
  @override
  final String bowlerId;

  // According to the laws of the game, only a wicket-keeper can stump a batter.
  final String wicketkeeperId;

  @override
  String get fielderId => wicketkeeperId;

  StumpedWicket(
      {required super.batterId,
      required this.bowlerId,
      required this.wicketkeeperId});

  @override
  Dismissal get dismissal => Dismissal.stumped;
}

class RunoutWicket extends Wicket with FielderWicket {
  @override
  final String fielderId;

  RunoutWicket({required super.batterId, required this.fielderId});

  @override
  Dismissal get dismissal => Dismissal.runOut;
}

class TimedOutWicket extends Wicket {
  TimedOutWicket({required super.batterId});

  @override
  Dismissal get dismissal => Dismissal.timedOut;
}

// Retirements

sealed class Retired {
  int? id;

  final String batterId;

  Retired({required this.batterId});

  Dismissal get dismissal;
}

class RetiredDeclared extends Retired {
  RetiredDeclared({required super.batterId});

  @override
  Dismissal get dismissal => Dismissal.retired;
}

class RetiredHurt extends Retired {
  RetiredHurt({required super.batterId});

  @override
  Dismissal get dismissal => Dismissal.retiredHurt;
}

mixin BowlerWicket {
  String get bowlerId;
}

mixin FielderWicket {
  String get fielderId;
}

// class RetiredBowler {
//   final String bowlerId;
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
