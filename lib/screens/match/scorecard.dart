import 'package:flutter/material.dart';
import 'package:scorecard/models/cricket_match.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/models/statistics.dart';
import 'package:scorecard/screens/match/innings_play_screen/recent_balls.dart';
import 'package:scorecard/screens/match/match_tile.dart';
import 'package:scorecard/screens/templates/titled_page.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/utils.dart';

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

class _ScorecardMatchPanel extends StatelessWidget {
  final CricketMatch match;
  const _ScorecardMatchPanel({required this.match});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MatchTile(match: match, showSummaryLine: true),
        const SizedBox(height: 8),
        for (int i = 0; i < match.inningsList.length; i++)
          _InningsPanel(match.inningsList[i], i + 1)
      ],
    );
  }
}

class _InningsPanel extends StatelessWidget {
  final Innings innings;
  final int inningsIndex;
  const _InningsPanel(this.innings, this.inningsIndex);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      surfaceTintColor: innings.battingTeam.color,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(width: 4),
                Text(
                  Strings.getInningsHeaderForIndex(inningsIndex),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TeamChip(team: innings.battingTeam),
                const SizedBox(width: 4),
              ],
            ),
            const SizedBox(height: 16),
            _BattingInningsPanel(innings),
            const SizedBox(height: 16),
            _FallOfWicketsPanel(innings),
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
      color: innings.battingTeam.color.withOpacity(0.4),
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
          ...innings.batterInningsList.map((batterInnings) => Column(
                children: [
                  const Divider(
                    color: Colors.black12,
                    height: 0,
                  ),
                  BatterInningsScore(batterInnings: batterInnings),
                ],
              ))
        ],
      ),
    );
  }
}

// TODO Abstract common code from _BattingInningsPanel
class _FallOfWicketsPanel extends StatelessWidget {
  final Innings innings;

  const _FallOfWicketsPanel(this.innings);

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: innings.battingTeam.color,
      color: innings.battingTeam.color.withOpacity(0.4),
      elevation: 4,
      margin: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              Strings.scorecardFallOfWickets.toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.titleMedium!,
              child: Table(
                // defaultColumnWidth: FlexColumnWidth(1),
                columnWidths: const {
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(3),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: const TableBorder(
                    horizontalInside: BorderSide(color: Colors.black12)),
                children: [
                  for (final fallOfWicket in innings.fallOfWickets)
                    TableRow(
                      children: [
                        SizedBox(
                          height: 36, // To space the rows
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                "${fallOfWicket.ball.overIndex}.${fallOfWicket.ball.ballIndex}"),
                          ),
                        ), //TODO Abstract
                        Text(
                            "${fallOfWicket.runsAtWicket}/${fallOfWicket.wicketsAtWicket}"),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(fallOfWicket.wicket.batter.name),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(Strings.getWicketDescription(
                                  fallOfWicket.wicket))),
                        ),
                      ],
                    )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// TODO Convert to Stateless Widget
Widget _wBowlingPanel(BuildContext context, Innings innings) {
  return _innerPanel(
      context,
      Strings.scorecardBowling,
      innings.bowlingTeam.color,
      innings.bowlerInningsList
          .map((bowlInn) => BowlerInningsScore(bowlerInnings: bowlInn))
          .toList());
}

Widget _innerPanel(BuildContext context, String heading, Color color,
    List<Widget> playerTiles) {
  return Card(
    margin: const EdgeInsets.all(0),
    surfaceTintColor: color,
    color: color.withOpacity(0.4),
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
  final BatterInnings batterInnings;
  const BatterInningsScore({super.key, required this.batterInnings});

  @override
  Widget build(BuildContext context) {
    final player = batterInnings.batter;
    final strikeRate = batterInnings.strikeRate;

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
          const SizedBox(width: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
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
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  strikeRate.isNaN
                      ? ""
                      : batterInnings.strikeRate.toStringAsFixed(2),
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
                      batterInnings.fours.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    )),
                const SizedBox(width: 3),
                CircleAvatar(
                    backgroundColor: ColorStyles.ballSix.withOpacity(0.7),
                    radius: 15,
                    foregroundColor: Colors.white,
                    child: Text(batterInnings.sixes.toString(),
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
