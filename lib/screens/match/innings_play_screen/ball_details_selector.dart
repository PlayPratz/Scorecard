import 'package:flutter/material.dart';
import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/states/controllers/ball_details_state.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/util/strings.dart';

class BallDetailsSelector extends StatelessWidget {
  final BallDetailsStateController stateController;
  final Innings innings;

  const BallDetailsSelector(
      {super.key, required this.stateController, required this.innings});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _BattingExtraSelector(stateController: stateController),
            _BallIsEventSelector(stateController: stateController),
            _BowlingExtraSelector(stateController: stateController),
          ],
        ),
        const SizedBox(height: 8),
        _RunSelector(
            stateController: stateController,
            battingTeamColor: innings.battingTeam.color),
      ],
    );
  }
}

const _borderColor = Colors.white24; // TODO Move to theme

class _RunSelector extends StatelessWidget {
  final BallDetailsStateController stateController;
  final Color battingTeamColor;

  const _RunSelector(
      {required this.stateController, required this.battingTeamColor});

  static const List<int> runList = [0, 1, 2, 3, 4, 5, 6];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        initialData: 0,
        stream: stateController.runStateStream,
        builder: (context, snapshot) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: runList.map((run) {
              final selectedRuns = snapshot.data;

              late final Color foregroundColor;
              late final Color backgroundColor;

              if (selectedRuns == run) {
                foregroundColor = Colors.white;
                if (selectedRuns == 4) {
                  backgroundColor = ColorStyles.ballFour;
                } else if (selectedRuns == 6) {
                  backgroundColor = ColorStyles.ballSix;
                } else {
                  backgroundColor = battingTeamColor;
                  // backgroundColor = Colors.white24;
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
                onTap: () => stateController.selectRuns(run),
                child: CircleAvatar(
                  radius: 22.5,
                  backgroundColor: _borderColor,
                  child: CircleAvatar(
                    radius: 22, // default
                    foregroundColor: foregroundColor,
                    backgroundColor: backgroundColor,
                    child: Text(Strings.getRunText(run)),
                  ),
                ),
              );
            }).toList(),
          );
        });
  }
}

// TODO maybe merge BowlingExtraSelector and BattingExtraSelector
// TODO into "Extra Selector" with params to decide color and values

class _BowlingExtraSelector extends StatelessWidget {
  final BallDetailsStateController stateController;

  const _BowlingExtraSelector({required this.stateController});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BowlingExtra?>(
        stream: stateController.bowlingExtraStateStream,
        builder: (context, snapshot) {
          final selectedBowlingExtra = snapshot.data;

          return Row(
              children: BowlingExtra.values.map((bowlingExtra) {
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
                  // checkmarkColor: Colors.black,
                  showCheckmark: false,
                  onSelected: (isSelected) {
                    if (isSelected) {
                      stateController.selectBowlingExtra(bowlingExtra);
                    } else {
                      stateController.selectBowlingExtra(null);
                    }
                  }),
            );
          }).toList());
        });
  }
}

class _BattingExtraSelector extends StatelessWidget {
  final BallDetailsStateController stateController;

  const _BattingExtraSelector({required this.stateController});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BattingExtra?>(
        stream: stateController.battingExtraStateStream,
        builder: (context, snapshot) {
          final selectedBattingExtra = snapshot.data;
          return Row(
              children: BattingExtra.values.map((battingExtra) {
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
                      stateController.selectBattingExtra(battingExtra);
                    } else {
                      stateController.selectBattingExtra(null);
                    }
                  }),
            );
          }).toList());
        });
  }
}

class _BallIsEventSelector extends StatelessWidget {
  final BallDetailsStateController stateController;

  const _BallIsEventSelector({required this.stateController});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stateController.ballIsEventStreamController,
      initialData: false,
      builder: (context, snapshot) {
        final isEvent = snapshot.data;
        return FilterChip(
            label: Text("Event",
                style: Theme.of(context)
                    .textTheme
                    .labelMedium), // TODO Abstract Move
            selected: isEvent!,
            showCheckmark: false,
            selectedColor: ColorStyles.ballEvent,
            side: const BorderSide(color: _borderColor, width: 0.5),
            onSelected: (isSelected) => stateController.setEvent(!isEvent));
      },
    );
  }
}
