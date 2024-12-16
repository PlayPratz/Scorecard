import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/screens/cricket_match/innings_timeline_screen.dart';
import 'package:scorecard/ui/ball_colors.dart';
import 'package:scorecard/ui/stringify.dart';

class CricketMatchScorecard extends StatelessWidget {
  final InitializedCricketMatch cricketMatch;
  final CricketGame game;
  const CricketMatchScorecard(this.cricketMatch, this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        children: [
          for (final innings in game.innings) _InningsScorecardSection(innings)
        ],
      ),
    );
  }
}

class _InningsScorecardSection extends StatelessWidget {
  final Innings innings;
  const _InningsScorecardSection(this.innings);

  @override
  Widget build(BuildContext context) {
    final wicketBalls = innings.wicketBalls;
    final playersWhoHaveBatted = innings.batters.keys.toList();
    final allYetToBat = innings.battingLineup.players
        .where((p) => !playersWhoHaveBatted.contains(p));
    final rules = innings.rules;
    final totalOvers = rules is LimitedOversRules ? rules.oversPerInnings : -1;
    return Card(
      // color: Color(innings.battingTeam.color).withOpacity(0.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Chip(
              label: Text("${innings.battingTeam.short} Innings"),
            ),
            _BattingScorecardSection(
              innings.batters.values,
              captain: innings.battingLineup.captain,
              allExtraBalls: innings.balls
                  .where((b) => b.isBowlingExtra || b.isBattingExtra),
              total: innings.score,
              totalOvers: totalOvers,
            ),
            const SizedBox(height: 8),
            if (allYetToBat.isNotEmpty) _YetToBatSection(allYetToBat),
            const SizedBox(height: 8),
            if (wicketBalls.isNotEmpty)
              _FallOfWicketsSection(
                wicketBalls,
                getScoreAt: (ball) => innings.calculateScore(at: ball),
              ),
            const SizedBox(height: 16),
            const Divider(height: 32),
            _BowlingScorecardSection(innings.bowlers.values)
          ],
        ),
      ),
    );
  }
}

class _BattingScorecardSection extends StatelessWidget {
  final Iterable<BatterInnings> allBatterInnings;

  final Iterable<Ball> allExtraBalls;
  final Score total;
  final int totalOvers;
  final Player captain;

  const _BattingScorecardSection(
    this.allBatterInnings, {
    required this.captain,
    required this.allExtraBalls,
    required this.total,
    required this.totalOvers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Table(
          border: const TableBorder(
            // verticalInside: BorderSide(width: 0.1),
            horizontalInside: BorderSide(width: 0.1),
          ),
          defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          defaultColumnWidth: const FixedColumnWidth(42),
          columnWidths: const {
            0: FlexColumnWidth(),
          },
          children: [
            TableRow(children: [
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
                child: Text("Batting",
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              const Text("R", textAlign: TextAlign.center),
              const Text("B", textAlign: TextAlign.center),
              const Text("SR", textAlign: TextAlign.center),
              const SizedBox()
              // Text("4s/6s", textAlign: TextAlign.center),
            ]),
            for (final batterInnings in allBatterInnings)
              TableRow(children: [
                ListTile(
                  leading: const CircleAvatar(
                    radius: 16,
                    child: Icon(Icons.sports_motorsports, size: 20),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        stringifyName(batterInnings.player),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                      ),
                    ],
                  ),
                  subtitle: Text(
                    Stringify.wicket(batterInnings.wicket,
                        retired: batterInnings.retired),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  // isThreeLine: true,

                  onTap: () =>
                      _goBattingInningsTimeline(context, batterInnings),
                  contentPadding: EdgeInsets.zero,
                  horizontalTitleGap: 10,
                  minTileHeight: 0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Text(
                    batterInnings.runsScored.toString(),
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Text(
                    batterInnings.ballsFaced.toString(),
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Text(
                    batterInnings.strikeRate.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _wBoundaryCount(context, batterInnings, 4, BallColors.four),
                    _wBoundaryCount(context, batterInnings, 6, BallColors.six),
                  ],
                ),
              ])
          ],
        ),
        const SizedBox(height: 12),
        Table(
          border: const TableBorder(
            horizontalInside: BorderSide(width: 0.1),
            top: BorderSide(width: 0.1),
          ),
          columnWidths: const {
            0: FixedColumnWidth(42),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FixedColumnWidth(132),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            TableRow(
              children: [
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text("Extras",
                      style: Theme.of(context).textTheme.bodySmall),
                ),
                ...stringifyExtras(context),
              ],
            ),
            TableRow(children: [
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text("Total".toUpperCase(),
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(Stringify.score(total),
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.right),
              ),
              Text("(${totalOvers.toStringAsFixed(1)})",
                  style: Theme.of(context).textTheme.bodySmall),
            ]),
          ],
        ),
      ],
    );
  }

  Widget _wBoundaryCount(BuildContext context, BatterInnings batterInnings,
          int runs, Color color) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0),
        child: CircleAvatar(
          radius: 10,
          backgroundColor: color,
          child: Text(
            batterInnings.balls
                .where((b) => b.runsScoredByBatter == runs)
                .length
                .toString(),
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      );

  String stringifyName(Player player) {
    final name = player.name.toUpperCase();
    if (player == captain) {
      return "$name (c)";
    } else {
      return name;
    }
  }

  List<Widget> stringifyExtras(BuildContext context) {
    int wides = 0;
    int noBalls = 0;

    int byes = 0;
    int legByes = 0;

    for (final ball
        in allExtraBalls.where((b) => b.isBattingExtra || b.isBowlingExtra)) {
      if (ball.isBattingExtra) {
        byes += ball.runsScoredByBatter;
      }
      if (ball.isBowlingExtra) {
        noBalls += ball.bowlingExtra!.penalty;
      }
    }

    final total = wides + noBalls + byes + legByes;
    return [
      Padding(
        padding: const EdgeInsets.only(right: 4.0),
        child: Text(
          total.toString(),
          style: Theme.of(context).textTheme.titleSmall,
          textAlign: TextAlign.right,
        ),
      ),
      Text("(${noBalls}nb, ${wides}wd, ${byes}b, ${legByes}lb)",
          style: Theme.of(context).textTheme.bodySmall),
    ];
  }

  void _goBattingInningsTimeline(
      BuildContext context, BatterInnings batterInnings) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BatterInningsTimelineScreen(batterInnings)));
  }
}

class _YetToBatSection extends StatelessWidget {
  final Iterable<Player> allYetToBat;

  const _YetToBatSection(this.allYetToBat);

  @override
  Widget build(BuildContext context) {
    return Row(
      // This row enables the child column to take full width
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text("Yet to Bat", style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 2),
            Wrap(
              spacing: 4,
              children: [
                for (final player in allYetToBat) ...[
                  Text(player.name.toUpperCase()),
                  if (player != allYetToBat.lastOrNull) const Text('•'),
                ]
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _FallOfWicketsSection extends StatelessWidget {
  final Iterable<Ball> allWicketBalls;
  final Score Function(Ball ball) getScoreAt;
  const _FallOfWicketsSection(this.allWicketBalls, {required this.getScoreAt});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text("Fall of Wickets", style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Table(
          columnWidths: const {
            0: FixedColumnWidth(64),
            1: FlexColumnWidth(),
            2: FixedColumnWidth(128),
          },
          border: const TableBorder(
            horizontalInside: BorderSide(width: 0.1),
          ),
          children: [
            // const TableRow(children: [
            //   Center(child: Text("Score")),
            //   Center(child: Text("Batter")),
            //   Center(child: Text("Overs"))
            // ]),
            for (final wicketBall in allWicketBalls)
              TableRow(children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 2.0),
                    child: Text(Stringify.score(getScoreAt(wicketBall))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 2.0),
                  child: Text(wicketBall.wicket!.batter.name),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 2.0),
                  child: Text(Stringify.postIndex(wicketBall.index)),
                ),
              ])
          ],
        ),
      ],
    );
  }
}

class _BowlingScorecardSection extends StatelessWidget {
  final Iterable<BowlerInnings> allBowlerInnings;

  const _BowlingScorecardSection(this.allBowlerInnings);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          defaultColumnWidth: const FixedColumnWidth(42),
          columnWidths: const {0: FlexColumnWidth()},
          border: const TableBorder(
            // verticalInside: BorderSide(width: 0.1),
            horizontalInside: BorderSide(width: 0.1),
          ),
          children: [
            TableRow(children: [
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
                child: Text("Bowling",
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              const Center(child: Text('O')),
              const Center(child: Text('W')),
              const Center(child: Text('R')),
              const Center(child: Text('Econ')),
            ]),
            for (final bowlerInnings in allBowlerInnings)
              TableRow(children: [
                ListTile(
                  leading: const CircleAvatar(
                    radius: 18,
                    child: Icon(Icons.sports_baseball),
                  ),
                  title: Text(
                    bowlerInnings.player.name.toUpperCase(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => goBowlingTimeline(context, bowlerInnings),
                  contentPadding: EdgeInsets.zero,
                  horizontalTitleGap: 10,
                  minTileHeight: 50,
                ),
                Center(
                    child: Text(Stringify.ballCount(bowlerInnings.ballsBowled,
                        bowlerInnings.ballsPerOver))),
                Center(child: Text(bowlerInnings.wicketsTaken.toString())),
                Center(child: Text(bowlerInnings.runsConceded.toString())),
                Center(child: Text(Stringify.economy(bowlerInnings.economy)))
              ])
          ],
        ),
      ],
    );
  }

  void goBowlingTimeline(BuildContext context, BowlerInnings bowlerInnings) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BowlerInningsTimelineScreen(bowlerInnings),
        ));
  }
}
