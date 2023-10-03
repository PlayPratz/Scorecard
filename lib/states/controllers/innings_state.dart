import 'dart:async';

import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/states/containers/innings_selection.dart';
import 'package:scorecard/util/constants.dart';

class InningsStateController {
  final _inningsEventController = StreamController<InningsEvent>();
  // get inningsEventStream => _inningsEventController.stream;

  final _inningsEventHistory = <InningsEvent>[];

  final _inningsStateController = StreamController<InningsState>();
  Stream<InningsState> get stateStream => _inningsStateController.stream;

  final Innings innings;
  final InningsSelections _selections;

  InningsStateController({required this.innings, required selections})
      : _selections = selections {
    _inningsEventController.stream.listen((event) {
      if (event.shouldAddToHistory) {
        _inningsEventHistory.add(event);
      }
      _inningsStateController.add(_deduceState());
    });
  }

  InningsState _deduceState() {
    // End Innings due to over completion
    if (innings.ballsBowled == innings.maxOvers * Constants.ballsPerOver) {
      return EndInningsState(innings: innings, selections: _selections);
    }

    // End Innings due to chasing the target
    if (innings.target != null && innings.runs >= innings.target!) {
      return EndInningsState(innings: innings, selections: _selections);
    }

    // Change Batter due to fall of wicket
    final playerInAction = innings.playersInAction;
    if (playerInAction.batter1 != null && playerInAction.batter1!.isOut) {
      return AddBatterState(
          innings: innings,
          selections: _selections,
          batterToReplace: playerInAction.batter1!);
    }

    if (playerInAction.batter2 != null && playerInAction.batter2!.isOut) {
      return AddBatterState(
          innings: innings,
          selections: _selections,
          batterToReplace: playerInAction.batter2!);
    }

    // Change Bowler due to end of over
    if (innings.balls.isNotEmpty &&
        innings.balls.last.ballIndex == Constants.ballsPerOver &&
        _inningsEventHistory.last is! SetBowlerEvent) {
      return AddBowlerState(innings: innings, selections: _selections);
    }

    // If none of the above conditions are met, the innings is in progress and
    // a ball is to be added.
    return AddBallState(innings: innings, selections: _selections);
  }

  InningsState get initialState =>
      AddBallState(innings: innings, selections: _selections);

  void addBall() {
    // Create a ball from the current selections
    final playersInAction = innings.playersInAction;
    final ball = Ball(
      bowler: playersInAction.bowler!.bowler,
      batter: playersInAction.striker!.batter,
      runsScored: _selections.runs,
      battingExtra: _selections.battingExtra,
      bowlingExtra: _selections.bowlingExtra,
      wicket: _selections.wicket,
    );

    // Update the over and ball index for the ball (ex: 4.2, 19.6)
    _updateIndexes(ball);

    // Add the ball to the innings.
    innings.play(ball);

    // Swap strike for odd number of runs.
    // This is mainly a convenience feature, as strike can be set manually
    // via the UI anyway.
    if (ball.runsScored % 2 == 1) _swapStrike();

    _inningsEventController.add(AddBallEvent(ball: ball));
  }

  void _undoAddBall(AddBallEvent addBallEvent) {
    // Reverse of addBall()

    final ball = addBallEvent.ball;

    if (ball.runsScored % 2 == 1) _swapStrike();

    innings.unPlay(ball);
  }

  void _updateIndexes(Ball ball) {
    // if (innings.balls.isEmpty) {
    //   ball.overIndex = 0;
    //   ball.ballIndex = 1;
    // } else {
    //   final lastBall = innings.balls.last;
    //   if (lastBall.ballIndex == Constants.ballsPerOver) {
    //     ball.overIndex = lastBall.overIndex + 1;
    //     ball.ballIndex = 1;
    //   } else {
    //     ball.overIndex = lastBall.overIndex;
    //     ball.ballIndex = lastBall.ballIndex + 1;
    //   }
    // }
    // if (!ball.isLegal) {
    //   ball.ballIndex--;
    // }

    int overIndex = innings.balls.isEmpty ? 0 : innings.balls.last.overIndex;
    int ballIndex = innings.balls.isEmpty ? 0 : innings.balls.last.ballIndex;

    if (ball.isLegal) {
      ballIndex++;

      if (ballIndex > Constants.ballsPerOver) {
        ballIndex = 0;
        overIndex++;
      }
    }

    ball.overIndex = overIndex;
    ball.ballIndex = ballIndex;
  }

  void _swapStrike() {
    final playersInAction = innings.playersInAction;
    if (playersInAction.batter1 == null || playersInAction.batter2 == null) {
      return;
    }
    // TODO move to innings?
    if (playersInAction.striker == playersInAction.batter1) {
      playersInAction.striker = playersInAction.batter2;
    } else {
      playersInAction.striker = playersInAction.batter1;
    }
  }

  void setBowler({required Player bowler}) {
    // Add bowler to innings
    final inBowlerInnings = innings.setBowler(bowler);

    // Update on UI/selections
    innings.playersInAction.bowler = inBowlerInnings;

    final outBowlerInnings = innings.balls.isNotEmpty
        ? innings.getBowlerInnings(innings.balls.last.bowler)
        : null;

    _inningsEventController.add(
        SetBowlerEvent(inBowler: inBowlerInnings, outBowler: outBowlerInnings));
  }

  void _undoSetBowler(SetBowlerEvent setBowlerEvent) {
    innings.removeBowler(setBowlerEvent.inBowler);

    innings.playersInAction.bowler = setBowlerEvent.outBowler;
  }

  void addBatter(
      {required Player inBatter, required BatterInnings outBatterInnings}) {
    // TODO Should most of this be in a State Manager? Probably move to different file.

    // Check if the batter being replaced has lost their wicket
    if (!outBatterInnings.isOut) {
      // If they haven't, they're most likely retired.
      // TODO implement different types of retired: hurt, etc.
      outBatterInnings.retire();
    }

    // Add the batter to innings
    final inBatterInnings = innings.addBatter(inBatter, outBatterInnings);

    // On the UI/selections, replace old batter with new batter.
    // _fixBattersInAction(inBatterInnings, outBatterInnings);

    _inningsEventController.add(
        AddBatterEvent(inBatter: inBatterInnings, outBatter: outBatterInnings));
  }

  void _undoAddBatter(AddBatterEvent addBatterEvent) {
    // Pretty much do the exact reverse of addBatter()

    if (addBatterEvent.outBatter == null) {
      throw StateError("AddBatterEvent does not contain 'OutBatter'");
    }

    // Params are reversed
    _fixBattersInAction(addBatterEvent.outBatter!, addBatterEvent.inBatter);

    // Remove the batter from the innings/scorecard
    innings.removeBatter(addBatterEvent.inBatter);

    // Reverse "retired" wicket if any
    if (addBatterEvent.outBatter!.isRetired) {
      addBatterEvent.outBatter!.wicket = null;
    }
  }

  void setStrike(BatterInnings batter) {
    innings.setStrike(batter);
    _inningsEventController.add(ChangeStrikeEvent(striker: batter));
  }

  void _fixBattersInAction(BatterInnings inBatter, BatterInnings outBatter) {
    final playersInAction = innings.playersInAction;
    if (outBatter == playersInAction.batter2) {
      playersInAction.batter2 = inBatter;
    } else {
      playersInAction.batter1 = inBatter;
    }
    if (playersInAction.striker != playersInAction.batter1 &&
        playersInAction.striker != playersInAction.batter2) {
      playersInAction.striker = inBatter;
    }
  }

  void undo() {
    if (_inningsEventHistory.isEmpty) {
      return;
    }
    final lastEvent = _inningsEventHistory.removeLast();

    switch (lastEvent) {
      case AddBallEvent():
        _undoAddBall(lastEvent);
        break;
      case AddBatterEvent():
        _undoAddBatter(lastEvent);
        break;
      case SetBowlerEvent():
        _undoSetBowler(lastEvent);
        break;
      default:
        return;
    }

    _inningsStateController.add(_deduceState());
  }
}

// EVENTS

sealed class InningsEvent {
  final bool shouldAddToHistory;

  InningsEvent({this.shouldAddToHistory = true});
}

class AddBallEvent extends InningsEvent {
  final Ball ball;

  AddBallEvent({required this.ball});
}

class AddBatterEvent extends InningsEvent {
  // final Player batter;
  //
  // AddBatterEvent({required this.batter});

  final BatterInnings inBatter;
  final BatterInnings? outBatter;

  AddBatterEvent({required this.inBatter, required this.outBatter});
}

class SetBowlerEvent extends InningsEvent {
  final BowlerInnings inBowler;
  final BowlerInnings? outBowler;

  SetBowlerEvent({required this.inBowler, this.outBowler});
}

class ChangeStrikeEvent extends InningsEvent {
  final BatterInnings striker;

  ChangeStrikeEvent({
    required this.striker,
  }) : super(shouldAddToHistory: false);
}

// STATES

sealed class InningsState {
  final Innings innings;
  final InningsSelections selections;

  InningsState({required this.innings, required this.selections});
}

// class InitInningsState extends InningsState {}

class AddBallState extends InningsState {
  AddBallState({required super.innings, required super.selections});
}

class AddBatterState extends InningsState {
  final BatterInnings batterToReplace;

  AddBatterState(
      {required super.innings,
      required super.selections,
      required this.batterToReplace});
}

class AddBowlerState extends InningsState {
  AddBowlerState({required super.innings, required super.selections});
}

class EndInningsState extends InningsState {
  EndInningsState({required super.innings, required super.selections});
}
