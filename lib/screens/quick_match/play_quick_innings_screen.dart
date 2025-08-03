import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scorecard/modules/quick_match/ball_and_extras_model.dart';
import 'package:scorecard/modules/quick_match/quick_match_model.dart';
import 'package:scorecard/modules/quick_match/wicket_model.dart';
import 'package:scorecard/ui/ball_colors.dart';

class PlayQuickInningsScreen extends StatelessWidget {
  final QuickInnings innings;

  const PlayQuickInningsScreen(this.innings, {super.key});

  @override
  Widget build(BuildContext context) {
    final ballController = _NextBallSelectorController();
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          _ScoreBar(
            runs: innings.runs,
            wickets: innings.wickets,
            currentRunRate: innings.currentRunRate,
            ballsBowled: innings.numBalls,
            maxBalls: innings.rules.maxBalls,
          ),
          const SizedBox(height: 18),
          // TODO Add Player Selection
          _OnCreasePlayers(
              batter1: _BatterScoreDisplay(
                innings.batter1Id,
                batterName: innings.,
                runsScored: runsScored,
                ballsFaced: ballsFaced,
              ),
              bowler: _BowlerScoreDisplay(
                bowlerId,
                bowlerName: bowlerName,
                runsConceded: runsConceded,
                ballsBowled: ballsBowled,
                wicketsTaken: wicketsTaken,
              )),

          const SizedBox(height: 18),
          _NextBallSelectorSection(ballController),
        ],
      ),
    );
  }

  String get _title => switch (innings.inningsNumber) {
        1 => "First Innings",
        2 => "Second Innings",
        _ => "Innings ${innings.inningsNumber}"
      };
}

class _ScoreBar extends StatelessWidget {
  final int runs;
  final int wickets;

  final double currentRunRate;

  final int ballsBowled;
  final int maxBalls;

  const _ScoreBar({
    super.key,
    required this.runs,
    required this.wickets,
    required this.currentRunRate,
    required this.ballsBowled,
    required this.maxBalls,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            Text("$runs/$wickets"),
            Text("CRR: ${currentRunRate.toStringAsFixed(2)}")
          ],
        ),
        Column(
          children: [Text("$ballsBowled/$maxBalls balls")],
        ),
      ],
    );
  }
}

class _OnCreasePlayers extends StatelessWidget {
  final _BatterScoreDisplay batter1;
  final _BatterScoreDisplay? batter2;

  final _BowlerScoreDisplay bowler;

  const _OnCreasePlayers(
      {super.key, required this.batter1, this.batter2, required this.bowler});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            ListTile(
              title: Text(batter1.batterName),
              trailing: Text("${batter1.runsScored} (${batter1.ballsFaced})"),
            ),
            if (batter2 != null)
              ListTile(
                title: Text(batter2!.batterName),
                trailing:
                    Text("${batter2!.runsScored} (${batter2!.ballsFaced})"),
              ),
          ],
        ),
        Column(
          children: [
            ListTile(
              title: Text(bowler.bowlerName),
              trailing: Text("${bowler.wicketsTaken - bowler.runsConceded}"),
            ),
            const ListTile(),
          ],
        ),
      ],
    );
  }
}

class _BatterScoreDisplay {
  final String batterId;
  final String batterName;
  final int runsScored;
  final int ballsFaced;

  _BatterScoreDisplay(
    this.batterId, {
    required this.batterName,
    required this.runsScored,
    required this.ballsFaced,
  });
}

class _BowlerScoreDisplay {
  final String bowlerId;
  final String bowlerName;
  final int runsConceded;
  final int ballsBowled;
  final int wicketsTaken;

  _BowlerScoreDisplay(
    this.bowlerId, {
    required this.bowlerName,
    required this.runsConceded,
    required this.ballsBowled,
    required this.wicketsTaken,
  });
}

class _NextBallSelectorSection extends StatelessWidget {
  final _NextBallSelectorController controller;

  final void Function()? onSelectWicket;

  const _NextBallSelectorSection(
    this.controller, {
    super.key,
    this.onSelectWicket,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: controller.stream,
      initialData: controller.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        return Column(
          children: [
            Row(
              children: [
                if (state is NextBallSelectorEnabledState &&
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
  final NextBallSelectorState state;

  final void Function(int runs) setRuns;
  const _RunSelectorSection(
    this.state, {
    super.key,
    required this.setRuns,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          7,
          (runs) => switch (state) {
            NextBallSelectorEnabledState() => ChoiceChip(
                label: Text(runs.toString(),
                    style: Theme.of(context).textTheme.bodySmall),
                selected:
                    runs == (state as NextBallSelectorEnabledState).nextRuns,
                onSelected: (x) => _onSelect(x, runs),
                selectedColor: _color(runs),
                shape: const CircleBorder(),
                showCheckmark: false,
              ),
            NextBallSelectorDisabledState() => ChoiceChip(
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
  final NextBallSelectorState state;

  final void Function(BattingExtraType? extra) setExtra;
  const _BattingExtraSelectorSection(
    this.state, {
    super.key,
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
    // This is not a mistake; it helps us avoid adding a type cast
    final state = this.state;
    return switch (state) {
      NextBallSelectorEnabledState() => ChoiceChip(
          label: Text(stringify(extra)),
          selected: extra == state.nextBattingExtra,
          onSelected: (x) {
            if (x) {
              setExtra(extra);
            } else {
              setExtra(null);
            }
          }),
      NextBallSelectorDisabledState() => ChoiceChip(
          label: Text(stringify(extra)),
          selected: false,
        )
    };
  }
}

class _BowlingExtraSelectorSection extends StatelessWidget {
  final NextBallSelectorState state;

  final void Function(BowlingExtraType? extra) setExtra;
  const _BowlingExtraSelectorSection(
    this.state, {
    super.key,
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
      NextBallSelectorEnabledState() => ChoiceChip(
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
      NextBallSelectorDisabledState() => ChoiceChip(
          label: Text(stringify(extra)),
          selected: false,
        )
    };
  }
}

class _NextBallSelectorController {
  final _selectionStreamController = StreamController<NextBallSelectorState>();
  Stream<NextBallSelectorState> get stream => _selectionStreamController.stream;

  void _dispatchState() {
    _selectionStreamController.add(state);
  }

  NextBallSelectorEnabledState get state => NextBallSelectorEnabledState(
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
    _dispatchState();
  }

  BowlingExtraType? _nextBowlingExtra;
  // BowlingExtra? get nextBowlingExtra => _nextBowlingExtra;
  set nextBowlingExtra(BowlingExtraType? x) {
    _nextBowlingExtra = x;
    _dispatchState();
  }

  BattingExtraType? _nextBattingExtra;
  // BattingExtra? get nextBattingExtra => _nextBattingExtra;
  set nextBattingExtra(BattingExtraType? x) {
    _nextBattingExtra = x;
    _dispatchState();
  }

  Wicket? _nextWicket;
  // Wicket? get nextWicket => _nextWicket;
  set nextWicket(Wicket? x) {
    _nextWicket = x;
    _dispatchState();
  }

  void disable() {
    _selectionStreamController.add(NextBallSelectorDisabledState());
  }

  void reset() {
    _nextRuns = 0;
    _nextBattingExtra = null;
    _nextBowlingExtra = null;
    _nextWicket = null;
    _dispatchState();
  }
}

sealed class NextBallSelectorState {}

class NextBallSelectorEnabledState extends NextBallSelectorState {
  final int nextRuns;
  final BowlingExtraType? nextBowlingExtra;
  final BattingExtraType? nextBattingExtra;
  final Wicket? nextWicket;

  NextBallSelectorEnabledState({
    required this.nextRuns,
    required this.nextBowlingExtra,
    required this.nextBattingExtra,
    required this.nextWicket,
  });
}

class NextBallSelectorDisabledState extends NextBallSelectorState {}

class _WicketChip extends StatelessWidget {
  final NextBallSelectorState state;
  final void Function()? onSelectWicket;
  final void Function()? onClearWicket;

  const _WicketChip(this.state,
      {required this.onSelectWicket, this.onClearWicket});

  @override
  Widget build(BuildContext context) {
    final state = this.state;
    switch (state) {
      case NextBallSelectorEnabledState():
        return ActionChip(
          label: _wicketSummary(state.nextWicket),
          backgroundColor: state.nextWicket != null ? BallColors.wicket : null,
          onPressed: state.nextWicket == null ? onSelectWicket : onClearWicket,
        );
      case NextBallSelectorDisabledState():
        return ActionChip(
          label: _wicketSummary(null),
        );
    }
  }

  // Widget _wicketSummary(Wicket? wicket) {
  //   if (wicket == null) return const Text("Add Wicket");
  //   return Text("${wicket.batterId.name} (${Stringify.wicket(wicket)})");
  // }

  Widget _wicketSummary(Wicket? wicket) => Text("WIP");
}
