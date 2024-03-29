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
        primaryTeam = match.home.team;
        secondaryTeam = match.away.team;
        break;
      case MatchState.firstInnings:
      case MatchState.secondInnings:
        primaryTeam = match.currentInnings.battingTeam.team;
        secondaryTeam = match.currentInnings.bowlingTeam.team;
        break;
      case MatchState.completed:
        final result = match.result;
        primaryTeam = result.winner.team;
        secondaryTeam = result.loser.team;
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
                      child: const Text(Strings.versus),
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
        TeamChip(team: match.home.team),
        TeamChip(team: match.away.team),
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
              text: match.firstInnings!.battingTeam.team.shortName,
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
        child: Center(child: Text(team.shortName.toUpperCase())),
      ),
    );
  }
}
