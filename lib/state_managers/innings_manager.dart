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
    int overIndex = 0,
    int ballIndex = 0,
  }) {
    // Initialize batters
    if (!innings.isInitialized) {
      throw "Innings not Initialized"; // TODO make it "not embarrassing"
    }
    _initialize();
  }

  factory InningsManager.resume(Innings innings) {
    final lastBall = innings.balls.last;
    return InningsManager(
      innings,
      overIndex: lastBall.overIndex,
      ballIndex: lastBall.ballIndex,
    );
  }

  void _initialize() {
    final battersOnPitch = innings.battersOnPitch;
    batter1 = battersOnPitch.first;
    batter2 = battersOnPitch.last; // Length of battersOnPitch will always be 2

    striker = batter1;

    if (innings.balls.isEmpty) {
      bowler = innings.bowlerInningsList.last;
    } else {
      // TODO is this needed
      bowler = innings.bowlerInnings[innings.balls.last];
    }
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
    loadBallIntoBatterInnings(ball);

    if (runs % 2 == 1) _swapStrike();
    _resetSelections();

    notifyListeners();
  }

  void loadBallIntoInnings(Ball ball) {
    // Determine ball and over index
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

    innings.playBall(ball);
    innings.batterInningsList;
  }

  void loadBallIntoBatterInnings(Ball ball) {
    if (striker == null) return;
    striker!.play(ball);
  }

  bool get canUndo => innings.balls.isNotEmpty;

  void undo() {
    if (!canUndo) return;

    // Check if any event is associated with the current ball
    final currentBall = innings.balls.lastOrNull;
    if (ballToEventMap.containsKey(currentBall)) {
      final eventList = ballToEventMap[currentBall]!;
      final lastEvent = eventList.removeLast();

      if (lastEvent is _AddBatterEvent) {
        undoBatter(lastEvent);
      } else if (lastEvent is _ChangeBowlerEvent) {
        undoBowler(lastEvent);
      }

      // Remove the event list if it is empty
      if (eventList.isEmpty) {
        ballToEventMap.remove(currentBall);
      }

      _resetSelections();
      notifyListeners();
      return;
    }

    final ball = innings.unPlayBall()!;

    // Fix Bowler
    bowler = innings.bowlerInnings[ball.bowler];

    // Fix Striker
    if (batter2 != null && batter2!.batter == ball.batter) {
      striker = batter2;
    } else {
      striker = batter1;
    }

    innings.batterInnings[ball.batter]?.undo(ball);

    _resetSelections();
    notifyListeners();
  }

  // SELECTIONS

  BatterInnings? batter1;
  BatterInnings? batter2;
  BatterInnings? striker;

  BowlerInnings? bowler;

  int runs = 0;

  Wicket? wicket;
  BowlingExtra? bowlingExtra;
  BattingExtra? battingExtra;

  void setRuns(int runs) {
    this.runs = runs;
    notifyListeners();
  }

  // TODO Split all these selections to different Managers (so that Selector doesn't have to be used)

  final ballToEventMap = <Ball?, List<_InputEvent>>{};

  void addBatter({required Player inBatter, required BatterInnings outBatter}) {
    if (!outBatter.isOut) {
      outBatter.retire();
    }

    final inBatterInnings = innings.addBatter(inBatter);

    // Save the AddBatterEvent
    final addBatterEvent =
        _AddBatterEvent(inBatter: inBatterInnings, outBatter: outBatter);

    ballToEventMap.update(
        innings.balls.lastOrNull, (eventList) => eventList..add(addBatterEvent),
        ifAbsent: () => [addBatterEvent]);

    if (outBatter == batter2) {
      batter2 = inBatterInnings;
    } else {
      batter1 = inBatterInnings;
    }
    if (striker != batter1 && striker != batter2) {
      striker = inBatterInnings;
    }

    notifyListeners();
  }

  void undoBatter(_AddBatterEvent addBatterEvent) {
    if (batter2 == addBatterEvent.inBatter) {
      batter2 = addBatterEvent.outBatter;
    } else {
      batter1 = addBatterEvent.outBatter;
    }

    if (striker != batter2 && striker != batter1) {
      striker = addBatterEvent.outBatter;
    }

    innings.batterInnings.remove(addBatterEvent.inBatter);
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
    if (batter1 == null || batter2 == null) {
      return;
    }

    if (striker == batter1) {
      striker = batter2;
    } else {
      striker = batter1;
    }
  }

  bool get canChangeBowler => true;

  void setBowler(Player bowler, {bool isMidOverChange = false}) {
    final prevBowler = this.bowler;

    final nextBowler = innings.addBowler(bowler);
    final changeBowlerEvent =
        _ChangeBowlerEvent(nextBowler: nextBowler, prevBowler: prevBowler);

    ballToEventMap.update(
      innings.balls.lastOrNull,
      (eventList) => eventList..add(changeBowlerEvent),
      ifAbsent: () => [changeBowlerEvent],
    );

    this.bowler = nextBowler;
    if (!isMidOverChange) {
      _swapStrike();
    }
    _canSelectBowler = false;

    notifyListeners();
  }

  void undoBowler(_ChangeBowlerEvent changeBowlerEvent) {
    bowler = changeBowlerEvent.prevBowler;

    if (changeBowlerEvent.nextBowler.balls.isEmpty) {
      innings.bowlerInnings.remove(changeBowlerEvent.nextBowler);
    }
  }

  bool get canSetWicket => nextInput == NextInput.ball;
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
    if (batter1 != null && batter1!.isOut ||
        batter2 != null && batter2!.isOut) {
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
  }
}

enum NextInput {
  ball,
  batter,
  bowler,
  end,
}

abstract class _InputEvent {}

class _AddBatterEvent extends _InputEvent {
  final BatterInnings inBatter;
  final BatterInnings? outBatter;

  _AddBatterEvent({required this.inBatter, required this.outBatter});
}

class _ChangeBowlerEvent extends _InputEvent {
  final BowlerInnings nextBowler;
  final BowlerInnings? prevBowler;

  _ChangeBowlerEvent({required this.nextBowler, required this.prevBowler});
}
