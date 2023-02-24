import 'package:flutter/material.dart';
import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/models/wicket.dart';
import 'package:scorecard/util/constants.dart';

class InningsManager with ChangeNotifier {
  final Innings innings;
  InningsManager(this.innings, {this.batter, this.nsbatter, this.bowler});

  Iterable<BatterInnings> get onPitchBatters => innings.batterInnings
      .where((batterInning) => !batterInning.isOut)
      .toList()
      .reversed
      .take(2);

  // Ball

  void addBall() {
    final ball = Ball(
        bowler: bowler!.bowler,
        batter: batter!.batter,
        runsScored: runs,
        battingExtra: battingExtra,
        bowlingExtra: bowlingExtra,
        wicket: wicket);
    innings.pushBall(ball);
    if (runs % 2 == 1) {
      _swapStrike();
    }
    resetSelections();
    notifyListeners();
  }

  bool get canUndoMove =>
      innings.ballsBowled > 0; //More than zero balls in list

  void undoMove() {
    innings.popBall();
    resetSelections();
    notifyListeners();
  }

  bool get canAddBall => true; // TODO _validateBallParams

  // void endInnings() {} TODO

  // SELECTIONS

  BatterInnings? batter;
  BatterInnings? nsbatter;
  BowlerInnings? bowler;

  int runs = 0;

  Wicket? wicket;
  BowlingExtra? bowlingExtra;
  BattingExtra? battingExtra;

  void setRuns(int runs) {
    this.runs = runs;
    notifyListeners();
  }

  void setBatter(BatterInnings batter) {
    if (batter == nsbatter) {
      _swapStrike();
    } else {
      this.batter = batter;
    }
    _canSelectBatter = false;

    notifyListeners();
  }

  void _swapStrike() {
    final swap = batter;
    batter = nsbatter;
    nsbatter = swap;
  }

  void setBowler(BowlerInnings bowler) {
    this.bowler = bowler;
    _canSelectBowler = false;

    notifyListeners();
  }

  void setWicket(Wicket? wicket) {
    this.wicket = wicket;
    notifyListeners();
  }

  void setBowlingExtra(BowlingExtra? bowlingExtra) {
    this.bowlingExtra = bowlingExtra;
    notifyListeners();
  }

  void setBattingExtra(BattingExtra? battingExtra) {
    this.battingExtra = battingExtra;
    notifyListeners();
  }

  bool _canSelectBatter = false;
  bool _canSelectBowler = false;

  NextInput get nextInput {
    if (innings.ballsBowled == innings.maxOvers * Constants.ballsPerOver) {
      return NextInput.end;
    }

    if (innings.target != null && innings.runs >= innings.target!) {
      return NextInput.end;
    }

    if (_canSelectBowler &&
        innings.balls.isNotEmpty &&
        innings.balls.where((ball) => ball.isLegal).length % 6 == 0) {
      return NextInput.bowler;
    }

    if (_canSelectBatter &&
        innings.balls.isNotEmpty &&
        innings.balls.last.isWicket) {
      return NextInput.batter;
    }
    return NextInput.ball;
  } //TODO

  void resetSelections() {
    runs = 0;
    wicket = null;
    bowlingExtra = null;
    battingExtra = null;

    _canSelectBatter = true;
    _canSelectBowler = true;
  }
}

enum NextInput {
  ball,
  batter,
  bowler,
  end,
}
