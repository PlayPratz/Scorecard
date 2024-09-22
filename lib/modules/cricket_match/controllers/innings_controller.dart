import 'dart:async';

import 'package:scorecard/modules/cricket_match/models/innings_model.dart';

/*
    How This Class Works:

    This State Controller uses two Streams - one for Events, one for States.
    Whenever an Event is added to the stream, the [_deduceState] function is
    called (since the a listener is registered for the Event Stream). This
    function now figures out the desired state of the Innings and and adds it
    to the State Stream. The UI component has a StreamBuilder that listens
    to this State Stream, thereby rebuilding the UI for every Event.

    An Event is added to the Event Stream whenever a function exposed by this
    State Controller is called. This function is usually called due to some
    user interaction.
 */

class InningsController {
  final Innings innings;

  // final _eventController = StreamController<InningsEvent>();
  final _stateController = StreamController<InningsState>();
  Stream<InningsState> get stateStream => _stateController.stream;

  InningsController(this.innings);
}

sealed class InningsState {}
