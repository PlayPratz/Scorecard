import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/cricket_match/models/wicket_model.dart';
import 'package:scorecard/modules/cricket_match/services/innings_service.dart';

class CricketGameScreen extends StatelessWidget {
  final CricketGame game;

  const CricketGameScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          // //Cricket Match Tile
          // _CricketMatchTile(),
          // //PlayersInAction
          // _PlayersInActionSection(),
          // //Recent Balls
          // _RecentBallsSection(),
          // //Wicket Selector
          // _WicketSelector(),
          // //Ball Details Selector
          // BallDetailsSelector(),
          // //
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: _playBall,
              icon: const Icon(Icons.sports_baseball),
              label: const Text("Play"),
            )
          ],
        ),
      ),
    );
  }

  void _playBall() {}
}

class CricketGameScreenController {
  final CricketGame game;

  final NextBallSelectionsController nextBallSelectionsController;

  CricketGameScreenController(
    this.game, {
    required this.nextBallSelectionsController,
  }) {
    _postStream
        .listen((post) => _streamController.add(_deduceStateFromPost(post)));
  }

  final _streamController = StreamController<CricketGameScreenState>();
  Stream<CricketGameScreenState> get stream => _streamController.stream;

  final _postStreamController = StreamController<InningsPost>();
  Stream<InningsPost> get _postStream => _postStreamController.stream;

  CricketGameScreenState _deduceStateFromPost(InningsPost post) {
    _service.postToInnings(game.currentInnings, post);

    final innings = game.currentInnings;
    final lastPost = innings.posts.last;

    switch (lastPost) {
      case BatterRetire():
      case NonStrikerRunout():
        return SelectBatterState(innings);
      case NextBowler():
      case NextBatter():
        return PlayBallState(innings);
      case Ball():
        if (game.currentInnings.isInningsComplete) {
          return EndInningsState(innings);
        } else if (lastPost.isWicket) {
          return SelectBatterState(innings);
        } else if (lastPost.index.ball == innings.rules.ballsPerOver) {
          return SelectBowlerState(innings);
        }
        return PlayBallState(innings);
    }
  }

  InningsService get _service => GetIt.I.get<InningsService>();
}

sealed class CricketGameScreenState {
  // Scoreboard
  final int runs;
  final int wickets;
  final InningsPost latestPost;

  // Players in Action
  final BatterInnings? batter1;
  final BatterInnings? batter2;
  final BatterInnings? striker;
  final BowlerInnings? bowler;

  CricketGameScreenState(Innings innings)
      : runs = innings.runs,
        wickets = innings.wickets,
        latestPost = innings.posts.last,
        batter1 = innings.batter1,
        batter2 = innings.batter2,
        striker = innings.striker,
        bowler = innings.bowler;
}

class SelectBowlerState extends CricketGameScreenState {
  SelectBowlerState(super.innings);
}

class SelectBatterState extends CricketGameScreenState {
  SelectBatterState(super.innings);
}

class EndInningsState extends CricketGameScreenState {
  EndInningsState(super.innings);
}

class PlayBallState extends CricketGameScreenState {
  PlayBallState(super.innings);
}

class NextBallSelectionsController {
  final _selectionStreamController = StreamController<NextBallSelectionState>();
  Stream<NextBallSelectionState> get stream =>
      _selectionStreamController.stream;

  void _dispatchState() {
    _selectionStreamController.add(state);
  }

  NextBallSelectionState get state => NextBallSelectionState(
        nextRuns: nextRuns,
        nextBowlingExtra: nextBowlingExtra,
        nextBattingExtra: nextBattingExtra,
        nextWicket: nextWicket,
      );

  // Selections
  int _nextRuns = 0;
  int get nextRuns => _nextRuns;
  set nextRuns(int x) {
    _nextRuns = x;
    _dispatchState();
  }

  BowlingExtra? _nextBowlingExtra;
  BowlingExtra? get nextBowlingExtra => _nextBowlingExtra;
  set nextBowlingExtra(BowlingExtra? x) {
    _nextBowlingExtra = x;
    _dispatchState();
  }

  BattingExtra? _nextBattingExtra;
  BattingExtra? get nextBattingExtra => _nextBattingExtra;
  set nextBattingExtra(BattingExtra? x) {
    _nextBattingExtra = x;
    _dispatchState();
  }

  Wicket? _nextWicket;
  Wicket? get nextWicket => _nextWicket;
  set nextWicket(Wicket? x) {
    _nextWicket = x;
    _dispatchState();
  }
}

class NextBallSelectionState {
  final int nextRuns;
  final BowlingExtra? nextBowlingExtra;
  final BattingExtra? nextBattingExtra;
  final Wicket? nextWicket;

  NextBallSelectionState({
    required this.nextRuns,
    required this.nextBowlingExtra,
    required this.nextBattingExtra,
    required this.nextWicket,
  });
}
