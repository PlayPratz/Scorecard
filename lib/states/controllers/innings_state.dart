import 'dart:async';

import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/states/containers/innings_selection.dart';
import 'package:scorecard/util/constants.dart';

class InningsStateController {
  final _inningsEventController = StreamController<InningsEvent>();

  final _inningsEventHistory = <InningsEvent>[];

  final _inningsStateController = StreamController<InningsState>();

  Stream<InningsState> get stateStream => _inningsStateController.stream;

  final Innings innings;
  final InningsSelections _selections;

  InningsStateController({
    required this.innings,
    required InningsSelections selections,
  }) : _selections = selections {
    _inningsEventController.stream.listen((event) {
      if (event.shouldAddToHistory) {
        _inningsEventHistory.add(event);
      }
      _inningsStateController.add(_deduceState());
    });
  }

  InningsState _deduceState() {
    // End Innings due to over completion
    if (innings.areOversCompleted) {
      return EndInningsState(innings: innings, selections: _selections);
    }

    // End Innings due to chasing the target
    if (innings.target != null && innings.runs >= innings.target!) {
      return EndInningsState(innings: innings, selections: _selections);
    }

    // Change Batter due to fall of wicket
    final playerInAction = innings.playersInAction;
    if (playerInAction.batter1.isOutOrRetired) {
      return AddBatterState(
        innings: innings,
        selections: _selections,
        batterToReplace: playerInAction.batter1,
      );
    }

    if (playerInAction.batter2 != null &&
        playerInAction.batter2!.isOutOrRetired) {
      return AddBatterState(
          innings: innings,
          selections: _selections,
          batterToReplace: playerInAction.batter2!);
    }

    // Change Bowler due to end of over
    if (innings.balls.isNotEmpty &&
        innings.balls.last.ballIndex == Constants.ballsPerOver &&
        (_inningsEventHistory.isEmpty || // TODO Jugaad
            _inningsEventHistory.last is! SetBowlerEvent)) {
      return AddBowlerState(innings: innings, selections: _selections);
    }

    // If none of the above conditions are met, the innings is in progress and
    // a ball is to be added.
    return AddBallState(innings: innings, selections: _selections);
  }

  InningsState get initialState => _deduceState();

  void addBall() {
    // Create a ball from the current selections
    final playersInAction = innings.playersInAction;
    final ball = Ball.create(
      bowler: playersInAction.bowler.bowler,
      batter: playersInAction.striker.batter,
      runsScored: _selections.runs,
      battingExtra: _selections.battingExtra,
      bowlingExtra: _selections.bowlingExtra,
      wicket: _selections.wicket,
      isEventOnly: _selections.isEvent,
    );

    // Update the over and ball index for the ball (ex: 4.2, 19.6)
    _updateIndexes(ball);

    // Add the ball to the innings.
    innings.play(ball);

    // Swap strike for odd number of runs.
    // This is mainly a convenience feature, as strike can be set manually
    // via the UI anyway.
    if (ball.runsScored % 2 == 1) _swapStrike();

    // Swap strike whenever an over completes.
    // Since this and the above strike-swap happens before an event is pushed,
    // only one change at most will be visible on the UI.
    if (innings.overs.last.isCompleted) _swapStrike();

    _inningsEventController.add(AddBallEvent(ball: ball));
  }

  void _undoAddBall(AddBallEvent addBallEvent) {
    // Reverse of addBall()

    final ball = addBallEvent.ball;

    if (ball.runsScored % 2 == 1) _swapStrike();
    if (innings.overs.last.isCompleted) _swapStrike();

    innings.unPlay(ball);
  }

  void _updateIndexes(Ball ball) {
    if (innings.balls.isEmpty) {
      ball.overIndex = 0;
      ball.ballIndex = 1;
    } else {
      final lastBall = innings.balls.last;
      if (lastBall.ballIndex == Constants.ballsPerOver) {
        ball.overIndex = lastBall.overIndex + 1;
        ball.ballIndex = 1;
      } else {
        ball.overIndex = lastBall.overIndex;
        ball.ballIndex = lastBall.ballIndex + 1;
      }
    }
    if (!ball.isLegal) {
      ball.ballIndex--;
    }

    // int overIndex = innings.balls.isEmpty ? 0 : innings.balls.last.overIndex;
    // int ballIndex = innings.balls.isEmpty ? 0 : innings.balls.last.ballIndex;
    //
    // if (ball.isLegal) {
    //   ballIndex++;
    //
    //   if (ballIndex > Constants.ballsPerOver) {
    //     ballIndex = 0;
    //     overIndex++;
    //   }
    // }
    //
    // ball.overIndex = overIndex;
    // ball.ballIndex = ballIndex;
  }

  void _swapStrike() {
    final playersInAction = innings.playersInAction;
    if (playersInAction.batter2 == null) {
      return;
    }
    // TODO move to innings?
    if (playersInAction.striker == playersInAction.batter1) {
      playersInAction.striker = playersInAction.batter2!;
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

    _inningsEventController.add(SetBowlerEvent(
      inBowler: inBowlerInnings,
      outBowler: outBowlerInnings,
    ));
  }

  void _undoSetBowler(SetBowlerEvent setBowlerEvent) {
    if (setBowlerEvent.outBowler == null) {
      return;
    }

    innings.removeBowler(setBowlerEvent.inBowler);

    _swapStrike();

    innings.playersInAction.bowler = setBowlerEvent.outBowler!;
  }

  void addBatter(
      {required Player inBatter, required BatterInnings outBatterInnings}) {
    // Add the batter to innings
    final inBatterInnings = innings.addBatter(inBatter, outBatterInnings);

    _inningsEventController.add(
        AddBatterEvent(inBatter: inBatterInnings, outBatter: outBatterInnings));
  }

  void _undoAddBatter(AddBatterEvent addBatterEvent) {
    // Pretty much do the exact reverse of addBatter()

    if (addBatterEvent.outBatter == null) {
      throw StateError("AddBatterEvent does not contain 'OutBatter'");
    }

    innings.removeBatter(addBatterEvent.inBatter,
        restore: addBatterEvent.outBatter!);

    // Reverse "retired" wicket if any
    if (addBatterEvent.outBatter!.isRetired) {
      addBatterEvent.outBatter!.setWicket(null);
    }
  }

  void setStrike(BatterInnings batter) {
    innings.setStrike(batter);
    _inningsEventController.add(ChangeStrikeEvent(striker: batter));
  }

  void undo() {
    if (_inningsEventHistory.isEmpty) {
      if (innings.balls.isNotEmpty) {
        _undoAddBall(AddBallEvent(ball: innings.balls.last));
        _inningsStateController.add(_deduceState());
      }
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

  SetBowlerEvent({required this.inBowler, required this.outBowler});
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
