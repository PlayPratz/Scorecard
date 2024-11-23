import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/cricket_match/models/wicket_model.dart';
import 'package:scorecard/ui/ball_colors.dart';

class NextBallSelectorSection extends StatelessWidget {
  final NextBallSelectorController controller;

  const NextBallSelectorSection(this.controller, {super.key});

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
                _BattingExtraSelectorSection(state,
                    setExtra: (extra) => controller.nextBattingExtra = extra),
                const Spacer(),
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
                label: Text(runs.toString()),
                selected:
                    runs == (state as NextBallSelectorEnabledState).nextRuns,
                onSelected: (x) => _onSelect(x, runs),
                selectedColor: _color(runs),
                shape: const CircleBorder(),
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

  final void Function(BattingExtra extra) setExtra;
  const _BattingExtraSelectorSection(
    this.state, {
    super.key,
    required this.setExtra,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: BattingExtra.values.map((e) => chip(e)).toList());
  }

  String stringify(BattingExtra extra) => switch (extra) {
        BattingExtra.bye => "Bye",
        BattingExtra.legBye => "Leg Bye"
      };

  ChoiceChip chip(BattingExtra extra) {
    // This is not a mistake; it helps us avoid adding a type cast
    final state = this.state;
    return switch (state) {
      NextBallSelectorEnabledState() => ChoiceChip(
          label: Text(stringify(extra)),
          selected: extra == state.nextBattingExtra,
          onSelected: (x) {
            if (x) setExtra(extra);
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

  final void Function(BowlingExtra extra) setExtra;
  const _BowlingExtraSelectorSection(
    this.state, {
    super.key,
    required this.setExtra,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(children: BowlingExtra.values.map((e) => chip(e)).toList());
  }

  String stringify(BowlingExtra extra) => switch (extra) {
        BowlingExtra.noBall => "No Ball",
        BowlingExtra.wide => "Wide"
      };

  ChoiceChip chip(BowlingExtra extra) {
    // This is not a mistake; it helps us avoid adding a type cast
    final state = this.state;
    return switch (state) {
      NextBallSelectorEnabledState() => ChoiceChip(
          label: Text(stringify(extra)),
          selected: extra == state.nextBowlingExtra,
          onSelected: (x) {
            if (x) setExtra(extra);
          }),
      NextBallSelectorDisabledState() => ChoiceChip(
          label: Text(stringify(extra)),
          selected: false,
        )
    };
  }
}

//
// class _RunSelector extends StatelessWidget {
//   final int runs;
//
//   final bool isEnabled;
//   final bool isSelected;
//
//   final void Function() onSelect;
//
//   final Color? color;
//   const _RunSelector(
//     this.runs, {
//     super.key,
//     required this.isSelected,
//     required this.onSelect,
//     required this.isEnabled,
//     this.color,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ChoiceChip(
//       label: Text(runs.toString()),
//       shape: const CircleBorder(),
//       selected: isSelected,
//       onSelected: isEnabled ? _onSelect : null,
//     );
//   }
//
//   void _onSelect(bool x) {
//     if(x) {
//       onSelect();
//     }
//   }
// }

class NextBallSelectorController {
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

  BowlingExtra? _nextBowlingExtra;
  // BowlingExtra? get nextBowlingExtra => _nextBowlingExtra;
  set nextBowlingExtra(BowlingExtra? x) {
    _nextBowlingExtra = x;
    _dispatchState();
  }

  BattingExtra? _nextBattingExtra;
  // BattingExtra? get nextBattingExtra => _nextBattingExtra;
  set nextBattingExtra(BattingExtra? x) {
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
  final BowlingExtra? nextBowlingExtra;
  final BattingExtra? nextBattingExtra;
  final Wicket? nextWicket;

  NextBallSelectorEnabledState({
    required this.nextRuns,
    required this.nextBowlingExtra,
    required this.nextBattingExtra,
    required this.nextWicket,
  });
}

class NextBallSelectorDisabledState extends NextBallSelectorState {}
