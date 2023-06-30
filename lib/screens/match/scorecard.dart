import 'package:flutter/material.dart';
import 'package:scorecard/models/statistics.dart';
import 'package:scorecard/screens/match/innings_play_screen/recent_balls.dart';
import 'package:scorecard/screens/match/match_tile.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/utils.dart';
import '../../models/cricket_match.dart';
import '../../models/innings.dart';
import '../templates/titled_page.dart';

class Scorecard extends StatelessWidget {
  final CricketMatch match;
  const Scorecard({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = match.homeTeam.shortName +
        Strings.separatorVersus +
        match.awayTeam.shortName;

    return TitledPage(
      appBarActions: [
        IconButton(
          onPressed: () =>
              Elements.showSnackBar(context, text: "Coming soon™!"),
          icon: const Icon(Icons.share),
        )
      ],
      title: title,
      child: SingleChildScrollView(
        child: _ScorecardMatchPanel(match: match),
      ),
    );
  }
}
/*
TODO: The way you have handled the batting scorecard:
If Ishan and Rohit open
Ishan gets out before Rohit ever faces a ball
Virat faces his first ball before Rohit

Then the scorecard will read:
Ishan
Virat
Rohit (if he plays any balls, that is)

Which brings us to the next problem
A batter who faces 0 balls will never make it to the scorecard

Regards,
Past PlayPratz
 */

class _ScorecardMatchPanel extends StatelessWidget {
  final CricketMatch match;
  const _ScorecardMatchPanel({required this.match});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MatchTile(match: match, showSummaryLine: true),
        const SizedBox(height: 16),
        ...match.inningsList.map((innings) => _InningsPanel(innings)).toList()
      ],
    );
  }
}

class _InningsPanel extends StatelessWidget {
  final Innings innings;
  const _InningsPanel(this.innings);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 2,
      surfaceTintColor: innings.battingTeam.color,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              //TODO WTF? It expands if not in a row
              children: [
                TeamChip(team: innings.battingTeam),
              ],
            ),
            const SizedBox(height: 16),
            _BattingInningsPanel(innings),
            const SizedBox(height: 16),
            _wBowlingPanel(context, innings),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: _wViewTimelineButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wViewTimelineButton(BuildContext context) => ElevatedButton.icon(
        onPressed: () =>
            Utils.goToPage(InningsTimelineScreen(innings: innings), context),
        icon: const Icon(Icons.timeline),
        label: const Text(Strings.goToTimeline),
      );
}

class _BattingInningsPanel extends StatelessWidget {
  final Innings innings;
  const _BattingInningsPanel(this.innings);

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: innings.battingTeam.color,
      color: innings.battingTeam.color.withOpacity(0.5),
      elevation: 4,
      margin: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              Strings.scorecardBatting.toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
          ...innings.batterInnings.map((batterInnings) => Column(
                children: [
                  const Divider(
                    color: Colors.black12,
                    height: 0,
                  ),
                  BatterInningsScore(battingStats: batterInnings),
                ],
              ))
        ],
      ),
    );
  }
}

Widget _wBowlingPanel(BuildContext context, Innings innings) {
  return _innerPanel(
      context,
      Strings.scorecardBowling,
      innings.bowlingTeam.color,
      innings.bowlerInnings
          .map((bowlInn) => BowlerInningsScore(bowlerInnings: bowlInn))
          .toList());
}

Widget _innerPanel(BuildContext context, String heading, Color color,
    List<Widget> playerTiles) {
  return Card(
    margin: const EdgeInsets.all(0),
    surfaceTintColor: color,
    color: color.withOpacity(0.5),
    elevation: 4,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            heading.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 16),
        ...playerTiles.map((tile) => Column(
              children: [const Divider(color: Colors.black12, height: 0), tile],
            )),
      ],
    ),
  );
}

class BowlerInningsScore extends StatelessWidget {
  final BowlingStats bowlerInnings;
  const BowlerInningsScore({super.key, required this.bowlerInnings});

  @override
  Widget build(BuildContext context) {
    final player = bowlerInnings.bowler;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Elements.getPlayerIcon(player, 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            Strings.getBowlerOversBowled(bowlerInnings),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: ColorStyles.wicket.withOpacity(0.7),
            foregroundColor: Colors.white,
            radius: 14,
            child: Text(
              bowlerInnings.wicketsTaken.toString(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            bowlerInnings.runsConceded.toString(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(width: 8),
          Text(bowlerInnings.economy.toStringAsFixed(2),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.merge(const TextStyle(color: Colors.white70))),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class BatterInningsScore extends StatelessWidget {
  final BattingStats battingStats;
  const BatterInningsScore({super.key, required this.battingStats});

  @override
  Widget build(BuildContext context) {
    final player = battingStats.batter;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Elements.getPlayerIcon(player, 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    Strings.getWicketDescription(battingStats.wicket),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.merge(const TextStyle(color: Colors.white70)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                battingStats.runs.toString(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(width: 4),
              Text(
                battingStats.ballsFaced.toString(),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.merge(const TextStyle(color: Colors.white70)),
              ),
            ],
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  battingStats.strikeRate.toStringAsFixed(2),
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.merge(const TextStyle(color: Colors.white70)),
                ),
                const SizedBox(width: 6),
                CircleAvatar(
                    backgroundColor: ColorStyles.ballFour.withOpacity(0.7),
                    foregroundColor: Colors.white,
                    radius: 15,
                    child: Text(
                      battingStats.fours.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    )),
                const SizedBox(width: 3),
                CircleAvatar(
                    backgroundColor: ColorStyles.ballSix.withOpacity(0.7),
                    radius: 15,
                    foregroundColor: Colors.white,
                    child: Text(battingStats.sixes.toString(),
                        style: Theme.of(context).textTheme.bodyMedium)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*
  TableRow _wBattingInningsRow(
      BuildContext context, BatterInnings batterInnings) {
    final player = batterInnings.batter;
    return TableRow(children: [
      Elements.getPlayerIcon(player, 36),
      Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              player.name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                Strings.getWicketDescription(batterInnings.wicket),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.merge(const TextStyle(color: Colors.white70)),
              ),
            ),
          ],
        ),
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            batterInnings.runs.toString(),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(width: 4),
          Text(
            batterInnings.ballsFaced.toString(),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.merge(const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
      Text(
        batterInnings.strikeRate.toStringAsFixed(2),
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.merge(const TextStyle(color: Colors.white70)),
      ),
      CircleAvatar(
          backgroundColor: ColorStyles.ballFour.withOpacity(0.7),
          foregroundColor: Colors.white,
          radius: 14,
          child: Text(
            batterInnings.fours.toString(),
            style: Theme.of(context).textTheme.labelMedium,
          )),
      CircleAvatar(
          backgroundColor: ColorStyles.ballSix.withOpacity(0.7),
          radius: 14,
          foregroundColor: Colors.white,
          child: Text(batterInnings.sixes.toString(),
              style: Theme.of(context).textTheme.labelMedium)),
    ]);
  }
 */
