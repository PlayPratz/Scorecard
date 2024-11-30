import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/ui/ball_colors.dart';
import 'package:scorecard/ui/stringify.dart';

class CricketMatchScorecard extends StatelessWidget {
  final InitializedCricketMatch cricketMatch;
  const CricketMatchScorecard(this.cricketMatch, {super.key});

  @override
  Widget build(BuildContext context) {
    final game = cricketMatch.game;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView(
          children: [
            for (final innings in game.innings)
              _InningsScorecardSection(innings)
          ],
        ),
      ),
    );
  }
}

class _InningsScorecardSection extends StatelessWidget {
  final Innings innings;
  const _InningsScorecardSection(this.innings, {super.key});

  @override
  Widget build(BuildContext context) {
    final wicketBalls = innings.wicketBalls;
    final playersWhoHaveBatted = innings.batters.keys.toList();
    final allYetToBat = innings.battingLineup.players
        .where((p) => !playersWhoHaveBatted.contains(p));
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          children: [
            _BattingScorecardSection(
              innings.batters.values,
              captain: innings.battingLineup.captain,
              allExtraBalls: innings.balls
                  .where((b) => b.isBowlingExtra || b.isBattingExtra),
              total: innings.score,
            ),
            const SizedBox(height: 8),
            if (allYetToBat.isNotEmpty) _YetToBatSection(allYetToBat),
            const SizedBox(height: 8),
            if (wicketBalls.isNotEmpty)
              _FallOfWicketsSection(
                wicketBalls,
                getScoreAt: (ball) => innings.calculateScore(at: ball),
              ),
            const SizedBox(height: 8),
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
  final Player captain;

  const _BattingScorecardSection(
    this.allBatterInnings, {
    super.key,
    required this.captain,
    required this.allExtraBalls,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text("Batting", style: Theme.of(context).textTheme.titleMedium),
        Table(
          border: const TableBorder(
            verticalInside: BorderSide(width: 0.1),
            horizontalInside: BorderSide(width: 0.1),
          ),
          // defaultVerticalAlignment: TableCellVerticalAlignment.top,
          defaultColumnWidth: const FixedColumnWidth(32),
          columnWidths: const {
            0: FlexColumnWidth(),
          },
          children: [
            const TableRow(children: [
              SizedBox(),
              Text("R", textAlign: TextAlign.center),
              Text("B", textAlign: TextAlign.center),
              Text("SR", textAlign: TextAlign.center),
              // Text("4s", textAlign: TextAlign.center),
              SizedBox(),
              // Text("6s", textAlign: TextAlign.center),
            ]),
            for (final batterInnings in allBatterInnings)
              TableRow(children: [
                ListTile(
                  leading: const Icon(Icons.sports_motorsports),
                  title: Text(stringifyName(batterInnings.player)),
                  subtitle: Text(Stringify.wicket(batterInnings.wicket,
                      retired: batterInnings.retired)),
                  contentPadding: EdgeInsets.zero,
                  minTileHeight: 0,

                  // dense: true,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    batterInnings.runsScored.toString(),
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    batterInnings.ballsFaced.toString(),
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    batterInnings.strikeRate.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _wBoundaryCount(batterInnings, 4, BallColors.four),
                    _wBoundaryCount(batterInnings, 6, BallColors.six),
                  ],
                ),
              ])
          ],
        ),
        const SizedBox(height: 12),
        Table(
          columnWidths: const {
            0: FixedColumnWidth(42),
            1: FlexColumnWidth(1),
            2: FixedColumnWidth(48),
            3: FixedColumnWidth(128),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            TableRow(
              children: [
                const SizedBox(height: 32),
                const Text("Extras"),
                ...stringifyExtras(context),
              ],
            ),
            TableRow(children: [
              const SizedBox(height: 32),
              Text("Total", style: Theme.of(context).textTheme.bodyLarge),
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(Stringify.score(total),
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.right),
              ),
              Text("(20.0 ov)", style: Theme.of(context).textTheme.bodySmall),
            ]),
          ],
        ),
        // ListTile(
        //   title: const Text("Extras"),
        //   trailing: stringifyExtras(context),
        // ),
        // ListTile(
        //   title: Text("Total", style: Theme.of(context).textTheme.bodyLarge),
        //   trailing: Text(Stringify.score(total),
        //       style: Theme.of(context).textTheme.titleMedium),
        // ),
      ],
    );
  }

  Widget _wBoundaryCount(BatterInnings batterInnings, int runs, Color color) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: color,
          child: Text(batterInnings.balls
              .where((b) => b.runsScoredByBatter == runs)
              .length
              .toString()),
        ),
      );

  String stringifyName(Player player) {
    final name = player.name;
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
}

class _YetToBatSection extends StatelessWidget {
  final Iterable<Player> allYetToBat;

  const _YetToBatSection(
    this.allYetToBat, {
    super.key,
  });

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
                  Text(player.name),
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
  const _FallOfWicketsSection(this.allWicketBalls,
      {super.key, required this.getScoreAt});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text("Fall of Wickets", style: Theme.of(context).textTheme.titleSmall),
        Table(
          columnWidths: const {
            0: FixedColumnWidth(48),
            1: FlexColumnWidth(),
            2: FixedColumnWidth(48),
          },
          border: const TableBorder.symmetric(
            inside: BorderSide(width: 0.1),
            // outside: BorderSide(width: 0.3 ),
          ),
          children: [
            const TableRow(children: [
              Center(child: Text("#")),
              Center(child: Text("Batter")),
              Center(child: Text("Overs"))
            ]),
            for (final wicketBall in allWicketBalls)
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 2.0),
                  child: Text(Stringify.score(getScoreAt(wicketBall))),
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

  const _BowlingScorecardSection(this.allBowlerInnings, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text("Bowling", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Table(
          defaultColumnWidth: const FixedColumnWidth(42),
          columnWidths: const {0: FlexColumnWidth()},
          border: const TableBorder(
            verticalInside: BorderSide(width: 0.1),
            horizontalInside: BorderSide(width: 0.1),
          ),
          children: [
            const TableRow(children: [
              SizedBox(),
              Center(child: Text('O')),
              Center(child: Text('W')),
              Center(child: Text('R')),
              Center(child: Text('E')),
            ]),
            for (final bowlerInnings in allBowlerInnings)
              TableRow(children: [
                ListTile(
                  leading: const Icon(Icons.people),
                  title: Text(bowlerInnings.player.name),
                  contentPadding: EdgeInsets.zero,
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
}
