import 'dart:async';

import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/wicket.dart';
import 'package:scorecard/states/containers/innings_selection.dart';

// TODO split into three managers?

class BallDetailsStateController {
  final InningsSelections _selections;

  BallDetailsStateController({required InningsSelections selections})
      : _selections = selections;

  final _runStreamController = StreamController<int>();
  Stream<int> get runStateStream => _runStreamController.stream;

  void selectRuns(int runs) {
    _selections.runs = runs;
    _runStreamController.add(runs);
  }

  final _bowlingExtraStreamController = StreamController<BowlingExtra?>();
  Stream<BowlingExtra?> get bowlingExtraStateStream =>
      _bowlingExtraStreamController.stream;

  void selectBowlingExtra(BowlingExtra? bowlingExtra) {
    _selections.bowlingExtra = bowlingExtra;
    _bowlingExtraStreamController.add(bowlingExtra);

    if (bowlingExtra != null) {
      setEvent(false);
    }
  }

  final _battingExtraStreamController = StreamController<BattingExtra?>();
  Stream<BattingExtra?> get battingExtraStateStream =>
      _battingExtraStreamController.stream;

  void selectBattingExtra(BattingExtra? battingExtra) {
    _selections.battingExtra = battingExtra;
    _battingExtraStreamController.add(battingExtra);

    if (battingExtra != null) {
      setEvent(false);
    }
  }

  final _ballIsEventStreamController = StreamController<bool>();
  Stream<bool> get ballIsEventStreamController =>
      _ballIsEventStreamController.stream;

  void setEvent(bool isEvent) {
    _selections.isEvent = isEvent;
    _ballIsEventStreamController.add(isEvent);

    if (isEvent) {
      selectBattingExtra(null);
      selectBowlingExtra(null);
    }
  }

  final _wicketStreamController = StreamController<Wicket?>();
  Stream<Wicket?> get wicketStateSteam => _wicketStreamController.stream;

  void selectWicket(Wicket? wicket) {
    _selections.wicket = wicket;
    _wicketStreamController.add(wicket);
  }

  void reset() {
    selectRuns(0);
    selectBowlingExtra(null);
    selectBattingExtra(null);
    selectWicket(null);
    setEvent(false);
  }
}

//
// class InningsSelectionstateController {
//   final _inningsSelectionEventController =
//       StreamController<InningsSelectionEvent>();
//
//   final inningsSelectionStateController =
//       StreamController<InningsSelectionState>();
//
//   InningsSelectionstateController() {
//     _inningsSelectionEventController.stream.listen((selectionEvent) {});
//   }
//
//   void setRuns(int runs) {
//     _inningsSelectionEventController.add(RunSelectionEvent(runs: runs));
//   }
//
//   void setBowlingExtra(BowlingExtra bowlingExtra) {
//     _inningsSelectionEventController
//         .add(BowlingExtraSelectionEvent(bowlingExtra: bowlingExtra));
//   }
//
//   void setBattingExtra(BattingExtra battingExtra) {
//     _inningsSelectionEventController
//         .add(BattingExtraSelectionEvent(battingExtra: battingExtra));
//   }
// }
//
// // EVENTS
//
// sealed class InningsSelectionEvent {}
//
// class RunSelectionEvent extends InningsSelectionEvent {
//   final int runs;
//
//   RunSelectionEvent({required this.runs});
// }
//
// class BowlingExtraSelectionEvent extends InningsSelectionEvent {
//   final BowlingExtra? bowlingExtra;
//
//   BowlingExtraSelectionEvent({required this.bowlingExtra});
// }
//
// class BattingExtraSelectionEvent extends InningsSelectionEvent {
//   final BattingExtra? battingExtra;
//
//   BattingExtraSelectionEvent({required this.battingExtra});
// }
//
// // STATES
//
// class InningsSelectionState extends InningsSelections {}
