import 'package:flutter/material.dart';
import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/cricket_match.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/models/statistics.dart';
import 'package:scorecard/screens/match/innings_play_screen/recent_balls.dart';
import 'package:scorecard/screens/match/match_tile.dart';
import 'package:scorecard/screens/templates/titled_page.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/utils.dart';

class Scorecard extends StatelessWidget {
  final CricketMatch match;
  const Scorecard({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title =
        "${match.home.team.shortName} ${Strings.versus} ${match.away.team.shortName}";

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
      surfaceTintColor: innings.battingTeam.team.color,
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
                TeamChip(team: innings.battingTeam.team),
                const SizedBox(width: 4),
              ],
            ),
            const SizedBox(height: 16),
            _BattingInningsPanel(innings),
            const SizedBox(height: 16),
            _YetToBatPanel(innings),
            const SizedBox(height: 16),
            _FallOfWicketsPanel(innings),
            const SizedBox(height: 16),
            _BowlingInningsPanel(innings),
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
    final extras = innings.balls
        .where((ball) => ball.isBowlingExtra || ball.isBattingExtra);
    final wides =
        extras.where((ball) => ball.bowlingExtra == BowlingExtra.wide);
    final noBalls =
        extras.where((ball) => ball.bowlingExtra == BowlingExtra.noBall);
    final byes = extras.where((ball) => ball.battingExtra == BattingExtra.bye);
    final legByes =
        extras.where((ball) => ball.battingExtra == BattingExtra.legBye);
    return _GenericInningsPanel(
      title: Strings.scorecardBatting.toUpperCase(),
      color: innings.battingTeam.team.color,
      child: Column(
        children: [
          for (final batterInnings in innings.batterInningsList)
            Column(
              children: [
                const Divider(color: Colors.black12, height: 0),
                BatterInningsScore(battingStats: batterInnings),
              ],
            ),
          const Divider(color: Colors.black12, height: 0),
          GenericItemTile(
            primaryHint: "Extras",
            secondaryHint:
                "(${wides.length} wd, ${noBalls.length} nb, ${byes.length} b, ${legByes.length} lb)",
            contentPadding: const EdgeInsets.only(left: 24, right: 64),
            trailing: Text(
              extras.length.toString(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const Divider(color: Colors.black12, height: 0),
          GenericItemTile(
            primaryHint: "Total",
            secondaryHint: Strings.getOverBowledText(innings, short: false),
            contentPadding: const EdgeInsets.only(left: 24, right: 64),
            trailing: Text(
              Strings.getInningsScore(innings),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
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
    final strikeRate = battingStats.strikeRate;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Elements.getPlayerIcon(player, 36, null), //TODO
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
                  child: battingStats is BatterInnings
                      ? Text(
                          Strings.getWicketDescription(
                              (battingStats as BatterInnings).wicket),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.merge(const TextStyle(color: Colors.white70)),
                        )
                      : const SizedBox(),
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
                  strikeRate.isNaN
                      ? ""
                      : battingStats.strikeRate.toStringAsFixed(2),
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

class _YetToBatPanel extends StatelessWidget {
  final Innings innings;

  const _YetToBatPanel(this.innings);

  @override
  Widget build(BuildContext context) {
    final playersThatDidNotBat = innings.battingTeam.squad;
    for (final batterInnings in innings.batterInningsList) {
      playersThatDidNotBat.remove(batterInnings.batter);
    }
    if (playersThatDidNotBat.isEmpty) {
      return const SizedBox();
    }

    return _GenericInningsPanel(
        title: "Yet To Bat".toUpperCase(),
        color: innings.battingTeam.team.color,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
            child: Wrap(
              spacing: 16,
              children: [
                for (final player in playersThatDidNotBat) Text(player.name),
              ],
            ),
          ),
        ));
  }
}

// TODO Abstract common code from _BattingInningsPanel
class _FallOfWicketsPanel extends StatelessWidget {
  final Innings innings;

  const _FallOfWicketsPanel(this.innings);

  @override
  Widget build(BuildContext context) {
    if (innings.fallOfWickets.isEmpty) {
      return const SizedBox();
    }
    return _GenericInningsPanel(
      title: "Fall of Wickets".toUpperCase(),
      color: innings.battingTeam.team.color,
      child: Padding(
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
      ),
    );
  }
}

class _BowlingInningsPanel extends StatelessWidget {
  final Innings innings;

  const _BowlingInningsPanel(this.innings);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      surfaceTintColor: innings.bowlingTeam.team.color,
      color: innings.bowlingTeam.team.color.withOpacity(0.4),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              Strings.scorecardBowling.toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
          ...[
            for (final bowlInn in innings.bowlerInningsList)
              Column(
                children: [
                  const Divider(color: Colors.black12, height: 0),
                  BowlerInningsScore(bowlerInnings: bowlInn)
                ],
              )
          ]
        ],
      ),
    );
  }
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
          Elements.getPlayerIcon(player, 36, null), //TODO
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

class _GenericInningsPanel extends StatelessWidget {
  final String title;
  final Color color;
  final Widget child;

  const _GenericInningsPanel(
      {required this.title, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: color,
      color: color.withOpacity(0.4),
      elevation: 4,
      margin: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
          child
        ],
      ),
    );
  }
}
