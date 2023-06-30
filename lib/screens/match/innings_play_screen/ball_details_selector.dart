import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/models/ball.dart';
import 'package:scorecard/state_managers/innings_manager.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/util/strings.dart';

const _borderColor = Colors.white24;

class RunSelector extends StatelessWidget {
  const RunSelector({super.key});

  static const List<int> runList = [0, 1, 2, 3, 4, 5, 6];

  @override
  Widget build(BuildContext context) {
    final selectedRuns = context
        .select<InningsManager, int>((inningsManager) => inningsManager.runs);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: runList.map((run) {
        final inningsManager = context.read<InningsManager>();
        final battingTeam = inningsManager.innings.battingTeam;

        late final Color foregroundColor;
        late final Color backgroundColor;

        if (selectedRuns == run) {
          foregroundColor = Colors.white;
          if (selectedRuns == 4) {
            backgroundColor = ColorStyles.ballFour;
          } else if (selectedRuns == 6) {
            backgroundColor = ColorStyles.ballSix;
          } else {
            backgroundColor = battingTeam.color;
          }
        } else if (run == 4) {
          foregroundColor = ColorStyles.ballFour;
          backgroundColor = ColorStyles.background;
        } else if (run == 6) {
          foregroundColor = ColorStyles.ballSix;
          backgroundColor = ColorStyles.background;
        } else {
          foregroundColor = Colors.white;
          backgroundColor = ColorStyles.background;
        }
        return GestureDetector(
          onTap: () => inningsManager.setRuns(run),
          child: CircleAvatar(
            radius: 20.5,
            backgroundColor: _borderColor,
            child: CircleAvatar(
              radius: 20, // default
              foregroundColor: foregroundColor,
              backgroundColor: backgroundColor,
              child: Text(Strings.getRunText(run)),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ExtraSelector extends StatelessWidget {
  const ExtraSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _wBattingExtraSelection(context),
        _wBowlingExtraSelection(context),
      ],
    );
  }

  Widget _wBattingExtraSelection(BuildContext context) {
    return Row(
        children: BattingExtra.values.map((battingExtra) {
      final inningsManager = context.read<InningsManager>();
      final selectedBattingExtra =
          context.select<InningsManager, BattingExtra?>(
              (inningsManager) => inningsManager.battingExtra);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FilterChip(
            showCheckmark: false,
            padding: const EdgeInsets.all(0),
            side: const BorderSide(color: _borderColor, width: 0.5),
            // selectedColor: backgroundColor,
            label: Text(Strings.getBattingExtra(battingExtra),
                style: Theme.of(context).textTheme.labelMedium
                // ?.merge(TextStyle(color: foregroundColor)),
                ),
            selected: battingExtra == selectedBattingExtra,
            onSelected: (isSelected) {
              if (isSelected) {
                inningsManager.setBattingExtra(battingExtra);
              } else {
                inningsManager.setBattingExtra(null);
              }
            }),
      );
    }).toList());
  }

  Widget _wBowlingExtraSelection(BuildContext context) {
    return Row(
        children: BowlingExtra.values.map((bowlingExtra) {
      final inningsManager = context.read<InningsManager>();
      final selectedBowlingExtra =
          context.select<InningsManager, BowlingExtra?>(
              (inningsManager) => inningsManager.bowlingExtra);
      late final Color? backgroundColor;
      late final Color foregroundColor;

      if (bowlingExtra == selectedBowlingExtra) {
        foregroundColor = ColorStyles.background;
        if (bowlingExtra == BowlingExtra.noBall) {
          backgroundColor = ColorStyles.ballNoBall;
        } else {
          // Wide
          backgroundColor = Colors.white;
        }
      } else {
        backgroundColor = ColorStyles.background;
        foregroundColor = Colors.white;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FilterChip(
            // showCheckmark: false,
            selectedColor: backgroundColor,
            side: const BorderSide(color: _borderColor, width: 0.5),
            label: Text(
              Strings.getBowlingExtra(bowlingExtra),
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.merge(TextStyle(color: foregroundColor)),
            ),
            selected: bowlingExtra == selectedBowlingExtra,
            onSelected: (isSelected) {
              if (isSelected) {
                inningsManager.setBowlingExtra(bowlingExtra);
              } else {
                inningsManager.setBowlingExtra(null);
              }
            }),
      );
    }).toList());
  }
}
