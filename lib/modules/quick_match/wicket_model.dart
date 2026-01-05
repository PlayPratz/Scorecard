sealed class Wicket {
  int? id;

  final int batterId;

  Dismissal get dismissal;

  Wicket({required this.batterId});
}

class Bowled extends Wicket with BowlerWicket {
  @override
  final int bowlerId;

  Bowled({required super.batterId, required this.bowlerId});

  @override
  Dismissal get dismissal => Dismissal.bowled;
}

class HitWicket extends Wicket with BowlerWicket {
  @override
  final int bowlerId;

  HitWicket({required super.batterId, required this.bowlerId});

  @override
  Dismissal get dismissal => Dismissal.hitWicket;
}

class Lbw extends Wicket with BowlerWicket {
  @override
  final int bowlerId;

  Lbw({required super.batterId, required this.bowlerId});

  @override
  Dismissal get dismissal => Dismissal.lbw;
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
  Dismissal get dismissal => Dismissal.caught;
}

class CaughtAndBowled extends Wicket with BowlerWicket, FielderWicket {
  @override
  final int bowlerId;

  @override
  int get fielderId => bowlerId;

  CaughtAndBowled({required super.batterId, required this.bowlerId});

  @override
  Dismissal get dismissal => Dismissal.caughtAndBowled;
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
  Dismissal get dismissal => Dismissal.stumped;
}

class RunOut extends Wicket with FielderWicket {
  @override
  final int fielderId;

  RunOut({required super.batterId, required this.fielderId});

  @override
  Dismissal get dismissal => Dismissal.runOut;
}

class TimedOut extends Wicket {
  TimedOut({required super.batterId});

  @override
  Dismissal get dismissal => Dismissal.timedOut;
}

class ObstructingTheField extends Wicket {
  ObstructingTheField({required super.batterId});

  @override
  Dismissal get dismissal => Dismissal.obstructing;
}

class HitTheBallTwice extends Wicket {
  HitTheBallTwice({required super.batterId});

  @override
  Dismissal get dismissal => Dismissal.hitTwice;
}

sealed class Retired extends Wicket {
  Retired({required super.batterId});
}

class RetiredOut extends Retired {
  RetiredOut({required super.batterId});

  @override
  Dismissal get dismissal => Dismissal.retiredOut;
}

class RetiredNotOut extends Retired {
  RetiredNotOut({required super.batterId});

  @override
  Dismissal get dismissal => Dismissal.retiredNotOut;
}

mixin BowlerWicket {
  int get bowlerId;
}

mixin FielderWicket {
  int get fielderId;
}

enum Dismissal {
  bowled("bowled"),
  lbw("lbw"),
  hitWicket("hit wicket"),
  caught("caught"),
  caughtAndBowled("caught and bowled"),
  stumped("stumped"),
  runOut("run out"),
  obstructing("obstructing the field"),
  hitTwice("hit the ball twice"),
  timedOut("timed out"),
  retiredOut("retired - out"),
  retiredNotOut("retired - not out");

  final String code;
  const Dismissal(this.code);
}
