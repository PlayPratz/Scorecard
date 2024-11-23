import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/team/models/team_model.dart';
import 'package:scorecard/screens/cricket_game/cricket_game_screen.dart';
import 'package:scorecard/ui/ball_colors.dart';

class LimitedOversScoreSection extends StatelessWidget {
  final LimitedOversScoreState state;

  final void Function()? onTap;

  const LimitedOversScoreSection(this.state, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), TODO FIX
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          child: Center(
            child: Table(
              // defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {1: FlexColumnWidth(0.4)},
              children: [
                TableRow(children: [
                  Text(
                    state.battingTeam.name.toUpperCase(),
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.right,
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.bottom,
                    child: CircleAvatar(
                      backgroundColor: BallColors.background,
                      radius: 12,
                      child: Text(
                        'v',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  Text(state.bowlingTeam.name.toUpperCase(),
                      style: Theme.of(context).textTheme.titleSmall),
                ]),
                TableRow(children: [
                  Text(
                    "${state.runs}-${state.wickets}",
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(),
                  Text("Overs ${state.currentIndex}/${state.oversToBowl}"),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

sealed class LimitedOversScoreState {
  final int runs;
  final int wickets;

  final Team battingTeam;
  final Team bowlingTeam;

  final InningsIndex currentIndex;
  final int oversToBowl;

  final bool isFirstTeamBatting;

  LimitedOversScoreState({
    required this.runs,
    required this.wickets,
    required this.battingTeam,
    required this.bowlingTeam,
    required this.currentIndex,
    required this.oversToBowl,
    required this.isFirstTeamBatting,
  });

  // LimitedOversScoreState.fromGameScreenState(CricketGameScreenState state,
  //     {required this.isLeftTeamBatting})
  //     : battingTeam = state.battingTeam,
  //       bowlingTeam = state.bowlingTeam,
  //       currentIndex = state.latestPost.index,
  //       runs = state.runs,
  //       wickets = state.wickets,
  //       oversToBowl = state.rules.ovre;
}

class LimitedOversScoreFirstInningsState extends LimitedOversScoreState {
  LimitedOversScoreFirstInningsState({
    required super.runs,
    required super.wickets,
    required super.battingTeam,
    required super.bowlingTeam,
    required super.currentIndex,
    required super.oversToBowl,
    required super.isFirstTeamBatting,
  });
}

class LimitedOversScoreSecondInningsState extends LimitedOversScoreState {
  final int target;

  LimitedOversScoreSecondInningsState({
    required super.runs,
    required super.wickets,
    required super.battingTeam,
    required super.bowlingTeam,
    required super.currentIndex,
    required super.oversToBowl,
    required super.isFirstTeamBatting,
    required this.target,
  });
}

class _BattingTeamTile extends StatelessWidget {
  final String teamName;
  final int runs;
  final int wickets;

  final Color color;
  // final Innings innings;
  final bool isLeftAligned;

  const _BattingTeamTile({
    super.key,
    required this.teamName,
    required this.color,
    required this.runs,
    required this.wickets,
    required this.isLeftAligned,
  });

  @override
  Widget build(BuildContext context) {
    // final innings = game.currentInnings;
    return Column(
      crossAxisAlignment:
          isLeftAligned ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          teamName.toUpperCase(),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        // const SizedBox(height: 2),
        Text(
          "$runs-$wickets",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }
}

class _BowlingTeamTile extends StatelessWidget {
  final String teamName;
  final int totalOvers;

  final Color color;
  final InningsIndex currentIndex;

  final bool isLeftAligned;

  const _BowlingTeamTile({
    super.key,
    required this.teamName,
    required this.color,
    required this.currentIndex,
    required this.totalOvers,
    required this.isLeftAligned,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isLeftAligned ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          teamName.toUpperCase(),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Text("Overs $currentIndex/$totalOvers"),
      ],
    );
  }
}

class _NumberBox extends StatelessWidget {
  final num number;
  final String label;

  const _NumberBox({
    super.key,
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Text(
          number is int ? number.toString() : number.toStringAsPrecision(2),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall)
      ]),
    );
  }
}
