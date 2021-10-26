import 'package:flutter/material.dart';
import 'package:scorecard/models/cricketmatch.dart';
import 'package:scorecard/styles/colorstyles.dart';
import 'package:scorecard/styles/strings.dart';

class MatchTile extends StatelessWidget {
  final CricketMatch match;

  const MatchTile({required this.match, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        // height: 120,
        decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.indigoAccent, width: 2)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              getMatchDetails(),
              const Divider(),
              _InningsTile(match.homeInnings),
              _InningsTile(match.awayInnings),
              const Divider(),
              getSummary()
            ],
          ),
        ),
      ),
    );
  }

  Widget getSummary() {
    List<TextSpan> textSpan;
    if (!match.isTossCompleted) {
      textSpan = [
        const TextSpan(text: Strings.scoreMatchNotStarted),
      ];
    } else if (match.secondInnings.isInPlay || match.firstInnings.isCompleted) {
      // Chasing
      textSpan = [
        TextSpan(
          text: match.secondInnings.battingTeam.shortName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const TextSpan(text: Strings.scoreRequire),
        TextSpan(
          text: match.secondInnings.runsRequired.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const TextSpan(
          text: Strings.scoreRunsIn,
        ),
        TextSpan(
          text: match.secondInnings.ballsRemaining.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const TextSpan(
          text: Strings.scoreBalls,
        ),
        TextSpan(
          text: match.secondInnings.runRateRequired.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const TextSpan(
          text: Strings.scoreRunsPerOver,
        )
      ];
    } else if (match.firstInnings.isInPlay) {
      // Projected
      textSpan = [
        TextSpan(
          text: match.firstInnings.battingTeam.shortName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const TextSpan(text: Strings.scoreWillScore),
        TextSpan(
            text: match.firstInnings.runsProjected.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const TextSpan(text: Strings.scoreRunsAtCurrentRate),
        TextSpan(
            text: match.firstInnings.runRatePerOver.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const TextSpan(text: Strings.scoreRunsPerOver),
      ];
    } else {
      textSpan = [
        TextSpan(
          text: match.toss!.winningTeam.shortName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const TextSpan(text: Strings.scoreWonToss),
        TextSpan(text: Strings.getTossChoice(match.toss!.choice)),
      ];
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, right: 8, left: 8),
      child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: textSpan,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          )),
    );
  }

  Widget getMatchDetails() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const Spacer(),
          Text(match.maxOvers.toString() + Strings.scoreOvers)
        ],
      ),
    );
  }
}

class _InningsTile extends StatelessWidget {
  final Innings innings;

  const _InningsTile(this.innings);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        minVerticalPadding: 0,
        minLeadingWidth: 0,
        dense: true,
        leading: Container(
          height: 10,
          width: 10,
          decoration: innings.isInPlay
              ? const BoxDecoration(
                  color: ColorStyles.currentlyBatting,
                  shape: BoxShape.circle,
                )
              : null,
        ),
        title: Text(
          innings.battingTeam.name,
          style: Theme.of(context)
              .textTheme
              .subtitle1
              ?.merge(const TextStyle(fontWeight: FontWeight.bold)),
        ),
        trailing: getScore(context));
  }

  Widget getScore(BuildContext context) {
    if (innings.isInPlay || innings.isCompleted) {
      String score = innings.runs.toString() + "/" + innings.wickets.toString();
      TextTheme textTheme = Theme.of(context).textTheme;

      return RichText(
        text: TextSpan(children: [
          TextSpan(text: score, style: textTheme.subtitle1),
          TextSpan(text: Strings.scoreIn, style: textTheme.caption),
          TextSpan(text: innings.oversBowled, style: textTheme.subtitle1),
        ]),
      );
    } else {
      return RichText(
          text: TextSpan(
        style: Theme.of(context).textTheme.caption,
        text: Strings.scoreYetToBat,
      ));
    }
  }
}
