import 'package:flutter/material.dart';
import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/wicket.dart';
import 'package:scorecard/util/constants.dart';

class InningsManager with ChangeNotifier {
  final Innings innings;
  InningsManager(
    this.innings, {
    this.batter1,
    this.batter2,
    this.bowler,
    int overIndex = 0,
    int ballIndex = 0,
  }) : striker = batter1;

  factory InningsManager.resume(Innings innings) {
    final lastBall = innings.balls.last;
    final batterInnings = innings.batterInnings
        .where((batterInning) => !batterInning.isOut)
        .toList()
        .reversed
        .take(2);

    return InningsManager(
      innings,
      batter1: batterInnings.first,
      batter2: batterInnings.last,
      bowler: innings.bowlerInnings.singleWhere(
          (bowlerInnings) => bowlerInnings.bowler == lastBall.bowler),
      overIndex: lastBall.overIndex,
      ballIndex: lastBall.ballIndex,
    );
  }

  // Ball

  // int _overIndex;
  // int _ballIndex;

  void addBall() {
    final ball = Ball(
      bowler: bowler!.bowler,
      batter: striker!.batter,
      runsScored: runs,
      battingExtra: battingExtra,
      bowlingExtra: bowlingExtra,
      wicket: wicket,
    );

    loadBallIntoInnings(ball);

    if (runs % 2 == 1) _swapStrike();
    _resetSelections();

    notifyListeners();
  }

  void loadBallIntoInnings(Ball ball) {
    // Detemine ball and over index
    int overIndex = 0;
    int ballIndex = 1;

    if (innings.balls.isNotEmpty) {
      // Ball index has to be changed

      // Get current indexes
      final lastBall = innings.balls.last;
      ballIndex = lastBall.ballIndex;
      overIndex = lastBall.overIndex;

      // Increment ballIndex
      ballIndex++;

      if (ballIndex > Constants.ballsPerOver) {
        // First ball of the over
        overIndex++;
        ballIndex = 1;

        if (!ball.isLegal) {
          ballIndex = 0;
        }
      }
    } else if (!ball.isLegal) {
      ballIndex = 0;
    }

    ball.ballIndex = ballIndex;
    ball.overIndex = overIndex;

    innings.pushBall(ball);
    innings.batterInnings;
  }

  bool get canUndoMove => innings.balls.isNotEmpty;

  void undoMove() {
    if (!canUndoMove) return;

    final ball = innings.popBall();
    if (ball!.runsScored % 2 == 1) _swapStrike();
    _resetSelections();

    // Prevent undo of first ball from triggering "Pick Bowler" NextInput
    _canSelectBowler = false;

    notifyListeners();
  }

  bool get canAddBall => true; // TODO _validateBallParams

  // void endInnings() {} TODO

  // SELECTIONS

  BatterInnings? batter1;
  BatterInnings? batter2;
  BatterInnings? striker;
  BatterInnings? batterToReplace;

  Iterable<BatterInnings> get _onPitchBatters => innings.batterInnings
      .where((batterInning) => !batterInning.isOut)
      .toList()
      .reversed
      .take(2);

  BowlerInnings? bowler;

  int runs = 0;

  Wicket? wicket;
  BowlingExtra? bowlingExtra;
  BattingExtra? battingExtra;

  void setRuns(int runs) {
    this.runs = runs;
    notifyListeners();
  }

  void addBatter(Player batter) {
    // Check if the batter exists in the Batter Innings list
    BatterInnings? batterInnings = _getBatterInningsOfPlayer(batter);
    if (batterInnings == null) {
      // New batter
      batterInnings = BatterInnings(batter: batter, innings: innings);
      return;
    }
    // New batter

    if (_onPitchBatters.first == batter1) {
      batter2 = batterInnings;
    } else {
      batter1 = batterInnings;
    }

    if (striker != batter1 && striker != batter2) {
      striker = batterInnings;
    }

    // _canSelectBatter = false;
    batterToReplace = null;

    notifyListeners();
  }

  void setStrike(BatterInnings batter) {
    if (batter2 != null && batter == batter2) {
      striker = batter2;
    } else {
      striker = batter1;
    }
    notifyListeners();
  }

  void _swapStrike() {
    // final swap = batter;
    // batter = nsbatter;
    // nsbatter = swap;
    if (striker == batter1) {
      striker = batter2;
    } else {
      striker = batter1;
    }
  }

  // void setBowler(BowlerInnings bowler) {
  //   this.bowler = bowler;
  //   _canSelectBowler = false;

  //   notifyListeners();
  // }

  // bool get canChangeBowler => innings.ballsBowled % Constants.ballsPerOver == 0;
  bool get canChangeBowler => true;

  void setBowler(Player bowler, {bool isMidOverChange = false}) {
    this.bowler = BowlerInnings(bowler: bowler, innings: innings);

    if (!isMidOverChange) {
      _swapStrike();
    }
    _canSelectBowler = false;

    notifyListeners();
  }

  void setWicket(Wicket? wicket) {
    this.wicket = wicket;

    if (wicket != null) {
      batterToReplace = _getBatterInningsOfPlayer(wicket.batter);
    }

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

  // bool _canSelectBatter = false;
  bool _canSelectBowler = false;

  NextInput get nextInput {
    // End Innings due to over completion
    if (innings.ballsBowled == innings.maxOvers * Constants.ballsPerOver) {
      return NextInput.end;
    }

    // End Innings due to chasing the target
    if (innings.target != null && innings.runs >= innings.target!) {
      return NextInput.end;
    }

    // Change Bowler due to end of over
    if (_canSelectBowler &&
        innings.balls.isNotEmpty &&
        innings.balls.last.ballIndex == Constants.ballsPerOver) {
      return NextInput.bowler;
    }

    // Change Batter due to fall of wicket
    if (
        // _canSelectBatter &&
        innings.balls.isNotEmpty &&
            innings.balls.last.isWicket &&
            batterToReplace != null) {
      return NextInput.batter;
    }
    return NextInput.ball;
  } //TODO

  // Helpers
  void _resetSelections() {
    runs = 0;
    wicket = null;
    bowlingExtra = null;
    battingExtra = null;

    // _canSelectBatter = true;
    _canSelectBowler = true;
    // batterToReplace = null;
  }

  BatterInnings? _getBatterInningsOfPlayer(Player player) {
    try {
      return innings.batterInnings
          .lastWhere((batInn) => batInn.batter == player);
    } on StateError {
      return null;
    }
  }
}

enum NextInput {
  ball,
  batter,
  bowler,
  end,
}
