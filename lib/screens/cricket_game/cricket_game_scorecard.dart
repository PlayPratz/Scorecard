import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/modules/cricket_match/models/wicket_model.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/ui/ball_colors.dart';
import 'package:scorecard/ui/stringify.dart';

class CricketGameScorecard extends StatelessWidget {
  final CricketGame game;
  const CricketGameScorecard(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
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
    return Column(
      children: [
        _BattingScorecardSection(innings.batters,
            captain: innings.battingLineup.captain),
        _YetToBatSection(innings.battingLineup.players, innings.batters),
        _FallOfWicketsSection(innings.wicketBalls),
        _BowlingScorecardSection(innings.bowlers)
      ],
    );
  }
}

class _BattingScorecardSection extends StatelessWidget {
  final Iterable<BatterInnings> allBatterInnings;
  final Player captain;

  const _BattingScorecardSection(
    this.allBatterInnings, {
    super.key,
    required this.captain,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
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
          Text("4s", textAlign: TextAlign.center),
          Text("6s", textAlign: TextAlign.center),
        ]),
        for (final batterInnings in allBatterInnings)
          TableRow(children: [
            ListTile(
              leading: const Icon(Icons.sports_motorsports),
              title: Text(stringifyName(batterInnings.player)),
              subtitle: Text(Stringify.wicket(batterInnings.wicket,
                  retired: batterInnings.retired)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                batterInnings.runs.toString(),
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                batterInnings.ballCount.toString(),
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 11.0),
              child: Text(
                batterInnings.strikeRate.toStringAsFixed(2),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            _wBoundaryCount(batterInnings, 4, BallColors.four),
            _wBoundaryCount(batterInnings, 6, BallColors.six),
          ])
      ],
    );
  }

  Widget _wBoundaryCount(BatterInnings batterInnings, int runs, Color color) =>
      Padding(
        padding: const EdgeInsets.all(2.0),
        child: CircleAvatar(
          backgroundColor: color,
          child: Text(batterInnings.balls
              .where((b) => b.runsScoredByBattingTeam == runs)
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
}

class _FallOfWicketsSection extends StatelessWidget {
  final Iterable<Ball> allWicketBalls;
  const _FallOfWicketsSection(this.allWicketBalls, {super.key});

  @override
  Widget build(BuildContext context) {
    return Table();
  }
}

class _YetToBatSection extends StatelessWidget {
  final Iterable<Player> lineupPlayers;
  final Iterable<BatterInnings> allBatterInnings;

  const _YetToBatSection(
    this.lineupPlayers,
    this.allBatterInnings, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final allYetToBat = lineupPlayers
        .where((p) => allBatterInnings.every((b) => b.player != p));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Yet to Bat"),
        const SizedBox(height: 8),
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
    );
  }
}

class _BowlingScorecardSection extends StatelessWidget {
  final Iterable<BowlerInnings> allBowlerInnings;

  const _BowlingScorecardSection(this.allBowlerInnings, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Bowling"),
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
                ),
                Center(
                    child: Text(stringifyBallCount(
                        bowlerInnings.ballCount, bowlerInnings.ballsPerOver))),
                Center(child: Text(bowlerInnings.wicketCount.toString())),
                Center(child: Text(bowlerInnings.runsConceded.toString())),
                Center(child: Text(stringifyEconomy(bowlerInnings.economy)))
              ])
          ],
        ),
      ],
    );
  }

  String stringifyBallCount(int ballCount, int ballsPerOver) =>
      "${ballCount ~/ ballsPerOver}.${ballCount % ballsPerOver}";

  String stringifyEconomy(double economy) =>
      economy == double.infinity ? '∞' : economy.toStringAsFixed(2);
}
