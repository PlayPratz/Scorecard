import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/cache/player_cache.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/modules/quick_match/post_ball_and_extras_model.dart';
import 'package:scorecard/modules/quick_match/quick_match_model.dart';
import 'package:scorecard/modules/quick_match/wicket_model.dart';
import 'package:scorecard/screens/player/player_list_screen.dart';
import 'package:scorecard/screens/quick_match/innings_timeline_screen.dart';
import 'package:scorecard/screens/quick_match/scorecard_screen.dart';
import 'package:scorecard/services/quick_match_service.dart';
import 'package:scorecard/ui/ball_colors.dart';
import 'package:scorecard/ui/stringify.dart';

class PlayQuickMatchScreen extends StatelessWidget {
  final QuickMatch match;

  const PlayQuickMatchScreen(this.match, {super.key});

  @override
  Widget build(BuildContext context) {
    final controller = _PlayQuickMatchScreenController(
        match, context.read<QuickMatchService>());
    controller.initialize();

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
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    onPressed: () => _quitMatch(context),
                    icon: const Icon(Icons.exit_to_app)),
                title: Text(Stringify.inningsHeading(innings.inningsNumber)),
                actions: [
                  FilledButton.tonalIcon(
                    onPressed: () => showEndInningsWarning(context),
                    onLongPress: () => controller.endInnings(context),
                    label: const Text("End"),
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
                        ballsBowled: innings.numBalls,
                        ballsPerInnings: innings.rules.ballsPerInnings,
                        ballsPerOver: innings.rules.ballsPerOver,
                        target: innings.target,
                        requiredRunRate: innings.requiredRunRate,
                        runsRequired: innings.runsRequired,
                        ballsLeft: innings.ballsLeft,
                        isLoading: state is _ActionLoadingState),
                    const Spacer(),
                    _RecentBallsSection(
                      innings.balls,
                      onOpenTimeline: () => controller.goTimeline(context),
                    ),
                    const SizedBox(height: 18),
                    _OnCreasePlayers(
                      batter1: _batter1Display(context, innings),
                      batter2: _batter2Display(context, innings),
                      bowler: _bowlerDisplay(context, innings),
                      strikerId: innings.strikerId,
                      allowSecondBatter: !innings.rules.onlySingleBatter,
                      outBatter:
                          state is _PickBatterState ? state.toReplaceId : null,
                      isOutBowler: false,
                      onPickBatter: () => controller.pickBatter(context, null),
                      onPickBowler: () => controller.pickBowler(context),
                      onRetireBatter: (batterId) =>
                          controller.retireBatter(batterId),
                      onRetireBowler: (bowlerId) => controller.retireBowler(),
                      onSetStrike: (batterId) => controller.setStrike(batterId),
                      allowInput: state is _PlayBallState,
                      goScorecard: controller.goScorecard,
                    ),
                    const SizedBox(height: 18),
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
                          _wUndoButton(controller, innings.posts.isNotEmpty),
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

  Future<void> _quitMatch(BuildContext context) async {
    Navigator.pop(context);
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
        _EndInningsState() => FilledButton.icon(
            onPressed: () => showEndInningsWarning(context),
            onLongPress: () => controller.endInnings(context),
            label: const Text("End Innings"),
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

  void showEndInningsWarning(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Long press to end this innings")));
  }

  Widget _wUndoButton(
          _PlayQuickMatchScreenController controller, bool canUndo) =>
      OutlinedButton.icon(
        onPressed: canUndo ? () => controller.undo() : null,
        label: const Text("Undo"),
        icon: const Icon(Icons.undo),
      );

  _BatterScoreDisplay? _batter1Display(
      BuildContext context, QuickInnings innings) {
    if (innings.batter1Id == null) return null;

    return _batterDisplayInner(context, innings, innings.batter1Id!);
  }

  _BatterScoreDisplay? _batter2Display(
      BuildContext context, QuickInnings innings) {
    if (innings.rules.onlySingleBatter || innings.batter2Id == null) {
      return null;
    }

    return _batterDisplayInner(context, innings, innings.batter2Id!);
  }

  _BatterScoreDisplay? _batterDisplayInner(
    BuildContext context,
    QuickInnings innings,
    String batterId,
  ) {
    final batterInnings = BatterInnings.of(batterId, innings);

    return _BatterScoreDisplay(
      batterId,
      batterName: PlayerCache().get(batterId).name,
      ballsFaced: batterInnings.numBalls,
      runsScored: batterInnings.runs,
      strikeRate: batterInnings.strikeRate,
    );
  }

  _BowlerScoreDisplay? _bowlerDisplay(
      BuildContext context, QuickInnings innings) {
    final bowlerId = innings.bowlerId;
    if (bowlerId == null) return null;

    final bowlerInnings = BowlerInnings.of(bowlerId, innings);

    return _BowlerScoreDisplay(
      bowlerId,
      bowlerName: PlayerCache().get(bowlerId).name,
      runsConceded: bowlerInnings.runs,
      ballsBowled: bowlerInnings.numBalls,
      ballsPerOver: bowlerInnings.ballsPerOver,
      wicketsTaken: bowlerInnings.numWickets,
      economy: bowlerInnings.economy,
    );
  }
}

// STATES

class _PlayQuickMatchScreenController {
  /// The match which is loaded
  final QuickMatch match;

  /// The innings which will be played
  late QuickInnings innings;

  final QuickMatchService _matchService;

  final ballController = _NextBallSelectorController();

  _PlayQuickMatchScreenController(this.match, this._matchService);

  final _stateStreamController = StreamController<_PlayQuickMatchScreenState>();
  Stream<_PlayQuickMatchScreenState> get _stateStream =>
      _stateStreamController.stream;

  Future<void> initialize() async {
    _stateStreamController.add(_InitializingState());

    QuickInnings? loadInnings = await _matchService.loadLastInnings(match);
    if (loadInnings != null) {
      // Loaded from disk
      innings = loadInnings;
    } else {
      // Create new
      innings = await _matchService.createFirstInnings(match);
    }

    _dispatchState();
  }

  void _dispatchLoading() =>
      _stateStreamController.add(_ActionLoadingState(innings));

  void _dispatchState() => _stateStreamController.add(_deduceState());

  _QuickMatchLoadedState _deduceState() {
    ballController.disable();

    if (innings.batter1Id == null ||
        (!innings.rules.onlySingleBatter && innings.batter2Id == null)) {
      return _PickBatterState(innings, toReplaceId: null);
    }

    if (innings.bowlerId == null) {
      return _PickBowlerState(innings);
    }

    final lastPost = innings.posts.last; // Cannot be empty

    switch (lastPost) {
      case BowlerRetire():
        return _PickBowlerState(innings);
      case BatterRetire():
        return _PickBatterState(innings, toReplaceId: lastPost.batterId);
      case RunoutBeforeDelivery():
        return _PickBatterState(innings, toReplaceId: lastPost.batterId);
      case NextBowler():
        break;
      case NextBatter():
        if (lastPost.index.ball == innings.rules.ballsPerOver) {
          return _PickBowlerState(innings);
        }
        break;
      case Ball():
        if (innings.hasEnded) {
          return _EndInningsState(innings);
        } else if (lastPost.isWicket) {
          return _PickBatterState(
            innings,
            toReplaceId: lastPost.wicket!.batterId,
          );
        } else if (lastPost.index.ball == innings.rules.ballsPerOver) {
          return _PickBowlerState(innings);
        }
        break;
    }
    ballController.reset();
    return _PlayBallState(innings);
  }

  Future<void> pickBowler(BuildContext context) async {
    _dispatchLoading();
    final bowler = await _pickPlayer(context);
    if (bowler != null) {
      await _matchService.nextBowler(innings, bowler.id);
      await Future.delayed(const Duration(milliseconds: 100));
    }
    _dispatchState();
  }

  void setStrike(String batterId) {
    _matchService.setStrike(innings, batterId);
    _dispatchState();
  }

  Future<void> pickBatter(BuildContext context, String? previousId) async {
    _dispatchLoading();

    if (innings.batter1Id == null) {}

    final batter = await _pickPlayer(context);
    if (batter != null) {
      await _matchService.nextBatter(
        innings,
        nextId: batter.id,
        previousId: previousId,
      );
      await Future.delayed(const Duration(milliseconds: 100));
    }
    _dispatchState();
  }

  Future<Player?> _pickPlayer(BuildContext context) async {
    final player = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PickFromAllPlayersScreen(
              onPickPlayer: (p) => Navigator.pop(context, p)),
        ));
    if (player is Player) {
      PlayerCache().put(player);
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
            nonStrikerId: innings.nonStrikerId!,
            bowlerId: innings.bowlerId!,
            players: PlayerCache().all().keys,
            onPickPlayer: _pickPlayer,
          ),
        ));

    if (wicket is Wicket) {
      ballController.nextWicket = wicket;
    } else if (wicket is Retired) {
      // TODO Improve
      await retireBatter(wicket.batterId);
    }
  }

  Future<void> retireBatter(String batterId) async {
    _dispatchLoading();
    await Future.delayed(const Duration(milliseconds: 150));
    await _matchService.retireDeclareBatter(innings, batterId);
    _dispatchState();
  }

  Future<void> retireBowler() async {
    _dispatchLoading();
    await Future.delayed(const Duration(milliseconds: 150));
    await _matchService.retireBowler(innings);
    _dispatchState();
  }

  Future<void> playBall() async {
    _dispatchLoading();
    await Future.delayed(const Duration(milliseconds: 350));
    if (innings.bowlerId == null || innings.strikerId == null) return;

    final ballState = ballController.stateNotifier.value;
    if (ballState is _NextBallSelectorDisabledState) return;

    ballState as _NextBallSelectorEnabledState;

    await _matchService.play(
      innings,
      bowlerId: innings.bowlerId!,
      batterId: innings.strikerId!,
      runs: ballState.nextRuns,
      isBoundary: ballState.nextRuns == 4 || ballState.nextRuns == 6, //TODO
      wicket: ballState.nextWicket,
      bowlingExtraType: ballState.nextBowlingExtra,
      battingExtraType: ballState.nextBattingExtra,
    );

    _dispatchState();
  }

  Future<void> undo() async {
    _dispatchLoading();
    await Future.delayed(const Duration(milliseconds: 250));
    await _matchService.undoPostFromInnings(innings);
    _dispatchState();
  }

  Future<void> endInnings(BuildContext context) async {
    _dispatchLoading();
    if (innings.inningsNumber == 1) {
      await _matchService.createSecondInnings(match, innings);
      await initialize();
    } else if (innings.inningsNumber == 2) {
      await _matchService.endMatch(match, innings);
      if (context.mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => ScorecardScreen(match)));
      }
    }
    // TODO Super overs
  }

  void goScorecard(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ScorecardScreen(match)));
  }

  void goTimeline(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => InningsTimelineScreen(innings)));
  }
}

sealed class _PlayQuickMatchScreenState {}

class _InitializingState extends _PlayQuickMatchScreenState {}

sealed class _QuickMatchLoadedState extends _PlayQuickMatchScreenState {
  final QuickInnings innings;

  _QuickMatchLoadedState(this.innings);
}

class _ActionLoadingState extends _QuickMatchLoadedState {
  _ActionLoadingState(super.innings);
}

class _PickBowlerState extends _QuickMatchLoadedState {
  _PickBowlerState(super.innings);
}

class _PickBatterState extends _QuickMatchLoadedState {
  final String? toReplaceId;

  _PickBatterState(super.innings, {required this.toReplaceId});
}

class _EndInningsState extends _QuickMatchLoadedState {
  _EndInningsState(super.innings);
}

class _PlayBallState extends _QuickMatchLoadedState {
  _PlayBallState(super.innings);
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
  final int ballsPerInnings;
  final int ballsPerOver;

  final bool isLoading;

  const _ScoreBar({
    required this.score,
    required this.currentRunRate,
    required this.requiredRunRate,
    required this.ballsBowled,
    required this.ballsPerInnings,
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
            trailing: Text(
                "${Stringify.ballCount(ballsBowled, ballsPerOver)}/${Stringify.ballCount(ballsPerInnings, ballsPerOver)}ov"),
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

              if (runsRequired != null) ...[
                wNumberBox(
                    context, "Runs", runsRequired!, false, BallColors.notOut),
                wNumberBox(
                    context, "Balls", ballsLeft, false, BallColors.newOver),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget wNumberBox(BuildContext context, String heading, num value,
      bool showDecimal, Color? color) {
    final valueString =
        showDecimal ? value.toStringAsFixed(2) : value.toString();
    return Expanded(
      child: Card(
        color: color?.withOpacity(0.9),
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
  final _BatterScoreDisplay? batter1;

  final bool allowSecondBatter;
  final _BatterScoreDisplay? batter2;

  final String? strikerId;

  final _BowlerScoreDisplay? bowler;

  final String? outBatter;
  final bool isOutBowler;

  final void Function(String batterId) onSetStrike;
  final void Function(String batterId) onRetireBatter;
  final void Function(String? bowlerId) onRetireBowler;

  final void Function() onPickBatter;
  final void Function() onPickBowler;

  final void Function(BuildContext context) goScorecard;

  final bool allowInput;

  const _OnCreasePlayers({
    required this.batter1,
    required this.batter2,
    required this.strikerId,
    required this.bowler,
    required this.outBatter,
    required this.isOutBowler,
    required this.allowSecondBatter,
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
              _wBatterDisplay(context, batter1),
              if (allowSecondBatter) _wBatterDisplay(context, batter2),
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

  Widget _wBatterDisplay(
      BuildContext context, _BatterScoreDisplay? batterScoreDisplay) {
    if (batterScoreDisplay == null) {
      return ListTile(
        title: const Text("Pick a Batter"),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => onPickBatter(),
      );
    } else {
      final isOut = outBatter == batterScoreDisplay.batterId;
      return ListTile(
        title: Text(batterScoreDisplay.batterName.toUpperCase()),
        titleTextStyle: Theme.of(context).textTheme.bodyMedium,
        subtitle:
            Text("SR ${batterScoreDisplay.strikeRate.toStringAsFixed(2)}"),
        subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
        trailing: Text(
            "${batterScoreDisplay.runsScored} (${batterScoreDisplay.ballsFaced})"),
        onTap:
            !allowInput ? null : () => onSetStrike(batterScoreDisplay.batterId),
        onLongPress: !allowInput
            ? null
            : () => onRetireBatter(batterScoreDisplay.batterId),
        selected: isOut ? false : batterScoreDisplay.batterId == strikerId,
        selectedTileColor: Colors.greenAccent.withOpacity(0.3),
        leadingAndTrailingTextStyle: Theme.of(context).textTheme.bodyLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        tileColor: isOut ? Colors.redAccent.withOpacity(0.2) : null,
      );
    }
  }

  Widget _wBowlerDisplay(BuildContext context) {
    if (bowler == null) {
      return ListTile(
        title: const Text("Pick a Bowler"),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => onPickBowler(),
      );
    } else {
      return ListTile(
        title: Text(bowler!.bowlerName.toUpperCase()),
        titleTextStyle: Theme.of(context).textTheme.bodyMedium,
        subtitle: Text(
            "${Stringify.ballCount(bowler!.ballsBowled, bowler!.ballsPerOver)}ov, ${bowler!.economy.toStringAsFixed(2)}rpo"),
        subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
        trailing: Text("${bowler!.wicketsTaken}-${bowler!.runsConceded}"),
        onLongPress:
            !allowInput ? null : () => onRetireBowler(bowler!.bowlerId),
        leadingAndTrailingTextStyle: Theme.of(context).textTheme.bodyLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        tileColor: BallColors.newOver.withOpacity(0.3),
      );
    }
  }
}

class _BatterScoreDisplay {
  final String batterId;
  final String batterName;
  final int runsScored;
  final int ballsFaced;
  final double strikeRate;

  _BatterScoreDisplay(
    this.batterId, {
    required this.batterName,
    required this.runsScored,
    required this.ballsFaced,
    required this.strikeRate,
  });
}

class _BowlerScoreDisplay {
  final String bowlerId;
  final String bowlerName;
  final int runsConceded;
  final int ballsBowled;
  final int ballsPerOver;
  final int wicketsTaken;
  final double economy;

  _BowlerScoreDisplay(
    this.bowlerId, {
    required this.bowlerName,
    required this.runsConceded,
    required this.ballsBowled,
    required this.ballsPerOver,
    required this.wicketsTaken,
    required this.economy,
  });
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
                  Text("Record Next Ball",
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
    getPlayerName(String id) => PlayerCache().get(id).name;

    if (wicket == null) return const Text("Add Wicket");
    return Text(
        "${getPlayerName(wicket.batterId)} (${Stringify.wicket(wicket, getPlayerName: getPlayerName)})");
  }
}

sealed class _NextBallSelectorState {}

class _NextBallSelectorEnabledState extends _NextBallSelectorState {
  final int nextRuns;
  final BowlingExtraType? nextBowlingExtra;
  final BattingExtraType? nextBattingExtra;
  final Wicket? nextWicket;

  _NextBallSelectorEnabledState({
    required this.nextRuns,
    required this.nextBowlingExtra,
    required this.nextBattingExtra,
    required this.nextWicket,
  });
}

class _NextBallSelectorDisabledState extends _NextBallSelectorState {}

class _RecentBallsSection extends StatelessWidget {
  final List<Ball> reversedBalls;

  final void Function()? onOpenTimeline;

  _RecentBallsSection(List<Ball> balls, {required this.onOpenTimeline})
      : reversedBalls = balls.reversed.toList();

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
                  icon: const Icon(Icons.history),
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
  final String strikerId;
  final String nonStrikerId;
  final String bowlerId;

  final Iterable<String> players;

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
  String? _wicketBatterId;
  String? _wicketFielderId;

  final playerIds = <String>[];

  @override
  void initState() {
    super.initState();
    playerIds.addAll(widget.players);
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
            wSelectableOption(
              getPlayer(batter).name,
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
              getPlayer(fielderId).name,
              isSelected: fielderId == _wicketFielderId,
              onSelect: () => setFielder(fielderId),
            ),
          ListTile(
            title: const Text("Pick Player"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final player = await widget.onPickPlayer(context);
              if (player != null) {
                playerIds.add(player.id);
                setFielder(player.id);
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
      _wicketBatterId = null;
      _wicketFielderId = null;
    });
  }

  void setBatter(String batterId) {
    setState(() {
      _wicketBatterId = batterId;
    });
  }

  void setFielder(String fielderId) {
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
        BowledWicket(batterId: widget.strikerId, bowlerId: widget.bowlerId),
      Dismissal.hitWicket =>
        HitWicket(batterId: widget.strikerId, bowlerId: widget.bowlerId),
      Dismissal.lbw =>
        LbwWicket(batterId: widget.strikerId, bowlerId: widget.bowlerId),
      Dismissal.caught => CaughtWicket(
          batterId: widget.strikerId,
          bowlerId: widget.bowlerId,
          fielderId: _wicketFielderId!),
      Dismissal.stumped => StumpedWicket(
          batterId: widget.strikerId,
          bowlerId: widget.bowlerId,
          wicketkeeperId: _wicketFielderId!),
      Dismissal.runOut =>
        RunoutWicket(batterId: _wicketBatterId!, fielderId: _wicketFielderId!),
      Dismissal.timedOut => TimedOutWicket(batterId: _wicketBatterId!),
      Dismissal.retired => RetiredDeclared(batterId: _wicketBatterId!),
      Dismissal.retiredHurt => RetiredHurt(batterId: _wicketBatterId!),
    };

    Navigator.pop(context, result);
  }

  Player getPlayer(String id) => PlayerCache().get(id);
}
