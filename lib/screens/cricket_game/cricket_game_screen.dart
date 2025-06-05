import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/cricket_match/models/wicket_model.dart';
import 'package:scorecard/modules/cricket_match/services/cricket_match_service.dart';
import 'package:scorecard/modules/cricket_match/services/innings_service.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/modules/team/models/team_model.dart';
import 'package:scorecard/screens/cricket_scorecard/cricket_match_scorecard.dart';
import 'package:scorecard/screens/cricket_game/cricket_score_section.dart';
import 'package:scorecard/screens/cricket_game/next_ball_selector_section.dart';
import 'package:scorecard/screens/cricket_game/players_in_action_section.dart';
import 'package:scorecard/screens/cricket_game/recent_balls_section.dart';
import 'package:scorecard/screens/cricket_match/cricket_match_screen_switcher.dart';
import 'package:scorecard/screens/cricket_match/innings_timeline_screen.dart';
import 'package:scorecard/screens/player/player_list_screen.dart';

class CricketGameScreen extends StatelessWidget {
  final LimitedOversCricketGameScreenController controller;

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
                  onPressed: () => _forfeitInnings(context),
                  icon: const Icon(
                    Icons.dangerous,
                    color: Colors.red,
                  )),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            children: [
              //Cricket Match Tile
              _wScoreSection(context, controller._game, state),
              _wSectionSeparator,
              //PlayersInAction
              _wHeader(context, "Players In Action"),
              PlayersInActionSection(
                state,
                onSetStrike: state is PlayBallState
                    ? (bi) => controller.setStrike(bi)
                    : null,
                isFirstTeamBatting: controller._game.team1 ==
                    controller._game.currentInnings.battingTeam,
                onRetireBowler: (b) => controller.onRetireBowler(b),
                // onRetireBatter: (b, r) => controller.retireBatter(b, r),
                onPickBatter: () => _pickBatter(context),
                onPickBowler: () => _pickBowler(context),
              ),

              _wSectionSeparator,

              // Recent Balls
              _wHeader(context, "Recent Balls"),
              RecentBallsSection(
                state.balls,
                onOpenTimeline: state.latestPost != null
                    ? () => controller.goInningsTimeline(context)
                    : null,
              ),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            height: 250,
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ball Detail Selector
                NextBallSelectorSection(
                  nextBallSelectorController,
                  onSelectWicket: () =>
                      _pickWicket(context, nextBallSelectorController),
                ),
                _wSectionSeparator,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _wUndoButton(),
                    const SizedBox(width: 8),
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
      switch (game.currentInnings) {
        // TODO: Handle this case.
        UnlimitedOversInnings() =>
          throw UnimplementedError("Unlimited Overs :-("),
        // TODO: Handle this case.
        FirstLimitedOversInnings() => LimitedOversScoreSection(
            FirstInningsScoreState(
              score: state.score,
              team1: state.team1,
              team2: state.team2,
              currentIndex: state.latestPost?.index ?? const PostIndex.zero(),
              oversToBowl: (game as LimitedOversGame).rules.oversPerInnings,
              isFirstTeamBatting: state.isFirstTeamBatting,
            ),
            onTap: () => controller.goScorecard(context),
          ),
        // TODO: Handle this case.
        SecondLimitedOversInnings() => LimitedOversScoreSection(
            SecondInningsScoreState(
              score: state.score,
              team1: state.team1,
              team2: state.team2,
              currentIndex: state.latestPost?.index ?? const PostIndex.zero(),
              oversToBowl: (game as LimitedOversGame).rules.oversPerInnings,
              isFirstTeamBatting: state.isFirstTeamBatting,
              target: (game.currentInnings as SecondLimitedOversInnings).target,
            ),
            onTap: () => controller.goScorecard(context),
          ),
      };

  Widget _wConfirmButton(BuildContext context, CricketGameScreenState state,
          NextBallSelectorController nextBallSelectorController) =>
      switch (state) {
        PickBowlerState() => FilledButton.icon(
            onPressed: () => _pickBowler(context),
            icon: const Icon(Icons.sports_baseball),
            label: const Text("Pick Bowler"),
          ),
        PickBatterState() => FilledButton.icon(
            onPressed: () => _pickBatter(context),
            icon: const Icon(Icons.sports_motorsports),
            label: const Text("Pick Batter"),
          ),
        EndInningsState() => FilledButton.icon(
            onPressed: () => controller.onEndInnings(context),
            icon: const Icon(Icons.done),
            label: const Text("End Innings"),
          ),
        PlayBallState() => FilledButton.icon(
            onPressed: () => _playBall(state, nextBallSelectorController),
            icon: const Icon(Icons.sports_baseball),
            label: const Text("Play"),
          ),
        LoadingState() => const FilledButton(onPressed: null, child: null),
      };

  Widget _wUndoButton() => OutlinedButton.icon(
        onPressed: controller.onUndo,
        label: const Text("Undo"),
        icon: const Icon(Icons.undo),
      );

  Widget get _wSectionSeparator => const SizedBox(height: 8);

  Widget _wHeader(BuildContext context, String text) =>
      Text(text, style: Theme.of(context).textTheme.titleSmall);

  void _playBall(PlayBallState playBallState,
          NextBallSelectorController nextBallSelectorController) =>
      controller.onPlay(playBallState, nextBallSelectorController.state);

  void _pickBatter(BuildContext context) => controller.onPickBatter(context);

  void _pickBowler(BuildContext context) => controller.onPickBowler(context);

  void _pickWicket(BuildContext context,
          NextBallSelectorController nextBallSelectorController) =>
      controller.onPickWicket(context, nextBallSelectorController);

  void _forfeitInnings(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Forfeit this Innings?"),
              content: const Text(
                  "This will end the innings. Tap outside to cancel."),
              actions: [
                TextButton(
                    onPressed: () {
                      controller.onForfeitInnings(context);
                    },
                    child: const Text("Forfeit"))
              ],
            ));
  }
}

class LimitedOversCricketGameScreenController {
  final OngoingCricketMatch _cricketMatch;
  final LimitedOversGame _game;
  LimitedOversCricketGameScreenController(this._cricketMatch, this._game);

  final _streamController = StreamController<CricketGameScreenState>();
  Stream<CricketGameScreenState> get stream => _streamController.stream;

  void _dispatchLoading() => _streamController.add(LoadingState(_game));
  void _dispatchState() => _streamController.add(_deduceState());

  CricketGameScreenState _deduceState() {
    final innings = _game.currentInnings;

    if (innings.batter1 == null ||
        innings.batter2 == null ||
        innings.striker == null) {
      return PickBatterState(_game);
    }

    if (innings.bowler == null) {
      return PickBowlerState(_game);
    }

    final lastPost = innings.posts.last;

    switch (lastPost) {
      case BowlerRetire():
        return PickBowlerState(_game);
      case BatterRetire():
      case RunoutBeforeDelivery():
        return PickBatterState(_game);
      case NextBowler():
        return PlayBallState(_game);
      case NextBatter():
        if (lastPost.index.ball == innings.rules.ballsPerOver) {
          return PickBowlerState(_game);
        }
        return PlayBallState(_game);
      case Ball():
        if (_game.currentInnings.isEnded) {
          return EndInningsState(_game);
        } else if (lastPost.isWicket) {
          return PickBatterState(_game);
        } else if (lastPost.index.ball == innings.rules.ballsPerOver) {
          return PickBowlerState(_game);
        }
        return PlayBallState(_game);
    }
  }

  void setStrike(BatterInnings batterInnings) {
    _inningsService.setStrike(currentInnings, batterInnings);
    _dispatchState();
  }

  Future<void> onRetireBatter(
      BatterInnings batterInnings, Retired retired) async {
    _dispatchLoading();
    await _inningsService.retireBatterInnings(
        currentInnings, batterInnings, retired);
    _dispatchState();
  }

  Future<void> onRetireBowler(BowlerInnings bowlerInnings) async {
    _dispatchLoading();
    await _inningsService.retireBowlerInnings(currentInnings, bowlerInnings);
    _dispatchState();
  }

  Future<void> onPickBowler(BuildContext context) async {
    _dispatchLoading();
    final bowler = await _onPickPlayer(
        context, currentInnings.bowlingLineup.players.toList());
    if (bowler != null) {
      await _inningsService.nextBowler(currentInnings, bowler);
    }
    _dispatchState();
  }

  Future<void> onPickBatter(BuildContext context) async {
    _dispatchLoading();
    final batter = await _onPickPlayer(
        context, currentInnings.battingLineup.players.toList());
    if (batter != null) {
      await _inningsService.nextBatter(currentInnings, batter);
    }
    _dispatchState();
  }

  Future<Player?> _onPickPlayer(
      BuildContext context, List<Player> players) async {
    final player = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PickPlayerScreen(players,
              onSelectPlayer: (p) => Navigator.pop(context, p)),
        ));
    if (player is Player) {
      return player;
    } else {
      return null;
    }
  }

  Future<void> onPickWicket(BuildContext context,
      NextBallSelectorController nextBallSelectorController) async {
    final wicket = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _WicketPickerScreen(
            striker: currentInnings.striker!,
            nonStriker: currentInnings.nonStriker!,
            bowler: currentInnings.bowler!,
            fieldingPlayers: currentInnings.bowlingLineup.players,
          ),
        ));

    if (wicket is Wicket) {
      nextBallSelectorController.nextWicket = wicket;
    } else if (wicket is Retired) {
      // TODO Improve
      final batterInnings = _inningsService.getBatterInningsOfPlayer(
          currentInnings, wicket.batter)!;
      await onRetireBatter(batterInnings, wicket);
    }
  }

  void goScorecard(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CricketMatchScorecard(_cricketMatch, _game)));
  }

  void goInningsTimeline(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => InningsTimelineScreen(_game.currentInnings)));
  }

  Future<void> onPlay(PlayBallState playBallState,
      NextBallSelectorState nextBallSelectorState) async {
    nextBallSelectorState as NextBallSelectorEnabledState;
    if (playBallState.bowler != null && playBallState.striker != null) {
      _dispatchLoading();
      await _inningsService.play(
        currentInnings,
        bowler: playBallState.bowler!.player,
        batter: playBallState.striker!.player,
        runsScored: nextBallSelectorState.nextRuns,
        wicket: nextBallSelectorState.nextWicket,
        bowlingExtraType: nextBallSelectorState.nextBowlingExtra,
        battingExtraType: nextBallSelectorState.nextBattingExtra,
      );
      _dispatchState();
    } else {
      throw StateError(
          "Attempted to play ball when either the bowler or striker were unset.");
    }
  }

  Future<void> onUndo() async {
    _dispatchLoading();
    await _inningsService.undoPostFromInnings(currentInnings);
    _dispatchState();
  }

  void onForfeitInnings(BuildContext context) {
    _inningsService.forfeitInnings(currentInnings);
    _dispatchState();
  }

  Future<void> onEndInnings(BuildContext context) async {
    await _matchService.endCurrentInnings(_cricketMatch, _game);
  }

  Innings get currentInnings => _game.currentInnings;
  InningsService get _inningsService => InningsService();
  LimitedOversMatchService get _matchService => LimitedOversMatchService();
}

sealed class CricketGameScreenState {
  // Scoreboard
  final Score score;
  final InningsPost? latestPost;
  final Team team1;
  final Team team2;
  final bool isFirstTeamBatting;
  // final InningsIndex currentIndex;
  final GameRules rules;

  // Players in Action
  final BatterInnings? batter1;
  final BatterInnings? batter2;
  final BatterInnings? striker;
  final BowlerInnings? bowler;

  // Balls
  final UnmodifiableListView<Ball> balls;

  CricketGameScreenState._({
    required this.score,
    required this.latestPost,
    required this.team1,
    required this.team2,
    required this.isFirstTeamBatting,
    required this.rules,
    required this.batter1,
    required this.batter2,
    required this.striker,
    required this.bowler,
    required this.balls,
  });

  CricketGameScreenState(CricketGame game)
      : this._(
          score: game.currentInnings.score,
          team1: game.team1,
          team2: game.team2,
          isFirstTeamBatting: game.team1 == game.currentInnings.battingTeam,
          rules: game.currentInnings.rules,
          latestPost: game.currentInnings.posts.lastOrNull,
          batter1: game.currentInnings.batter1,
          batter2: game.currentInnings.batter2,
          striker: game.currentInnings.striker,
          bowler: game.currentInnings.bowler,
          balls: game.currentInnings.balls,
        );
}

class LoadingState extends CricketGameScreenState {
  LoadingState(super.game); // TODO this should probably be empty
}

class PickBowlerState extends CricketGameScreenState {
  PickBowlerState(super.game);
}

class PickBatterState extends CricketGameScreenState {
  PickBatterState(super.game);
}

class EndInningsState extends CricketGameScreenState {
  EndInningsState(super.game);
}

class PlayBallState extends CricketGameScreenState {
  PlayBallState(super.game);
}

class _WicketPickerScreen extends StatefulWidget {
  final BatterInnings striker;
  final BatterInnings? nonStriker;
  final BowlerInnings bowler;

  final Iterable<Player> fieldingPlayers;

  const _WicketPickerScreen({
    required this.striker,
    required this.nonStriker,
    required this.bowler,
    required this.fieldingPlayers,
  });

  @override
  State<_WicketPickerScreen> createState() => _WicketPickerScreenState();
}

class _WicketPickerScreenState extends State<_WicketPickerScreen> {
  Dismissal? _wicketDismissal;
  Player? _wicketBatter;
  Player? _wicketFielder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        children: [
          for (final dismissal in Dismissal.values) wDismissalTile(dismissal),
          if (_wicketDismissal != null &&
              canBatterBeNonStriker(_wicketDismissal!))
            wPickBatter(),
          if (_wicketDismissal != null && requiresFielder(_wicketDismissal!))
            wPickFielder(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: canReturnWicket ? returnWicket : null,
              label: const Text("Add Wicket"),
              icon: const Icon(Icons.stacked_bar_chart),
            )
          ],
        ),
      ),
    );
  }

  Widget wDismissalTile(Dismissal dismissal) => wSelectableOption(
        stringifyWicketName(dismissal),
        onSelect: () => setDismissal(dismissal),
        isSelected: _wicketDismissal == dismissal,
      );

  Widget wPickBatter() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 32),
          wSectionHeader("Pick Batter"),
          for (final batter in [widget.striker, widget.nonStriker])
            wSelectableOption(
              batter!.player.name,
              isSelected: batter.player == _wicketBatter,
              onSelect: () => setBatter(batter.player),
            )
        ],
      );

  Widget wPickFielder() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 32),
          wSectionHeader(_wicketDismissal == Dismissal.stumped
              ? "Pick Wicket-Keeper"
              : "Pick Fielder"),
          for (final fielder in widget.fieldingPlayers)
            wSelectableOption(
              fielder.name,
              isSelected: fielder == _wicketFielder,
              onSelect: () => setFielder(fielder),
            )
        ],
      );

  Widget wSelectableOption(String name,
          {void Function()? onSelect, bool isSelected = false}) =>
      ListTile(
        title: Text(name),
        selected: isSelected,
        // selectedTileColor: Colors.greenAccent,
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.teal)
            : null,
        onTap: onSelect,
      );

  Widget wSectionHeader(String text) => Text(text);

  bool requiresBowler(Dismissal dismissal) => switch (dismissal) {
        Dismissal.bowled => true,
        Dismissal.hitWicket => true,
        Dismissal.lbw => true,
        Dismissal.caught => true,
        Dismissal.stumped => true,
        Dismissal.runOut => false,
        Dismissal.timedOut => false,
        Dismissal.retired => false,
        Dismissal.retiredHurt => false,
      };

  bool requiresFielder(Dismissal dismissal) => switch (dismissal) {
        Dismissal.bowled => false,
        Dismissal.hitWicket => false,
        Dismissal.lbw => false,
        Dismissal.caught => true,
        Dismissal.stumped => true,
        Dismissal.runOut => true,
        Dismissal.timedOut => false,
        Dismissal.retired => false,
        Dismissal.retiredHurt => false,
      };

  bool canBatterBeNonStriker(Dismissal dismissal) => switch (dismissal) {
        Dismissal.bowled => false,
        Dismissal.hitWicket => false,
        Dismissal.lbw => false,
        Dismissal.caught => false,
        Dismissal.stumped => false,
        Dismissal.runOut => true,
        Dismissal.timedOut => true,
        Dismissal.retired => true,
        Dismissal.retiredHurt => true,
      };

  String stringifyWicketName(Dismissal dismissal) => switch (dismissal) {
        Dismissal.bowled => "Bowled",
        Dismissal.hitWicket => "Hit Wicket",
        Dismissal.lbw => "LBW",
        Dismissal.caught => "Caught",
        Dismissal.stumped => "Stumped",
        Dismissal.runOut => "Run out",
        Dismissal.timedOut => "Timed out",
        Dismissal.retired => "Retired",
        Dismissal.retiredHurt => "Retired Hurt",
      };

  void setDismissal(Dismissal dismissal) {
    setState(() {
      _wicketDismissal = dismissal;
      _wicketBatter = null;
      _wicketFielder = null;
    });
  }

  void setBatter(Player batter) {
    setState(() {
      _wicketBatter = batter;
    });
  }

  void setFielder(Player fielder) {
    setState(() {
      _wicketFielder = fielder;
    });
  }

  bool get canReturnWicket {
    if (_wicketDismissal == null) return false;

    if (requiresFielder(_wicketDismissal!) && _wicketFielder == null) {
      return false;
    }

    if (canBatterBeNonStriker(_wicketDismissal!) && _wicketBatter == null) {
      return false;
    }

    return true;
  }

  void returnWicket() {
    if (!canReturnWicket) {
      return;
    }

    final result = switch (_wicketDismissal!) {
      Dismissal.bowled => BowledWicket(
          batter: widget.striker.player, bowler: widget.bowler.player),
      Dismissal.hitWicket =>
        HitWicket(batter: widget.striker.player, bowler: widget.bowler.player),
      Dismissal.lbw =>
        LbwWicket(batter: widget.striker.player, bowler: widget.bowler.player),
      Dismissal.caught => CaughtWicket(
          batter: widget.striker.player,
          bowler: widget.bowler.player,
          fielder: _wicketFielder!),
      Dismissal.stumped => StumpedWicket(
          batter: widget.striker.player,
          bowler: widget.bowler.player,
          wicketkeeper: _wicketFielder!),
      Dismissal.runOut =>
        RunoutWicket(batter: _wicketBatter!, fielder: _wicketFielder!),
      Dismissal.timedOut => TimedOutWicket(batter: _wicketBatter!),
      Dismissal.retired => RetiredDeclared(batter: _wicketBatter!),
      Dismissal.retiredHurt => RetiredHurt(batter: _wicketBatter!),
    };

    Navigator.pop(context, result);
  }
}
