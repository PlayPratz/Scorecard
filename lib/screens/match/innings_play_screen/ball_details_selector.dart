import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/models/ball.dart';
import 'package:scorecard/state_managers/innings_manager.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/util/helpers.dart';
import 'package:scorecard/util/strings.dart';

class RunSelector extends StatelessWidget {
  RunSelector({super.key});
  final _runSelection = _RunSelection();

  @override
  Widget build(BuildContext context) {
    final selectedRuns = context
        .select<InningsManager, int>((inningsManager) => inningsManager.runs);
    _runSelection._selectedRuns = selectedRuns;
    return ToggleButtons(
      onPressed: (int index) {
        // The button that is tapped is set to true, and the others to false.
        _runSelection.runIndex = index;
        context.read<InningsManager>().setRuns(_runSelection.runs);
      },
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      fillColor: _runSelection.runs == 4
          ? ColorStyles.ballFour
          : _runSelection.runs == 6
              ? ColorStyles.ballSix
              : ColorStyles.highlight,
      isSelected: _runSelection.booleans,
      children: _runSelection.widgets,
    );
  }
}

class _RunSelection {
  static const List<int> runList = [0, 1, 2, 3, 4, 5, 6];
  int _selectedRuns = 0;

  List<bool> get booleans =>
      runList.map((run) => run == _selectedRuns).toList();

  List<Widget> get widgets => runList.map((run) {
        Color color = Colors.white;
        if (_selectedRuns == run) {
          if (_selectedRuns == 4 || _selectedRuns == 6) {
            color = Colors.white;
          } else {
            color = Colors.black;
          }
        } else if (run == 4) {
          color = ColorStyles.ballFour;
        } else if (run == 6) {
          color = ColorStyles.ballSix;
        }
        return Text(
          Strings.getRunText(run),
          style: TextStyle(color: color),
        );
      }).toList();

  int get runs => _selectedRuns;
  set runIndex(int index) => _selectedRuns = runList[index];

  void clear() {
    _selectedRuns = 0;
  }
}

class ExtraSelector extends StatelessWidget {
  ExtraSelector({super.key});

  final SingleSelectionToggle<BowlingExtra> _bowlingExtraSelection =
      SingleSelectionToggle.withWidgetifier(
          dataList: BowlingExtra.values,
          widgetifier: (bowlingExtra, selection) {
            Color color = ColorStyles.ballWide;
            if (bowlingExtra == selection) {
              color = Colors.black;
            } else if (bowlingExtra == BowlingExtra.noBall) {
              color = ColorStyles.ballNoBall;
            }
            return Text(
              Strings.getBowlingExtra(bowlingExtra),
              style: TextStyle(color: color),
            );
          });
  final SingleSelectionToggle<BattingExtra> _battingExtraSelection =
      SingleSelectionToggle(
    dataList: BattingExtra.values,
    stringifier: Strings.getBattingExtra,
  );

  @override
  Widget build(BuildContext context) {
    final battingExtra = context.select<InningsManager, BattingExtra?>(
        (inningsManager) => inningsManager.battingExtra);

    _battingExtraSelection.selection = battingExtra;

    final bowlingExtra = context.select<InningsManager, BowlingExtra?>(
        (inningsManager) => inningsManager.bowlingExtra);

    _bowlingExtraSelection.selection = bowlingExtra;
    return Row(children: [
      ToggleButtons(
          onPressed: (index) {
            if (index == _battingExtraSelection.index) {
              _battingExtraSelection.clear();
            } else {
              _battingExtraSelection.index = index;
            }
            context
                .read<InningsManager>()
                .setBattingExtra(_battingExtraSelection.selection);
          },
          children: _battingExtraSelection.widgets,
          isSelected: _battingExtraSelection.booleans,
          constraints: const BoxConstraints(
            minHeight: 40.0,
            minWidth: 80.0,
          )),
      const Spacer(),
      ToggleButtons(
          onPressed: (index) {
            if (index == _bowlingExtraSelection.index) {
              _bowlingExtraSelection.clear();
            } else {
              _bowlingExtraSelection.index = index;
            }
            context
                .read<InningsManager>()
                .setBowlingExtra(_bowlingExtraSelection.selection);
          },
          children: _bowlingExtraSelection.widgets,
          isSelected: _bowlingExtraSelection.booleans,
          fillColor: _bowlingExtraSelection.selection != null
              ? ColorStyles.getBowlingExtraColour(
                  _bowlingExtraSelection.selection!)
              : null,
          constraints: const BoxConstraints(
            minHeight: 40.0,
            minWidth: 80.0,
          )),
    ]);
  }
}
