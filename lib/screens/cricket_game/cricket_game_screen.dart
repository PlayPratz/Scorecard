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
import 'package:scorecard/screens/cricket_game/cricket_game_scorecard.dart';
import 'package:scorecard/screens/cricket_game/cricket_score_section.dart';
import 'package:scorecard/screens/cricket_game/next_ball_selector_section.dart';
import 'package:scorecard/screens/cricket_game/players_in_action_section.dart';
import 'package:scorecard/screens/cricket_game/recent_balls_section.dart';
import 'package:scorecard/screens/player/player_list_screen.dart';

class CricketGameScreen extends StatelessWidget {
  final CricketGameScreenController controller;

  const CricketGameScreen(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final nextBallSelectorController = NextBallSelectorController();
    return StreamBuilder(
      stream: controller.stream,
      initialData: controller._deduceState(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final state = snapshot.data!;

        if (state is PlayBallState) {
          nextBallSelectorController.reset();
        } else {
          nextBallSelectorController.disable();
        }

        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: _settings, icon: const Icon(Icons.settings)),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView(
              children: [
                //Cricket Match Tile
                _wScoreSection(context, controller.game, state),
                _wSectionSeperator,

                //PlayersInAction
                _wHeader(context, "Players In Action"),
                PlayersInActionSection(
                  state,
                  onSetStrike: (bi) => controller.setStrike(bi),
                  isFirstTeamBatting: controller.game.lineup1.team ==
                      controller.game.currentInnings.battingLineup.team,
                  onRetireBowler: (b, r) => controller.retireBowler(b, r),
                  onRetireBatter: (b, r) => controller.retireBatter(b, r),
                  onPickBatter: () => _pickBatter(context),
                  onPickBowler: () => _pickBowler(context),
                ),

                _wSectionSeperator,

                // Recent Balls
                _wHeader(context, "Recent Balls"),
                RecentBallsSection(state.balls),

                //Wicket Selector
                // Wicket
                //Ball Details Selector
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            height: 220,
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _wHeader(context, "Record Next Ball"),
                _wSectionSeperator,
                NextBallSelectorSection(nextBallSelectorController),
                _wSectionSeperator,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _wUndoButton(),
                    _wSectionSeperator,
                    Expanded(
                        child: _wConfirmButton(
                            context, state, nextBallSelectorController)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _wScoreSection(BuildContext context, CricketGame game,
          CricketGameScreenState state) =>
      switch (game) {
        LimitedOversGame() => LimitedOversScoreSection(
            game.currentInnings is LimitedOversInningsWithTarget
                ? LimitedOversScoreFirstInningsState(
                    runs: state.runs,
                    wickets: state.wickets,
                    battingTeam: state.battingTeam,
                    bowlingTeam: state.bowlingTeam,
                    currentIndex:
                        state.latestPost?.index ?? const InningsIndex.zero(),
                    oversToBowl: game.rules.oversPerInnings,
                    isFirstTeamBatting: state.battingTeam == game.lineup1.team,
                  )
                : LimitedOversScoreSecondInningsState(
                    runs: state.runs,
                    wickets: state.wickets,
                    battingTeam: state.battingTeam,
                    bowlingTeam: state.bowlingTeam,
                    currentIndex:
                        state.latestPost?.index ?? const InningsIndex.zero(),
                    oversToBowl: game.rules.oversPerInnings,
                    isFirstTeamBatting: state.battingTeam == game.lineup1.team,
                    target: 0,
                  ),
            onTap: () => controller.showScorecard(context),
          ),

        // TODO: Handle this case.
        UnlimitedOversGame() => throw UnimplementedError(),
      };

  Widget _wConfirmButton(BuildContext context, CricketGameScreenState state,
          NextBallSelectorController nextBallSelectorController) =>
      switch (state) {
        PickBowlerState() => FilledButton.icon(
            onPressed: () => _pickBowler(context),
            icon: const Icon(Icons.person),
            label: const Text("Pick Bowler"),
          ),
        PickBatterState() => FilledButton.icon(
            onPressed: () => _pickBatter(context),
            icon: const Icon(Icons.person),
            label: const Text("Pick Batter"),
          ),
        EndInningsState() => FilledButton.icon(
            onPressed: _endInnings,
            icon: const Icon(Icons.done),
            label: const Text("End Innings"),
          ),
        PlayBallState() => FilledButton.icon(
            onPressed: () => _playBall(state, nextBallSelectorController),
            icon: const Icon(Icons.sports_baseball),
            label: const Text("Play"),
          ),
      };

  Widget _wUndoButton() => OutlinedButton.icon(
        onPressed: controller.undo,
        label: const Text("Undo"),
        icon: const Icon(Icons.undo),
      );

  Widget get _wSectionSeperator => const SizedBox(height: 12);

  Widget _wHeader(BuildContext context, String text) =>
      Text(text, style: Theme.of(context).textTheme.titleSmall);

  void _playBall(PlayBallState playBallState,
          NextBallSelectorController nextBallSelectorController) =>
      controller.play(playBallState, nextBallSelectorController.state);

  void _pickBatter(BuildContext context) => controller.pickBatter(context);

  void _pickBowler(BuildContext context) => controller.pickBowler(context);

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

  // late final Stream<CricketGameScreenState> stream =
  //     _streamController.stream.asBroadcastStream();

  // final _postStreamController = StreamController<InningsPost>();
  // Stream<InningsPost> get _postStream => _postStreamController.stream;

  void _dispatchState() => _streamController.add(_deduceState());

  CricketGameScreenState _deduceState() {
    // _service.postToInnings(game.currentInnings, post);

    final innings = game.currentInnings;

    if (innings.batter1 == null ||
        innings.batter2 == null ||
        innings.striker == null) {
      return PickBatterState(innings);
    }

    if (innings.bowler == null) {
      return PickBowlerState(innings);
    }

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

  void replaceBatter(Player nextBatter) {
    _service.nextBatter(currentInnings, nextBatter);
  }

  void retireBowler(BowlerInnings bowlerInnings, RetiredBowler retired) {
    _service.retireBowlerInnings(currentInnings, bowlerInnings, retired);
  }

  void replaceBowler({required Player previous, required Player next}) {
    _service.nextBowler(currentInnings, next);
  }

  Future<void> pickBowler(BuildContext context) async {
    final bowler = await _pickPlayer(
        context, currentInnings.bowlingLineup.players.toList());
    if (bowler != null) {
      _service.nextBowler(currentInnings, bowler);
      _dispatchState();
    }
  }

  Future<void> pickBatter(BuildContext context) async {
    final batter = await _pickPlayer(
        context, currentInnings.battingLineup.players.toList());
    if (batter != null) {
      _service.nextBatter(currentInnings, batter);
      _dispatchState();
    }
  }

  Future<Player?> _pickPlayer(
      BuildContext context, List<Player> players) async {
    final player = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerListScreen(players,
              onSelectPlayer: (p) => Navigator.pop(context, p)),
        ));
    if (player is Player) {
      return player;
    } else {
      return null;
    }
  }

  void showScorecard(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => CricketGameScorecard(game)));
  }

  void play(PlayBallState playBallState,
      NextBallSelectorState nextBallSelectorState) {
    // assert(nextBallSelectorState is NextBallSelectorEnabledState);
    nextBallSelectorState as NextBallSelectorEnabledState;
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
      _dispatchState();
    } else {
      throw StateError(
          "Attempted to play ball when either the bowler or striker were unset.");
    }
  }

  void undo() {
    _service.undoPostFromInnings(currentInnings);
    _dispatchState();
  }

  Innings get currentInnings => game.currentInnings;
  InningsService get _service => InningsService();
}

sealed class CricketGameScreenState {
  // Scoreboard
  final int runs;
  final int wickets;
  final InningsPost? latestPost;
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
        latestPost = innings.posts.lastOrNull,
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
