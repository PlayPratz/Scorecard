import 'package:flutter/material.dart';
import 'package:scorecard/models/cricketmatch.dart';
import 'package:scorecard/models/result.dart';
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
          color: ColorStyles.card,
          borderRadius: BorderRadius.circular(12),
          // border: Border.all(color: Colors.indigoAccent, width: 2)
        ),
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
    switch (match.matchState) {
      case MatchState.notStarted:
        // Not started
        textSpan = [
          const TextSpan(text: Strings.scoreMatchNotStarted),
        ];
        break;
      case MatchState.tossCompleted:
        textSpan = [
          TextSpan(
            text: match.toss!.winningTeam.shortName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(text: Strings.scoreWonToss),
          TextSpan(text: Strings.getTossChoice(match.toss!.choice)),
        ];
        break;
      case MatchState.firstInnings:
        // Projected score
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
        break;
      case MatchState.secondInnings:
        // Chasing, required rate
        int runsRequired = match.secondInnings.runsRequired;
        int ballsLeft = match.secondInnings.ballsRemaining;
        double runRateRequired = match.secondInnings.runRateRequired;
        textSpan = [
          TextSpan(
            text: match.secondInnings.battingTeam.shortName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(text: Strings.scoreRequire),
          TextSpan(
            text: runsRequired.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          runsRequired == 1
              ? const TextSpan(text: Strings.scoreRunsInSingle)
              : const TextSpan(text: Strings.scoreRunsIn),
          TextSpan(
            text: ballsLeft.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          ballsLeft == 1
              ? const TextSpan(text: Strings.scoreBallSingle)
              : const TextSpan(text: Strings.scoreBalls),
        ];
        if (ballsLeft > 30) {
          textSpan.addAll([
            const TextSpan(text: Strings.scoreAt),
            TextSpan(
              text: runRateRequired.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            runRateRequired == 1
                ? const TextSpan(text: Strings.scoreRunsPerOverSingle)
                : const TextSpan(text: Strings.scoreRunsPerOver),
          ]);
        }
        break;
      case MatchState.completed:
        Result matchResult = match.generateResult();
        switch (matchResult.getVictoryType()) {
          case VictoryType.defending:
            // win by ____ runs
            matchResult = matchResult as ResultWinByDefending;
            textSpan = [
              TextSpan(
                text: matchResult.winner.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: Strings.scoreWinBy),
              TextSpan(
                text: matchResult.runsWonBy.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              matchResult.runsWonBy == 1
                  ? const TextSpan(text: Strings.scoreWinByRunSingle)
                  : const TextSpan(text: Strings.scoreWinByRuns),
            ];
            break;
          case VictoryType.chasing:
            // win by ____ wickets with ____ balls to spare
            matchResult = matchResult as ResultWinByChasing;
            textSpan = [
              TextSpan(
                text: matchResult.winner.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: Strings.scoreWinBy),
              TextSpan(
                text: matchResult.wicketsLeft.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              matchResult.wicketsLeft == 1
                  ? const TextSpan(text: Strings.scoreWinByWicketSingle)
                  : const TextSpan(text: Strings.scoreWinByWickets),
              TextSpan(
                text: matchResult.ballsLeft.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              matchResult.ballsLeft == 1
                  ? const TextSpan(text: Strings.scoreWinByBallsToSpareSingle)
                  : const TextSpan(text: Strings.scoreWinByBallsToSpare),
            ];
            break;
          case VictoryType.tie:
            matchResult = matchResult as ResultTie;
            textSpan = [const TextSpan(text: Strings.scoreMatchTied)];
            break;
          default:
            // TODO Exception
            throw UnimplementedError();
        }
        break;
      default:
        // TODO Exception
        throw UnimplementedError();
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
