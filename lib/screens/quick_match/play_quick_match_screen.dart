import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/modules/cache/player_cache.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/modules/quick_match/post_ball_and_extras_model.dart';
import 'package:scorecard/modules/quick_match/quick_match_model.dart';
import 'package:scorecard/modules/quick_match/wicket_model.dart';
import 'package:scorecard/screens/player/player_list_screen.dart';
import 'package:scorecard/screens/quick_match/innings_timeline_screen.dart';
import 'package:scorecard/screens/quick_match/load_quick_match_screen.dart';
import 'package:scorecard/screens/quick_match/scorecard_screen.dart';
import 'package:scorecard/services/quick_match_service.dart';
import 'package:scorecard/ui/ball_colors.dart';
import 'package:scorecard/ui/stringify.dart';

class PlayQuickInningsScreen extends StatefulWidget {
  final int inningsId;

  const PlayQuickInningsScreen(this.inningsId, {super.key});

  @override
  State<PlayQuickInningsScreen> createState() => _PlayQuickInningsScreenState();
}

class _PlayQuickInningsScreenState extends State<PlayQuickInningsScreen> {
  late final _PlayQuickMatchScreenController controller;
  late final QuickMatchService service;

  @override
  void initState() {
    super.initState();
    service = context.read<QuickMatchService>();
    controller = _PlayQuickMatchScreenController(widget.inningsId, service);
    controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: controller._stateStream,
        initialData: _InitializingState(),
        builder: (context, snapshot) {
          final state = snapshot.data;
          if (state == null || state is _InitializingState) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("Loading..."),
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            final innings = (state as _QuickMatchLoadedState).innings;
            final canDeclare = state is! _InningsHasEndedState;
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    onPressed: () => _quitMatch(context),
                    icon: const Icon(Icons.exit_to_app)),
                title:
                    Text(Stringify.quickInningsHeading(innings.inningsNumber)),
                actions: [
                  FilledButton.tonalIcon(
                    onPressed: canDeclare
                        ? () => showEndInningsWarning(context)
                        : null,
                    onLongPress: canDeclare
                        ? () => controller.declareInnings(context)
                        : null,
                    label: const Text("Declare"),
                    icon: const Icon(
                      Icons.cancel,
                      color: Colors.redAccent,
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      backgroundColor: Colors.redAccent.withOpacity(0.2),
                    ),
                  )
                ],
              ),
              body: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                child: Column(
                  children: [
                    _ScoreBar(
                      score: innings.score,
                      currentRunRate: innings.currentRunRate,
                      ballsBowled: innings.balls,
                      maxBalls: innings.ballLimit,
                      ballsPerOver: innings.ballsPerOver,
                      target: innings.target,
                      requiredRunRate: innings.requiredRunRate,
                      runsRequired: innings.runsRequired,
                      ballsLeft: innings.ballsLeft,
                      isLoading: state is _ActionLoadingState,
                    ),
                    _RecentBallsSection(
                      state.recentBalls.whereType<Ball>().toList(),
                      onOpenTimeline: () => controller.goTimeline(context),
                    ),
                    const Spacer(),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: ListTile(
                    //         title: const Text("Rotate Strike"),
                    //         titleTextStyle:
                    //             Theme.of(context).textTheme.bodySmall,
                    //         trailing: Switch(
                    //             value: controller.autoRotateStrike,
                    //             onChanged: (_) =>
                    //                 controller.toggleAutoRotateStrike()),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    _OnCreasePlayers(
                      batter1: state.batter1,
                      batter2: state.batter2,
                      bowler: state.bowler,
                      ballsPerOver: innings.ballsPerOver,
                      strikerSlot: innings.striker,
                      isOutBowler: state is _PickBowlerState,
                      onPickBatter: () => controller.pickBatter(context, null),
                      onPickBowler: () => controller.pickBowler(context),
                      onRetireBatter: (batterId) =>
                          controller.retireBatter(batterId),
                      onRetireBowler: (bowlerId) => controller.retireBowler(),
                      onSetStrike: (batterId) => controller.setStrike(batterId),
                      allowInput: state is _PlayBallState,
                      goScorecard: controller.goScorecard,
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              bottomNavigationBar: BottomAppBar(
                height: 230,
                child: Column(
                  children: [
                    _NextBallSelectorSection(
                      controller.ballController,
                      onSelectWicket: () => controller.pickWicket(context),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Row(
                        children: [
                          _wUndoButton(controller, state.canUndo),
                          const SizedBox(width: 4),
                          Expanded(
                            child: SizedBox.expand(
                              child:
                                  _wConfirmButton(context, controller, state),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        });
  }

  Widget _wConfirmButton(
          BuildContext context,
          _PlayQuickMatchScreenController controller,
          _QuickMatchLoadedState state) =>
      switch (state) {
        _PickBowlerState() => FilledButton.icon(
            onPressed: () => controller.pickBowler(context),
            label: const Text("Pick Bowler"),
            icon: const Icon(Icons.person),
          ),
        _PickBatterState() => FilledButton.icon(
            onPressed: () => controller.pickBatter(
              context,
              state.toReplaceId,
            ),
            label: const Text("Pick Batter"),
            icon: const Icon(Icons.person),
          ),
        _InningsHasEndedState() => FilledButton.icon(
            onPressed: () => showEndInningsWarning(context),
            onLongPress: () => controller.finishInnings(context, state.next),
            label: const Text("Finish"),
            icon: const Icon(Icons.check_circle),
          ),
        _PlayBallState() => FilledButton.icon(
            onPressed: () => controller.playBall(),
            label: const Text("Play Ball"),
            icon: const Icon(Icons.sports_baseball),
          ),
        _ActionLoadingState() => FilledButton.icon(
            onPressed: null,
            label: const Text("Loading..."),
            icon: const SizedBox.square(
              dimension: 18,
              child: LinearProgressIndicator(),
            ),
          ),
      };

  Widget _wUndoButton(
          _PlayQuickMatchScreenController controller, bool canUndo) =>
      OutlinedButton.icon(
        onPressed: canUndo ? () => controller.undo() : null,
        label: const Text("Undo"),
        icon: const Icon(Icons.undo),
      );

  void showEndInningsWarning(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text("Long press to end this innings (This can't be undone!)")));
  }

  Future<void> _quitMatch(BuildContext context) async {
    Navigator.pop(context);
  }
}

// STATES

class _PlayQuickMatchScreenController {
  final int inningsId;
  final QuickMatchService _matchService;

  final ballController = _NextBallSelectorController();

  _PlayQuickMatchScreenController(this.inningsId, this._matchService);

  late QuickInnings innings;
  BattingScore? batter1;
  BattingScore? batter2;
  BowlingScore? bowler;
  InningsPost? lastPost;
  bool get canUndo => lastPost != null;
  late UnmodifiableListView<Ball> recentBalls;

  final _stateStreamController = StreamController<_PlayQuickMatchState>();
  Stream<_PlayQuickMatchState> get _stateStream =>
      _stateStreamController.stream;

  Future<void> initialize() async {
    _stateStreamController.add(_InitializingState());
    _dispatchState();
  }

  void _dispatchLoading() => _stateStreamController.add(_ActionLoadingState(
        innings,
        recentBalls,
        batter1,
        batter2,
        bowler,
        canUndo,
      ));

  Future<void> _dispatchState() async =>
      _stateStreamController.add(await _deduceState());

  Future<_QuickMatchLoadedState> _deduceState() async {
    ballController.disable();

    // Reload innings
    innings = await _matchService.getInnings(inningsId);
    recentBalls = await _matchService.getRecentBallsOf(innings);

    batter1 = innings.batter1Id != null
        ? await _matchService.getLastBattingScoreOf(innings, innings.batter1Id!)
        : null;
    batter2 = innings.batter2Id != null
        ? await _matchService.getLastBattingScoreOf(innings, innings.batter2Id!)
        : null;
    bowler = innings.bowlerId != null
        ? await _matchService.getBowlingScoreOf(innings, innings.bowlerId!)
        : null;

    lastPost = await _matchService.getLastPostOf(innings);

    if (innings.status == 9 || innings.isEnded) {
      return _InningsHasEndedState(
        innings,
        recentBalls,
        batter1,
        batter2,
        bowler,
        canUndo,
        next: _matchService.getNextState(innings),
      );
    }

    if (innings.batter1Id == null) {
      // A batter must be picked
      return _PickBatterState(
          innings, recentBalls, batter1, batter2, bowler, canUndo,
          toReplaceId: null);
    }

    if (batter1 != null && batter1!.isOut) {
      // Need to replace this batter
      return _PickBatterState(
          innings, recentBalls, batter1, batter2, bowler, canUndo,
          toReplaceId: batter1!.batterId);
    }

    if (batter2 != null && batter2!.isOut) {
      // Need to replace this batter
      return _PickBatterState(
          innings, recentBalls, batter1, batter2, bowler, canUndo,
          toReplaceId: batter2!.batterId);
    }

    if (innings.bowlerId == null ||
        recentBalls.isNotEmpty &&
            recentBalls.first.index.ball == innings.ballsPerOver &&
            recentBalls.first.bowlerId == innings.bowlerId) {
      // A bowler must be picked
      // OR the current bowler bowled the last legal ball of the current over
      return _PickBowlerState(
          innings, recentBalls, batter1, batter2, bowler, canUndo);
    }

    if (lastPost == null) {
      // Just a safety trap in case there are no posts
      // Ideally in this case, it should still be innings.batter1Id == null
      return _PickBowlerState(
          innings, recentBalls, batter1, batter2, bowler, canUndo);
    }

    final post = lastPost!; //Easier for typecasting
    switch (post) {
      case BowlerRetire():
        return _PickBowlerState(
            innings, recentBalls, batter1, batter2, bowler, canUndo);
      case BatterRetire():
        return _PickBatterState(
            innings, recentBalls, batter1, batter2, bowler, canUndo,
            toReplaceId: post.batterId);
      case WicketBeforeDelivery():
        return _PickBatterState(
            innings, recentBalls, batter1, batter2, bowler, canUndo,
            toReplaceId: post.batterId);
      case NextBowler():
        break;
      case NextBatter():
        if (post.index.ball == innings.ballsPerOver) {
          return _PickBowlerState(
              innings, recentBalls, batter1, batter2, bowler, canUndo);
        }
        break;
      case Penalty():
        break;
      case Ball():
        if (innings.isEnded) {
          return _InningsHasEndedState(
              innings, recentBalls, batter1, batter2, bowler, canUndo,
              next: _matchService.getNextState(innings));
        } else if (post.isWicket) {
          return _PickBatterState(
            innings,
            recentBalls,
            batter1,
            batter2,
            bowler,
            canUndo,
            toReplaceId: post.wicket!.batterId,
          );
        } else if (post.index.ball == innings.ballsPerOver) {
          return _PickBowlerState(
              innings, recentBalls, batter1, batter2, bowler, canUndo);
        }
        break;
      case Break():
        throw UnimplementedError();
    }
    ballController.reset();
    return _PlayBallState(
        innings, recentBalls, batter1, batter2, bowler, canUndo);
  }

  Future<void> pickBowler(BuildContext context) async {
    _dispatchLoading();
    final bowler = await _pickPlayer(context, "Pick a Bowler");
    if (bowler != null) {
      await _matchService.nextBowler(innings, bowler.id!);
    }
    await _dispatchState();
  }

  void setStrike(int slot) {
    _matchService.setStrike(innings, slot);
    _dispatchState();
  }

  void setSolo(bool solo) {}

  Future<void> pickBatter(BuildContext context, int? previousId) async {
    _dispatchLoading();

    if (innings.batter1Id == null) {}

    final batter = await _pickPlayer(context, "Pick a Batter");
    if (batter != null) {
      await _matchService.nextBatter(
        innings,
        nextId: batter.id!,
        previousId: previousId,
      );
    }
    _dispatchState();
  }

  Future<Player?> _pickPlayer(BuildContext context, String title) async {
    final player = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PickFromAllPlayersScreen(
            title: title,
            onPickPlayer: (p) => Navigator.pop(context, p),
          ),
        ));
    if (player is Player) {
      return player;
    } else {
      return null;
    }
  }

  Future<void> pickWicket(BuildContext context) async {
    final wicket = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _WicketPickerScreen(
            strikerId: innings.strikerId!,
            nonStrikerId: innings.nonStrikerId,
            bowlerId: innings.bowlerId!,
            players: PlayerCache.all,
            onPickPlayer: (context) => _pickPlayer(context, "Pick a Fielder"),
          ),
        ));

    if (wicket is Wicket) {
      ballController.nextWicket = wicket;
    } else if (wicket is Retired) {
      // TODO Improve
      await retireBatter(wicket.batterId);
    }
  }

  Future<void> retireBatter(int batterId) async {
    _dispatchLoading();
    await _matchService.retireBatter(innings, batterId);
    _dispatchState();
  }

  Future<void> retireBowler() async {
    _dispatchLoading();
    await _matchService.retireBowler(innings);
    _dispatchState();
  }

  Future<void> playBall() async {
    _dispatchLoading();
    if (innings.bowlerId == null || innings.strikerId == null) return;

    final ballState = ballController.stateNotifier.value;
    if (ballState is _NextBallSelectorDisabledState) return;

    ballState as _NextBallSelectorEnabledState;

    await _matchService.play(
      innings,
      runs: ballState.nextRuns,
      isBoundary: ballState.nextIsBoundary,
      wicket: ballState.nextWicket,
      bowlingExtraType: ballState.nextBowlingExtra,
      battingExtraType: ballState.nextBattingExtra,
      autoRotateStrike: true, // TODO
    );

    _dispatchState();
  }

  Future<void> undo() async {
    _dispatchLoading();
    if (lastPost == null) {
      return;
    }
    await _matchService.undoPostFromInnings(innings, lastPost!);
    _dispatchState();
  }

  Future<void> declareInnings(BuildContext context) async {
    _dispatchLoading();
    final next = await _matchService.declareInnings(innings);
    if (context.mounted) {
      finishInnings(context, next);
    }
    // _dispatchEndInnings(next);
  }

  Future<void> finishInnings(BuildContext context, NextStage next) async {
    _dispatchLoading();
    if (next == NextStage.nextInnings) {
      await _startNextInnings(context);
    } else if (next == NextStage.endMatch) {
      await _endMatch(context);
    } else if (next == NextStage.superOver) {
      showModalBottomSheet(
        context: context,
        builder: (context) => SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                const SizedBox(height: 32),
                Text("This match has ended in a tie",
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 32),
                SizedBox(
                    width: 192,
                    height: 42,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.sports),
                      label: const Text("Start Super Over"),
                      onPressed: () {
                        Navigator.pop(context);
                        _startSuperOver(context);
                      },
                    )),
                const SizedBox(height: 16),
                SizedBox(
                  width: 192,
                  height: 42,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.handshake),
                    label: const Text("End Match as Tie"),
                    onPressed: () {
                      Navigator.pop(context);
                      _endMatch(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<void> _startNextInnings(BuildContext context) async {
    if (innings.isSuperOver) {
      return _startSuperOver(context);
    }
    final next = await _matchService.createNextInnings(innings);
    if (context.mounted) {
      loadMatch(context, next.matchId);
    }
  }

  Future<void> _startSuperOver(BuildContext context) async {
    final next = await _matchService.createSuperOver(innings);
    if (context.mounted) {
      loadMatch(context, next.matchId);
    }
  }

  Future<void> _endMatch(BuildContext context) async {
    await _matchService.endMatch(innings);
    if (context.mounted) {
      loadMatch(context, innings.matchId);
    }
  }

  void goScorecard(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ScorecardScreen(innings.matchId)));
  }

  void goTimeline(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => InningsTimelineScreen(innings)));
  }
}

sealed class _PlayQuickMatchState {}

class _InitializingState extends _PlayQuickMatchState {}

sealed class _QuickMatchLoadedState extends _PlayQuickMatchState {
  final QuickInnings innings;
  final BattingScore? batter1;
  final BattingScore? batter2;
  final BowlingScore? bowler;
  final UnmodifiableListView<Ball> recentBalls;
  bool canUndo;

  _QuickMatchLoadedState(
    this.innings,
    this.recentBalls,
    this.batter1,
    this.batter2,
    this.bowler,
    this.canUndo,
  );
}

class _ActionLoadingState extends _QuickMatchLoadedState {
  _ActionLoadingState(super.innings, super.recentBalls, super.batter1,
      super.batter2, super.bowler, super.canUndo);
}

class _PickBowlerState extends _QuickMatchLoadedState {
  _PickBowlerState(super.innings, super.recentBalls, super.batter1,
      super.batter2, super.bowler, super.canUndo);
}

class _PickBatterState extends _QuickMatchLoadedState {
  final int? toReplaceId;

  _PickBatterState(super.innings, super.recentBalls, super.batter1,
      super.batter2, super.bowler, super.canUndo,
      {required this.toReplaceId});
}

class _InningsHasEndedState extends _QuickMatchLoadedState {
  final NextStage next;
  _InningsHasEndedState(super.innings, super.recentBalls, super.batter1,
      super.batter2, super.bowler, super.canUndo,
      {required this.next});
}

class _PlayBallState extends _QuickMatchLoadedState {
  _PlayBallState(
    super.innings,
    super.recentBalls,
    super.batter1,
    super.batter2,
    super.bowler,
    super.canUndo,
  );
}

// COMPONENTS

class _ScoreBar extends StatelessWidget {
  final Score score;

  final double currentRunRate;
  final double? requiredRunRate;

  final int? target;
  final int? runsRequired;
  final int ballsLeft;

  final int ballsBowled;
  final int maxBalls;
  final int ballsPerOver;

  final bool isLoading;

  const _ScoreBar({
    required this.score,
    required this.currentRunRate,
    required this.requiredRunRate,
    required this.ballsBowled,
    required this.maxBalls,
    required this.ballsPerOver,
    required this.target,
    required this.runsRequired,
    required this.ballsLeft,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          ListTile(
            leading: SizedBox.square(
              dimension: 20,
              child: isLoading ? const CircularProgressIndicator() : null,
            ),
            title: Text(Stringify.score(score)),
            titleTextStyle: Theme.of(context).textTheme.displaySmall,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(target == null ? "" : "Target: $target"),
                Text(
                    "${Stringify.ballCount(ballsBowled, ballsPerOver)}/${Stringify.ballCount(maxBalls, ballsPerOver)}ov"),
              ],
            ),
            leadingAndTrailingTextStyle: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // wNumberBox(context, "PROJ", currentRunRate),
              wNumberBox(context, "CRR", currentRunRate, true, null),

              if (requiredRunRate != null)
                wNumberBox(context, "RRR", requiredRunRate!, true, null),

              if (runsRequired == null)
                wNumberBox(
                    context,
                    "Projected",
                    currentRunRate * maxBalls / ballsPerOver,
                    false,
                    BallColors.notOut),

              if (runsRequired != null)
                wNumberBox(
                    context, "Runs", runsRequired!, false, BallColors.notOut),

              wNumberBox(
                  context, "Balls Left", ballsLeft, false, BallColors.newOver),
            ],
          ),
        ],
      ),
    );
  }

  Widget wNumberBox(BuildContext context, String heading, num value,
      bool showDecimal, Color? color) {
    final valueString =
        showDecimal ? value.toStringAsFixed(2) : value.floor().toString();
    return Expanded(
      child: Card(
        color: color?.withAlpha(100),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(heading),
              const SizedBox(height: 4),
              Text(
                valueString,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnCreasePlayers extends StatelessWidget {
  final BattingScore? batter1;
  final BattingScore? batter2;
  final int strikerSlot;
  final BowlingScore? bowler;
  final int ballsPerOver;

  final bool isOutBowler;

  final void Function(int strikerSlot) onSetStrike;
  final void Function(int batterId) onRetireBatter;
  final void Function(int bowlerId) onRetireBowler;

  final void Function() onPickBatter;
  final void Function() onPickBowler;

  final void Function(BuildContext context) goScorecard;

  final bool allowInput;

  const _OnCreasePlayers({
    required this.batter1,
    required this.batter2,
    required this.strikerSlot,
    required this.bowler,
    required this.ballsPerOver,
    required this.isOutBowler,
    required this.onSetStrike,
    required this.onRetireBatter,
    required this.onRetireBowler,
    required this.onPickBatter,
    required this.onPickBowler,
    required this.allowInput,
    required this.goScorecard,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  "Batters",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              _wBatterDisplay(context, 1, batter1, strikerSlot),
              _wBatterDisplay(context, 2, batter2, strikerSlot),
            ],
          ),
        ),
        const SizedBox(width: 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                alignment: Alignment.centerLeft,
                child: Text("Bowler",
                    style: Theme.of(context).textTheme.titleSmall),
              ),
              _wBowlerDisplay(context),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                width: 156,
                child: FilledButton.icon(
                  onPressed: () => goScorecard(context),
                  icon: const Icon(Icons.list_alt),
                  label: const Text("Scorecard"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _wBatterDisplay(BuildContext context, int batterNum,
      BattingScore? battingScore, int strikerSlot) {
    final isOnStrike = batterNum == strikerSlot;
    if (battingScore == null) {
      return ListTile(
        title: const Text("Pick a Batter"),
        subtitle: const SizedBox(),
        trailing: const Padding(
          padding: EdgeInsets.only(bottom: 18.0),
          child: Icon(Icons.chevron_right),
        ),
        onTap: () => onPickBatter(),
      );
    } else {
      return ListTile(
        title: Text(getPlayerName(battingScore.batterId).toUpperCase()),
        titleTextStyle: Theme.of(context).textTheme.bodyMedium,
        subtitle: Text("SR ${Stringify.decimal(battingScore.strikeRate)}"),
        subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
        trailing:
            Text("${battingScore.runsScored} (${battingScore.ballsFaced})"),
        onTap: !allowInput ? null : () => onSetStrike(batterNum),
        // onLongPress:
        //     !allowInput ? null : () => onRetireBatter(battingScore.batterId),
        selected: battingScore.isNotOut! ? isOnStrike : false,
        selectedTileColor: Colors.greenAccent.withOpacity(0.3),
        leadingAndTrailingTextStyle: Theme.of(context).textTheme.bodyLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        tileColor:
            !battingScore.isNotOut! ? Colors.redAccent.withOpacity(0.2) : null,
      );
    }
  }

  Widget _wBowlerDisplay(BuildContext context) {
    if (bowler == null) {
      return ListTile(
        title: const Text("Pick a Bowler"),
        subtitle: const SizedBox(),
        trailing: const Padding(
          padding: EdgeInsets.only(bottom: 18.0),
          child: Icon(Icons.chevron_right),
        ),
        onTap: () => onPickBowler(),
      );
    } else {
      return ListTile(
        title: Text(getPlayerName(bowler!.bowlerId).toUpperCase()),
        titleTextStyle: Theme.of(context).textTheme.bodyMedium,
        subtitle: Text(
            "${Stringify.ballCount(bowler!.ballsBowled, ballsPerOver)}ov, ${Stringify.decimal(bowler!.economy)} rpo"),
        subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
        trailing: Text("${bowler!.wicketsTaken}-${bowler!.runsConceded}"),
        onLongPress:
            !allowInput ? null : () => onRetireBowler(bowler!.bowlerId),
        leadingAndTrailingTextStyle: Theme.of(context).textTheme.bodyLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        tileColor: isOutBowler
            ? Colors.redAccent.withOpacity(0.2)
            : BallColors.newOver.withOpacity(0.3),
      );
    }
  }
}

class _NextBallSelectorSection extends StatelessWidget {
  final _NextBallSelectorController controller;

  final void Function() onSelectWicket;

  const _NextBallSelectorSection(
    this.controller, {
    required this.onSelectWicket,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller.stateNotifier,
      builder: (context, child) {
        final state = controller.stateNotifier.value;
        return Column(
          children: [
            Row(
              children: [
                if (state is _NextBallSelectorEnabledState &&
                    state.nextWicket == null)
                  Text("Record Ball",
                      style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                _WicketChip(state,
                    onSelectWicket: onSelectWicket,
                    onClearWicket: () => controller.nextWicket = null),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _BattingExtraSelectorSection(state,
                    setExtra: (extra) => controller.nextBattingExtra = extra),
                _BowlingExtraSelectorSection(state,
                    setExtra: (extra) => controller.nextBowlingExtra = extra),
              ],
            ),
            const SizedBox(height: 8),
            _RunSelectorSection(
              state,
              setRuns: (runs) => controller.nextRuns = runs,
            )
          ],
        );
      },
    );
  }
}

class _RunSelectorSection extends StatelessWidget {
  final _NextBallSelectorState state;

  final void Function(int runs) setRuns;
  const _RunSelectorSection(
    this.state, {
    required this.setRuns,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          7,
          (runs) => switch (state) {
            _NextBallSelectorEnabledState() => ChoiceChip(
                label: Text(runs.toString()),
                selected:
                    runs == (state as _NextBallSelectorEnabledState).nextRuns,
                onSelected: (x) => _onSelect(x, runs),
                selectedColor: _color(runs),
                shape: const CircleBorder(),
                showCheckmark: false,
              ),
            _NextBallSelectorDisabledState() => ChoiceChip(
                label: Text(runs.toString()),
                selected: false,
                shape: const CircleBorder(),
              ),
          },
          growable: false,
        ));
  }

  Color? _color(int runs) => switch (runs) {
        4 => BallColors.four,
        6 => BallColors.six,
        _ => null,
      };

  void _onSelect(bool isSelected, int runs) {
    if (isSelected) setRuns(runs);
  }
}

class _BattingExtraSelectorSection extends StatelessWidget {
  final _NextBallSelectorState state;

  final void Function(BattingExtraType? extra) setExtra;

  const _BattingExtraSelectorSection(
    this.state, {
    required this.setExtra,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 2,
      children: BattingExtraType.values.map((e) => chip(e)).toList(),
    );
  }

  String stringify(BattingExtraType extra) => switch (extra) {
        BattingExtraType.bye => "Bye",
        BattingExtraType.legBye => "Leg Bye"
      };

  ChoiceChip chip(BattingExtraType extra) {
    // This is not a mistake; it avoids adding a type cast
    final state = this.state;

    final isDisabled = state is _NextBallSelectorDisabledState ||
        state is _NextBallSelectorEnabledState &&
            state.nextBowlingExtra == BowlingExtraType.wide;

    return ChoiceChip(
      label: Text(stringify(extra)),
      selected: !isDisabled &&
          extra == (state as _NextBallSelectorEnabledState).nextBattingExtra,
      selectedColor: switch (extra) {
        BattingExtraType.bye => BallColors.bye,
        BattingExtraType.legBye => BallColors.legBye,
      },
      onSelected: isDisabled
          ? null
          : (x) {
              if (x) {
                setExtra(extra);
              } else {
                setExtra(null);
              }
            },
    );
  }
}

class _BowlingExtraSelectorSection extends StatelessWidget {
  final _NextBallSelectorState state;

  final void Function(BowlingExtraType? extra) setExtra;
  const _BowlingExtraSelectorSection(
    this.state, {
    required this.setExtra,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 2,
      children: BowlingExtraType.values.map((e) => chip(e)).toList(),
    );
  }

  String stringify(BowlingExtraType extra) => switch (extra) {
        BowlingExtraType.noBall => "No Ball",
        BowlingExtraType.wide => "Wide"
      };

  ChoiceChip chip(BowlingExtraType extra) {
    // This is not a mistake; it helps us avoid adding a type cast
    final state = this.state;
    return switch (state) {
      _NextBallSelectorEnabledState() => ChoiceChip(
          label: Text(stringify(extra)),
          selected: extra == state.nextBowlingExtra,
          selectedColor: switch (extra) {
            BowlingExtraType.noBall => BallColors.noBall,
            BowlingExtraType.wide => BallColors.wide,
          },
          onSelected: (x) {
            if (x) {
              setExtra(extra);
            } else {
              setExtra(null);
            }
          }),
      _NextBallSelectorDisabledState() => ChoiceChip(
          label: Text(stringify(extra)),
          selected: false,
        )
    };
  }
}

class _NextBallSelectorController {
  final stateNotifier =
      ValueNotifier<_NextBallSelectorState>(_NextBallSelectorDisabledState());

  void _dispatchState() => stateNotifier.value = _deduceState();

  void disable() => stateNotifier.value = _NextBallSelectorDisabledState();

  // void reset() => stateNotifier.value = _NextBallSelectorEnabledState.reset();

  void reset() {
    nextRuns = 0;
    nextBowlingExtra = null;
    nextBattingExtra = null;
    nextWicket = null;
    _dispatchState();
  }

  _NextBallSelectorEnabledState _deduceState() => _NextBallSelectorEnabledState(
        nextRuns: _nextRuns,
        nextIsBoundary: _nextRuns == 4 || _nextRuns == 6,
        nextBowlingExtra: _nextBowlingExtra,
        nextBattingExtra: _nextBattingExtra,
        nextWicket: _nextWicket,
      );

  // Selections
  int _nextRuns = 0;
  // int get nextRuns => _nextRuns;
  set nextRuns(int x) {
    _nextRuns = x;
    if (x == 0 && _nextBattingExtra != null) {
      _nextBattingExtra = null;
    }
    _dispatchState();
  }

  BowlingExtraType? _nextBowlingExtra;
  // BowlingExtra? get nextBowlingExtra => _nextBowlingExtra;
  set nextBowlingExtra(BowlingExtraType? x) {
    _nextBowlingExtra = x;
    if (x == BowlingExtraType.wide) {
      _nextBattingExtra = null;
    }
    _dispatchState();
  }

  BattingExtraType? _nextBattingExtra;
  // BattingExtra? get nextBattingExtra => _nextBattingExtra;
  set nextBattingExtra(BattingExtraType? x) {
    _nextBattingExtra = x;
    if (x != null && _nextRuns == 0) {
      _nextRuns = 1;
    }
    _dispatchState();
  }

  Wicket? _nextWicket;
  // Wicket? get nextWicket => _nextWicket;
  set nextWicket(Wicket? x) {
    _nextWicket = x;
    _dispatchState();
  }
}

class _WicketChip extends StatelessWidget {
  final _NextBallSelectorState state;
  final void Function() onSelectWicket;
  final void Function() onClearWicket;

  const _WicketChip(
    this.state, {
    required this.onSelectWicket,
    required this.onClearWicket,
  });

  @override
  Widget build(BuildContext context) {
    final state = this.state;
    switch (state) {
      case _NextBallSelectorEnabledState():
        return ActionChip(
          label: _wicketSummary(state.nextWicket),
          backgroundColor: state.nextWicket != null ? BallColors.wicket : null,
          onPressed: state.nextWicket == null ? onSelectWicket : onClearWicket,
        );
      case _NextBallSelectorDisabledState():
        return ActionChip(
          label: _wicketSummary(null),
        );
    }
  }

  Widget _wicketSummary(Wicket? wicket) {
    if (wicket == null) return const Text("Add Wicket");
    return Text(
        "${getPlayerName(wicket.batterId)} (${Stringify.wicket(wicket, getPlayerName: getPlayerName)})");
  }
}

sealed class _NextBallSelectorState {}

class _NextBallSelectorEnabledState extends _NextBallSelectorState {
  final int nextRuns;
  final bool nextIsBoundary;
  final BowlingExtraType? nextBowlingExtra;
  final BattingExtraType? nextBattingExtra;
  final Wicket? nextWicket;

  _NextBallSelectorEnabledState({
    required this.nextRuns,
    required this.nextIsBoundary,
    required this.nextBowlingExtra,
    required this.nextBattingExtra,
    required this.nextWicket,
  });
}

class _NextBallSelectorDisabledState extends _NextBallSelectorState {}

class _RecentBallsSection extends StatelessWidget {
  final List<Ball> reversedBalls;

  final void Function()? onOpenTimeline;

  const _RecentBallsSection(this.reversedBalls, {required this.onOpenTimeline});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(32))),
      child: InkWell(
        onTap: onOpenTimeline,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    reverse: true,
                    itemCount: reversedBalls.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: BallMini(
                        reversedBalls[index],
                        isFirstBallOfOver: _isFirstBallOfOver(index),
                      ),
                    ),
                  ),
                ),
                IconButton.filled(
                  onPressed: onOpenTimeline,
                  icon: const Icon(Icons.timeline),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isFirstBallOfOver(int index) {
    if (index == reversedBalls.length - 1) return true;
    if (reversedBalls[index].index.over !=
        reversedBalls[index + 1].index.over) {
      return true;
    }

    return false;
  }
}

class _WicketPickerScreen extends StatefulWidget {
  final int strikerId;
  final int? nonStrikerId;
  final int bowlerId;

  final Iterable<Player> players;

  final Future<Player?> Function(BuildContext context) onPickPlayer;

  const _WicketPickerScreen({
    required this.strikerId,
    required this.nonStrikerId,
    required this.bowlerId,
    required this.players,
    required this.onPickPlayer,
  });

  @override
  State<_WicketPickerScreen> createState() => _WicketPickerScreenState();
}

class _WicketPickerScreenState extends State<_WicketPickerScreen> {
  Dismissal? _wicketDismissal;
  int? _wicketBatterId;
  int? _wicketFielderId;

  final playerIds = <int>{};

  @override
  void initState() {
    super.initState();
    playerIds.addAll(widget.players.map((p) => p.id!));
  }

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
          for (final batter in [widget.strikerId, widget.nonStrikerId])
            if (batter != null)
              wSelectableOption(
                getPlayerName(batter),
                isSelected: batter == _wicketBatterId,
                onSelect: () => setBatter(batter),
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
          for (final fielderId in playerIds)
            wSelectableOption(
              getPlayerName(fielderId),
              isSelected: fielderId == _wicketFielderId,
              onSelect: () => setFielder(fielderId),
            ),
          ListTile(
            title: const Text("Pick Player"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final player = await widget.onPickPlayer(context);
              if (player != null) {
                playerIds.add(player.id!);
                setFielder(player.id!);
              }
            },
          ),
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
        Dismissal.caughtAndBowled => true,
        Dismissal.stumped => true,
        Dismissal.runOut => false,
        Dismissal.timedOut => false,
        Dismissal.retiredOut => false,
        Dismissal.retiredNotOut => false,
        Dismissal.obstructing => false,
        Dismissal.hitTwice => false,
      };

  bool requiresFielder(Dismissal dismissal) => switch (dismissal) {
        Dismissal.bowled => false,
        Dismissal.hitWicket => false,
        Dismissal.lbw => false,
        Dismissal.caught => true,
        Dismissal.caughtAndBowled => false, // same as bowler
        Dismissal.stumped => true,
        Dismissal.runOut => true,
        Dismissal.timedOut => false,
        Dismissal.retiredOut => false,
        Dismissal.retiredNotOut => false,
        Dismissal.obstructing => false,
        Dismissal.hitTwice => false,
      };

  bool canBatterBeNonStriker(Dismissal dismissal) => switch (dismissal) {
        Dismissal.bowled => false,
        Dismissal.hitWicket => false,
        Dismissal.lbw => false,
        Dismissal.caught => false,
        Dismissal.caughtAndBowled => false,
        Dismissal.stumped => false,
        Dismissal.runOut => true,
        Dismissal.timedOut => true,
        Dismissal.retiredOut => true,
        Dismissal.retiredNotOut => true,
        Dismissal.obstructing => true,
        Dismissal.hitTwice => false,
      };

  String stringifyWicketName(Dismissal dismissal) => switch (dismissal) {
        Dismissal.bowled => "Bowled",
        Dismissal.hitWicket => "Hit Wicket",
        Dismissal.lbw => "LBW",
        Dismissal.caught => "Caught",
        Dismissal.caughtAndBowled => "Caught and Bowled",
        Dismissal.stumped => "Stumped",
        Dismissal.runOut => "Run out",
        Dismissal.timedOut => "Timed out",
        Dismissal.retiredOut => "Retired - Out",
        Dismissal.retiredNotOut => "Retired - Not Out",
        Dismissal.obstructing => "Obstructing the field",
        Dismissal.hitTwice => "Hit the ball twice",
      };

  void setDismissal(Dismissal dismissal) {
    setState(() {
      _wicketDismissal = dismissal;
      _wicketBatterId = null;
      _wicketFielderId = null;
    });
  }

  void setBatter(int batterId) {
    setState(() {
      _wicketBatterId = batterId;
    });
  }

  void setFielder(int fielderId) {
    setState(() {
      _wicketFielderId = fielderId;
    });
  }

  bool get canReturnWicket {
    if (_wicketDismissal == null) return false;

    if (requiresFielder(_wicketDismissal!) && _wicketFielderId == null) {
      return false;
    }

    if (canBatterBeNonStriker(_wicketDismissal!) && _wicketBatterId == null) {
      return false;
    }

    return true;
  }

  void returnWicket() {
    if (!canReturnWicket) {
      return;
    }

    final result = switch (_wicketDismissal!) {
      Dismissal.bowled =>
        Bowled(batterId: widget.strikerId, bowlerId: widget.bowlerId),
      Dismissal.hitWicket =>
        HitWicket(batterId: widget.strikerId, bowlerId: widget.bowlerId),
      Dismissal.lbw =>
        Lbw(batterId: widget.strikerId, bowlerId: widget.bowlerId),
      Dismissal.caught => widget.bowlerId == _wicketFielderId
          ? CaughtAndBowled(
              batterId: widget.strikerId, bowlerId: widget.bowlerId)
          : Caught(
              batterId: widget.strikerId,
              bowlerId: widget.bowlerId,
              fielderId: _wicketFielderId!),
      Dismissal.caughtAndBowled =>
        CaughtAndBowled(batterId: widget.strikerId, bowlerId: widget.bowlerId),
      Dismissal.stumped => Stumped(
          batterId: widget.strikerId,
          bowlerId: widget.bowlerId,
          wicketkeeperId: _wicketFielderId!),
      Dismissal.runOut =>
        RunOut(batterId: _wicketBatterId!, fielderId: _wicketFielderId!),
      Dismissal.timedOut => TimedOut(batterId: _wicketBatterId!),
      Dismissal.retiredOut => RetiredOut(batterId: _wicketBatterId!),
      Dismissal.retiredNotOut => RetiredNotOut(batterId: _wicketBatterId!),
      Dismissal.obstructing => ObstructingTheField(batterId: _wicketBatterId!),
      Dismissal.hitTwice => HitTheBallTwice(batterId: _wicketBatterId!),
    };

    Navigator.pop(context, result);
  }
}
