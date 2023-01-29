import 'package:flutter/material.dart';
import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/innings.dart';

class InningsManager with ChangeNotifier {
  final Innings innings;
  InningsManager(this.innings, {BatterInnings? batter, bowler});

  Iterable<BatterInnings> get onPitchBatters => innings.batterInnings
      .where((batterInning) => !batterInning.isOut)
      .toList()
      .reversed
      .take(2);

  // Ball

  void addBall(Ball ball) {
    innings.pushBall(ball);
  }

  bool get canUndoMove =>
      innings.ballsBowled > 0; //More than zero balls in list

  void undoMove() {}

  bool get canAddBall => true; // TODO _validateBallParams

  void endInnings() {}

  // State

  NextInput get nextInput => NextInput.ball; //TODO

  // MISC

  bool get isHomeTeamBatting => true; //TODO
}

enum NextInput {
  ball,
  batter,
  bowler,
  end,
}
