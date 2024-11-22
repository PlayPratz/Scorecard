import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';

class CricketGameScorecard extends StatelessWidget {
  final CricketGame game;
  const CricketGameScorecard(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _InningsScorecardSection extends StatelessWidget {
  const _InningsScorecardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _BattingScorecardSection extends StatelessWidget {
  const _BattingScorecardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _FallOfWicketsSection extends StatelessWidget {
  const _FallOfWicketsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _YetToBatSection extends StatelessWidget {
  const _YetToBatSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _BowlingScorecardSection extends StatelessWidget {
  final Iterable<BowlerInnings> bowlerInnings;

  const _BowlingScorecardSection(this.bowlerInnings, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const Text("BOWLING"),
          const SizedBox(height: 8),
          Table(
            children: [
              const TableRow(children: [
                SizedBox(),
                Center(child: Text('O')),
                Center(child: Text('W')),
                Center(child: Text('R')),
                Center(child: Text('econ')),
              ]),
              for (final bowler in bowlerInnings)
                TableRow(children: [
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: Text(bowler.player.name.toUpperCase()),
                  ),
                  Center(
                      child: Text(stringifyBallCount(
                          bowler.ballCount, bowler.ballsPerOver))),
                  Center(child: Text(bowler.wicketCount.toString())),
                  Center(child: Text(bowler.runsConceded.toString())),
                  Center(child: Text(stringifyEconomy(bowler.economy)))
                ])
            ],
          ),
        ],
      ),
    );
  }

  String stringifyBallCount(int ballCount, int ballsPerOver) =>
      "${ballCount / ballsPerOver}.${ballCount % ballsPerOver}";

  String stringifyEconomy(double economy) =>
      economy == double.infinity ? '∞' : economy.toStringAsFixed(2);
}
