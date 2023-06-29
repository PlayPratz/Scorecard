import 'package:flutter/material.dart';
import 'package:scorecard/models/team.dart';
import '../../models/cricket_match.dart';

class MatchTile extends StatelessWidget {
  final CricketMatch match;

  final void Function()? onTap;
  final void Function()? onLongPress;
  // final bool isLive;
  const MatchTile({
    super.key,
    required this.match,
    this.onTap,
    this.onLongPress,
    // this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    late final Team primaryTeam;
    late final Team secondaryTeam;

    final hasStarted = match.inningsList.isNotEmpty;

    switch (match.matchState) {
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _wTeamNameChip(match.homeTeam),
                    _wTeamNameChip(match.awayTeam),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  children: [
                    // const Spacer(),
                    if (hasStarted)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${match.currentInnings.strOvers}/${match.maxOvers} overs",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (match.matchState == MatchState.secondInnings ||
                                match.matchState == MatchState.completed)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: _wFirstInningsScore(context),
                              )
                          ],
                        ),
                      ),
                    CircleAvatar(
                      child: Text('v'),
                      backgroundColor: secondaryTeam.color.withOpacity(0.25),
                      foregroundColor: Colors.white,
                    ),
                    if (hasStarted)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              match.currentInnings.strScore,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.merge(
                                    const TextStyle(color: Colors.white),
                                  ),
                            )
                          ],
                        ),
                      ),
                    // const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
              text: match.firstInnings!.strScore,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.merge(const TextStyle(color: Colors.white)),
            ),
            const TextSpan(text: " in "),
            TextSpan(text: match.firstInnings!.strOvers),
            // const TextSpan(text: " overs"),
          ],
        ),
      );

  Widget _wTeamNameChip(Team team) => Container(
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
