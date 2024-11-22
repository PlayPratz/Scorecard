import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/cricket_match/models/wicket_model.dart';
import 'package:scorecard/modules/cricket_match/services/innings_service.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/modules/team/models/team_model.dart';
import 'package:scorecard/screens/cricket_game/cricket_score_section.dart';
import 'package:scorecard/screens/cricket_game/next_ball_selector_section.dart';
import 'package:scorecard/screens/cricket_game/players_in_action_section.dart';
import 'package:scorecard/screens/cricket_game/recent_balls_section.dart';

class CricketGameScreen extends StatelessWidget {
  final CricketGameScreenController controller;

  const CricketGameScreen(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final nextBallSelectorController = NextBallSelectorController();
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: _settings, icon: const Icon(Icons.settings)),
        ],
      ),
      body: ListView(
        children: [
          //Cricket Match Tile
          StreamBuilder(
              stream: controller.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  // controller.initialize();
                  return const Center(child: CircularProgressIndicator());
                }
                final state = snapshot.data!;
                return Column(
                  children: [
                    _wScoreSection(controller.game, state),
                    const SizedBox(height: 16),
                    //PlayersInAction
                    PlayersInActionSection(
                      state,
                      onSetStrike: (bi) => controller.setStrike(bi),
                      isFirstTeamBatting: controller.game.lineup1.team.id ==
                          controller.game.currentInnings.battingLineup.team.id,
                      onRetireBowler: (b, r) => controller.retireBowler(b, r),
                      onRetireBatter: (b, r) => controller.retireBatter(b, r),
                      onPickBatter: _pickBatter,
                      onPickBowler: _pickBowler,
                    ),
                    //Recent Balls
                    RecentBallsSection(state.balls),
                  ],
                );
              }),

          //Wicket Selector
          // Wicket
          //Ball Details Selector
          NextBallSelectorSection(nextBallSelectorController),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder(
              stream: controller.stream,
              builder: (context, snapshot) => snapshot.hasData
                  ? _wConfirmButton(snapshot.data!)
                  : const SizedBox(),
            )
          ],
        ),
      ),
    );
  }

  Widget _wScoreSection(CricketGame game, CricketGameScreenState state) =>
      switch (game) {
        LimitedOversGame() => LimitedOversScoreSection(
            game.currentInnings is LimitedOversInningsWithTarget
                ? LimitedOversScoreFirstInningsState(
                    runs: state.runs,
                    wickets: state.wickets,
                    battingTeam: state.battingTeam,
                    bowlingTeam: state.bowlingTeam,
                    currentIndex: state.latestPost.index,
                    oversToBowl: game.rules.oversPerInnings,
                    isLeftTeamBatting: state.battingTeam == game.lineup1.team,
                  )
                : LimitedOversScoreSecondInningsState(
                    runs: state.runs,
                    wickets: state.wickets,
                    battingTeam: state.battingTeam,
                    bowlingTeam: state.bowlingTeam,
                    currentIndex: state.latestPost.index,
                    oversToBowl: game.rules.oversPerInnings,
                    isLeftTeamBatting: state.battingTeam == game.lineup2.team,
                    target: 0,
                  ),
          ),

        // TODO: Handle this case.
        UnlimitedOversGame() => throw UnimplementedError(),
      };

  Widget _wConfirmButton(CricketGameScreenState state) => FilledButton(
      onPressed: _playBall,
      child: switch (state) {
        PickBowlerState() => FilledButton.icon(
            onPressed: _pickBowler,
            icon: const Icon(Icons.person),
            label: const Text("Pick Bowler"),
          ),
        PickBatterState() => FilledButton.icon(
            onPressed: _pickBatter,
            icon: const Icon(Icons.person),
            label: const Text("Pick Batter"),
          ),
        EndInningsState() => FilledButton.icon(
            onPressed: _endInnings,
            icon: const Icon(Icons.done),
            label: const Text("End Innings"),
          ),
        PlayBallState() => FilledButton.icon(
            onPressed: _playBall,
            icon: const Icon(Icons.sports_baseball),
            label: const Text("Play"),
          ),
      });

  void _playBall() {}

  void _pickBatter() {}

  void _pickBowler() {}

  void _endInnings() {}

  void _settings() {}
}

class CricketGameScreenController {
  final CricketGame game;
  // final NextBallSelectorController nextBallSelectionsController;
  CricketGameScreenController(this.game);

  // CricketGameScreenController(
  //   this.game, {
  //   required this.nextBallSelectionsController,
  // });
  // {
  //   _postStream
  //       .listen((post) => _streamController.add(_deduceStateFromPost(post)));
  // }

  final _streamController = StreamController<CricketGameScreenState>();
  Stream<CricketGameScreenState> get stream => _streamController.stream;

  // final _postStreamController = StreamController<InningsPost>();
  // Stream<InningsPost> get _postStream => _postStreamController.stream;

  void _dispatchState() => _streamController.add(_deduceState());

  CricketGameScreenState _deduceState() {
    // _service.postToInnings(game.currentInnings, post);

    final innings = game.currentInnings;
    final lastPost = innings.posts.last;

    switch (lastPost) {
      case BowlerRetire():
        return PickBowlerState(innings);
      case BatterRetire():
      case RunoutBeforeDelivery():
        return PickBatterState(innings);
      case NextBowler():
      case NextBatter():
        return PlayBallState(innings);
      case Ball():
        if (game.currentInnings.isInningsComplete) {
          return EndInningsState(innings);
        } else if (lastPost.isWicket) {
          return PickBatterState(innings);
        } else if (lastPost.index.ball == innings.rules.ballsPerOver) {
          return PickBowlerState(innings);
        }
        return PlayBallState(innings);
    }
  }

  void setStrike(BatterInnings batterInnings) {
    _service.setStrike(currentInnings, batterInnings);
    _dispatchState();
  }

  void retireBatter(BatterInnings batterInnings, RetiredBatter retired) {
    _service.retireBatterInnings(currentInnings, batterInnings, retired);
  }

  void replaceBatter({
    required Player next,
    required BatterInnings? previous,
  }) {
    _service.nextBatter(currentInnings,
        nextBatter: next, previousBatterInnings: previous);
  }

  void retireBowler(BowlerInnings bowlerInnings, RetiredBowler retired) {
    _service.retireBowlerInnings(currentInnings, bowlerInnings, retired);
  }

  void replaceBowler({required Player previous, required Player next}) {
    _service.nextBowler(currentInnings, next);
  }

  void play(PlayBallState playBallState,
      NextBallSelectorEnabledState nextBallSelectorState) {
    if (playBallState.bowler != null && playBallState.striker != null) {
      _service.play(
        currentInnings,
        bowler: playBallState.bowler!.player,
        batter: playBallState.striker!.player,
        runsScored: nextBallSelectorState.nextRuns,
        wicket: nextBallSelectorState.nextWicket,
        bowlingExtra: nextBallSelectorState.nextBowlingExtra,
        battingExtra: nextBallSelectorState.nextBattingExtra,
      );
    } else {
      throw StateError(
          "Attempted to play ball when either the bowler or striker were unset.");
    }
  }

  Innings get currentInnings => game.currentInnings;
  InningsService get _service => InningsService();
}

sealed class CricketGameScreenState {
  // Scoreboard
  final int runs;
  final int wickets;
  final InningsPost latestPost;
  final Team battingTeam;
  final Team bowlingTeam;
  // final InningsIndex currentIndex;
  final GameRules rules;

  // Players in Action
  final BatterInnings? batter1;
  final BatterInnings? batter2;
  final BatterInnings? striker;
  final BowlerInnings? bowler;

  // Balls
  final UnmodifiableListView<Ball> balls;

  CricketGameScreenState(Innings innings)
      : runs = innings.runs,
        wickets = innings.wickets,
        battingTeam = innings.battingLineup.team,
        bowlingTeam = innings.bowlingLineup.team,
        rules = innings.rules,
        latestPost = innings.posts.last,
        batter1 = innings.batter1,
        batter2 = innings.batter2,
        striker = innings.striker,
        bowler = innings.bowler,
        balls = innings.balls;
}

class PickBowlerState extends CricketGameScreenState {
  PickBowlerState(super.innings);
}

class PickBatterState extends CricketGameScreenState {
  PickBatterState(super.innings);
}

class EndInningsState extends CricketGameScreenState {
  EndInningsState(super.innings);
}

class PlayBallState extends CricketGameScreenState {
  PlayBallState(super.innings);
}
