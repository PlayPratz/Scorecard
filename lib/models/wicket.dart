import 'package:scorecard/models/player.dart';

abstract class Wicket {
  Player batter;

  Wicket(this.batter);

  Dismissal get dismissal;
}

abstract class _BowlerWicket extends Wicket {
  Player bowler;

  _BowlerWicket(Player batsman, this.bowler) : super(batsman);
}

class BowledWicket extends _BowlerWicket {
  BowledWicket(Player batsman, Player bowler) : super(batsman, bowler);

  @override
  Dismissal get dismissal => Dismissal.bowled;
}

class CatchWicket extends _BowlerWicket {
  Player catcher;

  CatchWicket(Player batsman, Player bowler, this.catcher)
      : super(batsman, bowler);

  @override
  Dismissal get dismissal => Dismissal.caught;
}

class LbwWicket extends _BowlerWicket {
  LbwWicket(Player batsman, Player bowler) : super(batsman, bowler);

  @override
  Dismissal get dismissal => Dismissal.lbw;
}

class HitWicket extends _BowlerWicket {
  HitWicket(Player batsman, Player bowler) : super(batsman, bowler);

  @override
  Dismissal get dismissal => Dismissal.hitWicket;
}

class StumpedWicket extends _BowlerWicket {
  StumpedWicket(Player batsman, Player bowler) : super(batsman, bowler);

  @override
  Dismissal get dismissal => Dismissal.stumped;
}

class RunoutWicket extends Wicket {
  Player fielder;

  RunoutWicket(Player batsman, this.fielder) : super(batsman);

  @override
  Dismissal get dismissal => Dismissal.runout;
}

class RetiredWicket extends Wicket {
  RetiredWicket(Player batsman) : super(batsman);

  @override
  Dismissal get dismissal => Dismissal.retired;
}

class ObstructingFieldWicket extends Wicket {
  ObstructingFieldWicket(Player batsman) : super(batsman);

  @override
  Dismissal get dismissal => Dismissal.obstructingField;
}

enum Dismissal {
  bowled,
  caught,
  lbw,
  hitWicket,
  stumped,
  runout,
  // uncommon dimissals
  retired,
  hitTwice,
  obstructingField,
  timedOut
}
