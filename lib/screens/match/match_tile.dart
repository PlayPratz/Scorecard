import 'package:flutter/material.dart';
import '../../models/cricket_match.dart';
import '../../models/innings.dart';
import '../../models/result.dart';
import '../../styles/color_styles.dart';
import '../../util/strings.dart';
import '../../util/elements.dart';

class MatchTile extends StatelessWidget {
  final CricketMatch match;
  final void Function(CricketMatch match)? onSelectMatch;
  final void Function(CricketMatch match)? onLongPress;

  const MatchTile({
    required this.match,
    this.onSelectMatch,
    this.onLongPress,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: ColorStyles.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: InkWell(
        onTap: onSelectMatch != null ? () => onSelectMatch!(match) : null,
        onLongPress: onLongPress != null ? () => onLongPress!(match) : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Column(
            children: [
              _wMatchDetails(),
              Row(
                children: [
                  Expanded(
                    child: _InningsTile(match.homeInnings),
                  ),
                  Expanded(
                    child: _InningsTile(match.awayInnings),
                  ),
                ],
              ),
              const Divider(
                thickness: 4,
              ),
              _wSummary(),
              const SizedBox(height: 8)
            ],
          ),
        ),
      ),
    );
  }

  Widget _wMatchDetails() {
    String text = match.isSuperOver
        ? Strings.matchScreenSuperOver
        : match.maxOvers.toString() + Strings.scoreOvers;
    return Align(
      alignment: Alignment.centerRight,
      child: Text(text),
    );
  }

  Widget _wSummary() {
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
        if (match.firstInnings.ballsBowled == 0) {
          textSpan = [
            TextSpan(
              text: match.toss!.winningTeam.shortName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: Strings.scoreWonToss),
            TextSpan(text: Strings.getTossChoice(match.toss!.choice)),
          ];
          break;
        }
        // Projected score
        textSpan = [
          TextSpan(
            text: match.firstInnings.battingTeam.shortName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(text: Strings.scoreWillScore),
          TextSpan(
              text: "PROJECTED SCORE HERE",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const TextSpan(text: Strings.scoreRunsAtCurrentRate),
          TextSpan(
              text: "RPO HERE",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const TextSpan(text: Strings.scoreRunsPerOver),
        ];
        break;
      case MatchState.secondInnings:
        // Chasing, required rate
        int runsRequired = -1;
        int ballsLeft = -1;
        double runRateRequired = -1;
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
        if (ballsLeft > 6) {
          textSpan.addAll([
            const TextSpan(text: Strings.scoreAt),
            TextSpan(
              text: runRateRequired.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            runRateRequired == 1
                ? const TextSpan(text: Strings.scoreRunsPerOverSingle)
                : const TextSpan(text: Strings.scoreRunsPerOver),
          ]);
        }
        break;
      case MatchState.completed:
        Result matchResult = match.result;
        switch (matchResult.getVictoryType()) {
          case VictoryType.defending:
            // win by ____ runs
            matchResult = matchResult as ResultWinByDefending;
            textSpan = [
              TextSpan(
                text: matchResult.winner!.name,
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
                text: matchResult.winner!.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: Strings.scoreWinWith),
              // TextSpan(
              //   text: matchResult.wicketsLeft.toString(),
              //   style: const TextStyle(fontWeight: FontWeight.bold),
              // ),
              // matchResult.wicketsLeft == 1
              //     ? const TextSpan(text: Strings.scoreWinByWicketSingle)
              //     : const TextSpan(text: Strings.scoreWinByWickets),
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
      padding: const EdgeInsets.only(top: 12.0, right: 4, left: 4),
      child: FittedBox(
        fit: BoxFit.contain,
        child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: textSpan,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w300,
                fontSize: 14,
              ),
            )),
      ),
    );
  }
}

class _InningsTile extends StatelessWidget {
  final Innings innings;

  const _InningsTile(this.innings);

  @override
  Widget build(BuildContext context) {
    String score = innings.runs.toString() +
        Strings.seperatorSlash +
        innings.wickets.toString();
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      // tileColor: innings.battingTeam.color,
      minVerticalPadding: 8,
      minLeadingWidth: 0,
      // horizontalTitleGap: 0,
      dense: false,
      leading: Elements.getOnlineIndicator(true),
      title: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: innings.battingTeam.color.withOpacity(0.8),
        ),
        child: Text(
          innings.battingTeam.name.toUpperCase(),
          style: Theme.of(context).textTheme.titleSmall?.merge(const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              )),
        ),
      ),
      // subtitle: Padding(
      //   padding: const EdgeInsets.symmetric(vertical: 8),
      //   child: _wScoreDisplay(context),
      // ),
      trailing: const SizedBox(width: 12),
    );
  }

  // Widget _wScoreDisplay(BuildContext context) {
  //   if (innings.isInPlay || innings.isCompleted) {
  //     String score = innings.runs.toString() +
  //         Strings.seperatorSlash +
  //         innings.wickets.toString();
  //     TextTheme textTheme = Theme.of(context).textTheme;

  //     return RichText(
  //       text: TextSpan(children: [
  //         TextSpan(text: score, style: textTheme.bodyLarge),
  //         TextSpan(text: Strings.scoreIn, style: textTheme.bodySmall),
  //         TextSpan(text: innings.oversBowled, style: textTheme.bodyLarge),
  //         TextSpan(
  //             text: Strings.bracketOpenWithSpace, style: textTheme.bodySmall),
  //         TextSpan(
  //             text: innings.maxOvers.toString(), style: textTheme.bodySmall),
  //         TextSpan(text: Strings.bracketClose, style: textTheme.bodySmall),
  //       ]),
  //     );
  //   } else {
  //     return RichText(
  //         text: TextSpan(
  //       style: Theme.of(context).textTheme.bodySmall,
  //       text: Strings.scoreYetToBat,
  //     ));
  //   }
  // }
}
