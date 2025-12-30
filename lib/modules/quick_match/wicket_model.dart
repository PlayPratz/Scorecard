sealed class Wicket {
  int? id;

  final int batterId;

  String get code;

  Wicket({required this.batterId});
}

class Bowled extends Wicket with BowlerWicket {
  @override
  final int bowlerId;

  Bowled({required super.batterId, required this.bowlerId});

  @override
  String get code => "bowled";
}

class HitWicket extends Wicket with BowlerWicket {
  @override
  final int bowlerId;

  HitWicket({required super.batterId, required this.bowlerId});

  @override
  String get code => "hit wicket";
}

class Lbw extends Wicket with BowlerWicket {
  @override
  final int bowlerId;

  Lbw({required super.batterId, required this.bowlerId});

  @override
  String get code => "lbw";
}

class Caught extends Wicket with BowlerWicket, FielderWicket {
  @override
  final int bowlerId;
  @override
  final int fielderId;

  Caught(
      {required super.batterId,
      required this.bowlerId,
      required this.fielderId});

  @override
  String get code => "caught";
}

class CaughtAndBowled extends Wicket with BowlerWicket, FielderWicket {
  @override
  final int bowlerId;

  @override
  int get fielderId => bowlerId;

  CaughtAndBowled({required super.batterId, required this.bowlerId});

  @override
  String get code => "caught and bowled";
}

class Stumped extends Wicket with BowlerWicket, FielderWicket {
  @override
  final int bowlerId;

  // According to the laws of the game, only a wicket-keeper can stump a batter.
  final int wicketkeeperId;

  @override
  int get fielderId => wicketkeeperId;

  Stumped(
      {required super.batterId,
      required this.bowlerId,
      required this.wicketkeeperId});

  @override
  String get code => "stumped";
}

class RunOut extends Wicket with FielderWicket {
  @override
  final int fielderId;

  RunOut({required super.batterId, required this.fielderId});

  @override
  String get code => "run out";
}

class TimedOut extends Wicket {
  TimedOut({required super.batterId});

  @override
  String get code => "timed out";
}

class ObstructingTheField extends Wicket {
  ObstructingTheField({required super.batterId});

  @override
  String get code => "obstructing the field";
}

class HitTheBallTwice extends Wicket {
  HitTheBallTwice({required super.batterId});

  @override
  String get code => "hit the ball twice";
}

sealed class Retired extends Wicket {
  Retired({required super.batterId});
}

class RetiredOut extends Retired {
  RetiredOut({required super.batterId});

  @override
  String get code => "retired - out";
}

class RetiredNotOut extends Retired {
  RetiredNotOut({required super.batterId});

  @override
  String get code => "retired - not out";
}

mixin BowlerWicket {
  int get bowlerId;
}

mixin FielderWicket {
  int get fielderId;
}

// class RetiredBowler {
//   final String bowlerId;
//
//   RetiredBowler({required this.bowler});
// }

// enum Dismissal {
//   bowled("bowled"),
//   lbw("lbw"),
//   hitWicket("hit wicket"),
//   caught("caught"),
//   caughtAndBowled("caught and bowled"),
//   stumped("stumped"),
//   runOut("run out"),
//   obstructing("obstructing the field"),
//   hitTwice("hit the ball twice"),
//   timedOut("timed out"),
//   retiredOut("retired - out"),
//   retiredNotOut("retired - not out");
//
//   final String description;
//   const Dismissal(this.description);
// }
