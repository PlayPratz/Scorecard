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

  bool get canAddBall =>
      striker != null &&
      (striker == batter1 || striker == batter2) &&
      bowler != null;

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

  bool get canUndoBall => innings.balls.isNotEmpty;

  void undoBall() {
    if (!canUndoBall) return;

    final ball = innings.popBall()!;

    // Fix Batters
    if (ball.isWicket) {
      final battersOnPitch = _onPitchBatters;

      if (battersOnPitch.any((batInn) => batInn.batter == batter1!.batter)) {
        // This means that batter1 is still playing
        batter2 = battersOnPitch
            .firstWhere((batInn) => batInn.batter != batter1!.batter);
        if (!battersOnPitch.any((batInn) => batInn.batter == striker!.batter)) {
          striker = batter2;
        }
      } else {
        // This means that batter2 is still playing
        batter1 = battersOnPitch
            .firstWhere((batInn) => batInn.batter != batter2!.batter);
        if (!battersOnPitch.any((batInn) => batInn.batter == striker!.batter)) {
          striker = batter1;
        }
      }

      // if (ball.batter == batter1!.batter) {
      //   // batter1 needs to be restored, batter2 is correct
      //   if (batter2!.batter == battersOnPitch.first.batter) {
      //     batter1 = _onPitchBatters.last;
      //   } else {
      //     batter1 = _onPitchBatters.first;
      //   }
      //   // Restore striker
      //   if (striker != null && striker!.batter == ball.batter) {
      //     striker = batter1;
      //   }
      // } else {
      //   // batter2 needs to be restored, batter1 is correct
      //   if (batter1!.batter == battersOnPitch.first.batter) {
      //     batter2 = _onPitchBatters.last;
      //   } else {
      //     batter2 = _onPitchBatters.first;
      //   }
      //   // Restore striker
      //   if (striker != null && striker!.batter == ball.batter) {
      //     striker = batter2;
      //   }
      // }
    } else {
      // Restore striker
      if (batter1!.batter == ball.batter) {
        striker = batter1;
      } else {
        striker = batter2;
      }
    }

    // Fix Bowler
    setBowler(ball.bowler, isMidOverChange: true);

    _resetSelections();
    notifyListeners();
  }

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
    batterInnings ??= BatterInnings(batter, innings: innings);
    // New batter

    if (batter1 == batterToReplace) {
      batter1 = batterInnings;
    } else {
      batter2 = batterInnings;
    }

    if (striker != batter1 && striker != batter2) {
      striker = batterInnings;
    }

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
    this.bowler = BowlerInnings(bowler, innings: innings);

    if (!isMidOverChange) {
      _swapStrike();
    }
    _canSelectBowler = false;

    notifyListeners();
  }

  bool get canSetWicket => nextInput == NextInput.ball;
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

    // Change Batter due to fall of wicket
    if (
        // _canSelectBatter &&
        innings.balls.isNotEmpty &&
            innings.balls.last.isWicket &&
            batterToReplace != null) {
      return NextInput.batter;
    }

    // Change Bowler due to end of over
    if (_canSelectBowler &&
        innings.balls.isNotEmpty &&
        innings.balls.last.ballIndex == Constants.ballsPerOver) {
      return NextInput.bowler;
    }
    return NextInput.ball;
  }

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
