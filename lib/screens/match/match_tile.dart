import 'package:flutter/material.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/models/cricket_match.dart';

class MatchTile extends StatelessWidget {
  final CricketMatch match;

  final void Function()? onTap;
  final void Function()? onLongPress;

  final bool showSummaryLine;
  const MatchTile(
      {super.key,
      required this.match,
      this.onTap,
      this.onLongPress,
      this.showSummaryLine = true});

  @override
  Widget build(BuildContext context) {
    late final Team primaryTeam;
    late final Team secondaryTeam;

    final matchState = match.matchState;
    switch (matchState) {
      case MatchState.notStarted:
      case MatchState.tossCompleted:
        primaryTeam = match.homeTeam;
        secondaryTeam = match.awayTeam;
        break;
      case MatchState.firstInnings:
      case MatchState.secondInnings:
        primaryTeam = match.currentInnings.battingTeam;
        secondaryTeam = match.currentInnings.bowlingTeam;
        break;
      case MatchState.completed:
        final result = match.result;
        primaryTeam = result.winner;
        secondaryTeam = result.loser;
        break;
    }

    return Card(
      elevation: 2,
      surfaceTintColor: primaryTeam.color,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32),
          child: Column(
            children: [
              Material(
                textStyle: Theme.of(context).textTheme.titleSmall?.merge(
                      const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                color: Colors.transparent,
                child: _wTeamHeaders(),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  children: [
                    // const Spacer(),
                    Expanded(
                      child: _wTeamBlock(context, matchState, match.homeInnings,
                          match.awayInnings,
                          isRightAligned: false),
                    ),
                    CircleAvatar(
                      child: const Text('v'),
                      backgroundColor: secondaryTeam.color.withOpacity(0.25),
                      foregroundColor: Colors.white,
                    ),

                    Expanded(
                      child: _wTeamBlock(context, matchState, match.awayInnings,
                          match.homeInnings,
                          isRightAligned: true),
                    ),
                    // const Spacer(),
                  ],
                ),
              ),
              if (showSummaryLine)
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: _wSummaryLine(context, matchState),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _wTeamHeaders() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TeamChip(team: match.homeTeam),
        TeamChip(team: match.awayTeam),
      ],
    );
  }

  Widget _wTeamBlock(BuildContext context, MatchState matchState,
      Innings? hereInnings, Innings? thereInnings,
      {required bool isRightAligned}) {
    final crossAxisAlignment =
        isRightAligned ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    // Match is completed
    if (matchState == MatchState.completed) {
      return Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          _wBattingScoreText(context, hereInnings!),
          const SizedBox(height: 8),
          _wBowlingOversText(context, hereInnings, short: true),
        ],
      );
    }

    // Here Team is batting
    if (match.inningsList.isNotEmpty && match.currentInnings == hereInnings) {
      return Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          _wBattingScoreText(context, match.currentInnings),
        ],
      );
    }

    // There Team is batting
    if (match.inningsList.isNotEmpty && match.currentInnings == thereInnings) {
      return Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          _wBowlingOversText(context, match.currentInnings),
          if (match.matchState == MatchState.secondInnings)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: _wFirstInningsScore(context),
            )
        ],
      );
    } else {
      return Align(
          alignment:
              isRightAligned ? Alignment.centerRight : Alignment.centerLeft,
          child: const Text(Strings.scoreYetToBat));
    }
  }

  Widget _wFirstInningsScore(BuildContext context) => Text.rich(
        TextSpan(
          style: Theme.of(context).textTheme.bodySmall,
          children: [
            TextSpan(
              text: match.firstInnings!.battingTeam.shortName,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.merge(const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const TextSpan(text: " "),
            TextSpan(
              text: Strings.getInningsScore(match.firstInnings!),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.merge(const TextStyle(color: Colors.white)),
            ),
            const TextSpan(text: " in "),
            TextSpan(
                text: Strings.getOverBowledText(match.firstInnings!,
                    short: true)),
            // const TextSpan(text: " overs"),
          ],
        ),
      );

  Widget _wSummaryLine(BuildContext context, MatchState matchState) {
    final textStyle = Theme.of(context).textTheme.labelLarge;
    // ?.merge(TextStyle(fontStyle: FontStyle.italic));
    switch (matchState) {
      case MatchState.notStarted:
        return Text(Strings.scoreMatchNotStarted, style: textStyle);
      case MatchState.tossCompleted:
      case MatchState.firstInnings:
        return Text(
          Strings.getTossWinner(match.toss!).toUpperCase(),
          style: textStyle,
        );
      case MatchState.secondInnings:
        return Text(
            Strings.getChaseEquation(match.currentInnings).toUpperCase(),
            style: textStyle);
      case MatchState.completed:
        return Text(Strings.getResult(match.result).toUpperCase(),
            style: textStyle);
    }
  }
}

Widget _wBattingScoreText(BuildContext context, Innings innings) =>
    Text(Strings.getInningsScore(innings),
        style: Theme.of(context).textTheme.displaySmall?.merge(
              const TextStyle(color: Colors.white),
            ));

Widget _wBowlingOversText(BuildContext context, Innings innings,
        {bool short = false}) =>
    Text(
      Strings.getOverBowledText(innings, short: short),
      style: Theme.of(context).textTheme.titleMedium,
    );

class TeamChip extends StatelessWidget {
  final Team team;
  const TeamChip({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: team.color,
        borderRadius: BorderRadius.circular(16),
      ),
      constraints: const BoxConstraints(minWidth: 64),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: Text(team.name.toUpperCase())),
      ),
    );
  }
}

class RunRatePane extends StatelessWidget {
  final bool showChaseRequirement;
  final Innings innings;

  RunRatePane(
      {super.key, required this.showChaseRequirement, required this.innings});

  final showRRR = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: showRRR,
      builder: (context, _, child) => Row(
        children: [
          Expanded(
            child: showRRR.value
                ? _wRunRateBox(
                    context: context,
                    color: innings.battingTeam.color,
                    heading: Strings.scoreRRR,
                    value: innings.requiredRunRate.toStringAsFixed(2),
                    onTap: _handleToggle)
                : _wRunRateBox(
                    context: context,
                    color: innings.battingTeam.color,
                    heading: Strings.scoreCRR,
                    value: innings.currentRunRate.toStringAsFixed(2),
                    onTap: showChaseRequirement ? _handleToggle : null),
          ),
          if (showChaseRequirement) ...<Widget>[
            Expanded(
              child: _wRunRateBox(
                  context: context,
                  color: innings.battingTeam.color,
                  heading: Strings.scoreRequire,
                  value: innings.requiredRuns.toString()),
            ),
            Expanded(
              child: _wRunRateBox(
                  context: context,
                  color: innings.bowlingTeam.color,
                  heading: Strings.scoreBalls,
                  value: innings.ballsLeft.toString()),
            ),
          ] else
            Expanded(
              child: _wRunRateBox(
                  context: context,
                  color: innings.battingTeam.color,
                  heading: Strings.scoreProjected,
                  value: innings.projectedRuns.toString()),
            ),
        ],
      ),
    );
  }

  Card _wRunRateBox({
    required BuildContext context,
    required Color color,
    required String heading,
    required String value,
    VoidCallback? onTap,
  }) =>
      Card(
        elevation: 2,
        color: color.withOpacity(0.3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                FittedBox(
                  child: Text(
                    heading.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge,
                )
              ],
            ),
          ),
        ),
      );

  void _handleToggle() {
    if (showChaseRequirement == true) {
      showRRR.value = !showRRR.value;
    }
  }
}
