import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/services/cricket_match_service.dart';
import 'package:scorecard/screens/cricket_match/cricket_match_scorecard.dart';
import 'package:scorecard/screens/cricket_game/cricket_game_screen.dart';
import 'package:scorecard/screens/cricket_match/review_cricket_match_screen.dart';
import 'package:scorecard/screens/cricket_match/initialize_cricket_match_screen.dart';

class CricketMatchScreenSwitcher extends StatelessWidget {
  final CricketMatch cricketMatch;

  const CricketMatchScreenSwitcher(this.cricketMatch, {super.key});

  @override
  Widget build(BuildContext context) {
    final controller = CricketMatchScreenSwitcherController(cricketMatch);
    return StreamBuilder(
        stream: controller._stream,
        initialData: _CMSSLoadingState(),
        builder: (context, snapshot) => switch (snapshot.data!) {
              _CMSSLoadingState() => loadingScreen,
              _CMSSLoadedState() => getScreen(context, cricketMatch),
            });
  }

  Widget get loadingScreen => Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
        bottomNavigationBar: const BottomAppBar(),
      );

  Widget getScreen(BuildContext context, CricketMatch cricketMatch) {
    switch (cricketMatch) {
      case CompletedCricketMatch():
        return CricketMatchScorecard(cricketMatch);
      case OngoingCricketMatch():
        final controller = CricketGameScreenController(cricketMatch);
        return CricketGameScreen(controller);
      case InitializedCricketMatch():
        final controller = ReviewCricketGameScreenController(cricketMatch);
        return ReviewCricketGameScreen(controller);
      case ScheduledCricketMatch():
        final controller = InitializeCricketMatchScreenController(cricketMatch);
        return InitializeCricketMatchScreen(controller);
    }
    throw UnsupportedError(
        "Attempted to open match that was not of the defined types (id: ${cricketMatch.id}");
  }
}

sealed class _CMSSState {}

class _CMSSLoadingState extends _CMSSState {}

class _CMSSLoadedState extends _CMSSState {}

class CricketMatchScreenSwitcherController {
  final CricketMatch cricketMatch;

  CricketMatchScreenSwitcherController(this.cricketMatch) {
    loadCricketGame();
  }

  final _streamController = StreamController<_CMSSState>();
  Stream<_CMSSState> get _stream => _streamController.stream;

  Future<void> loadCricketGame() async {
    _streamController.add(_CMSSLoadingState());

    final cricketMatch = this.cricketMatch;
    if (cricketMatch is InitializedCricketMatch) {
      await CricketMatchService().getGameForMatch(cricketMatch);
    }

    _streamController.add(_CMSSLoadedState());
  }
}
