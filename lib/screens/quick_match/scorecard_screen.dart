import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/cache/player_cache.dart';
import 'package:scorecard/modules/quick_match/quick_match_model.dart';
import 'package:scorecard/services/quick_match_service.dart';
import 'package:scorecard/ui/ball_colors.dart';
import 'package:scorecard/ui/stringify.dart';

class ScorecardScreen extends StatelessWidget {
  final QuickMatch match;

  ScorecardScreen(this.match, {super.key});

  final _stateStreamController = StreamController<_ScorecardState>();

  @override
  Widget build(BuildContext context) {
    loadInnings(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Scorecard")),
      body: StreamBuilder(
          stream: _stateStreamController.stream,
          builder: (context, snapshot) {
            final state = snapshot.data;
            switch (state) {
              case null:
              case _ScorecardLoadingState():
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              case _ScorecardLoadedState():
                return ListView.builder(
                  itemBuilder: (context, index) =>
                      _InningsScorecard(state.allInnings[index]),
                  itemCount: state.allInnings.length,
                );
            }
          }),
    );
  }

  Future<void> loadInnings(BuildContext context) async {
    final service = context.read<QuickMatchService>();
    final allInnings = await service.loadAllInnings(match);
    await Future.delayed(const Duration(seconds: 1));
    _stateStreamController.add(_ScorecardLoadedState(allInnings));
  }
}

sealed class _ScorecardState {}

class _ScorecardLoadingState extends _ScorecardState {}

class _ScorecardLoadedState extends _ScorecardState {
  final List<QuickInnings> allInnings;

  _ScorecardLoadedState(this.allInnings);
}

class _InningsScorecard extends StatelessWidget {
  final QuickInnings innings;

  const _InningsScorecard(this.innings);

  @override
  Widget build(BuildContext context) {
    final service = context.read<QuickMatchService>();
    getPlayerName(id) => PlayerCache().get(id).name;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TODO make this efficient
            wHeader(context),
            _BattingScorecard(
              service.getBatters(innings),
              score: innings.score,
              target: innings.target,
              extras: innings.extras,
              ballsPerInnings: innings.rules.ballsPerInnings,
              ballsPerOver: innings.rules.ballsPerOver,
              getPlayerName: getPlayerName,
            ),
            const SizedBox(height: 24),
            _BowlingScorecard(
              service.getBowlers(innings),
              getPlayerName: getPlayerName,
            )
          ],
        ),
      ),
    );
  }

  Widget wHeader(BuildContext context) {
    final String header;
    if (innings.inningsNumber == 1) {
      header = "First Innings";
    } else if (innings.inningsNumber == 2) {
      header = "Second Innings";
    } else {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Text(header, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _BattingScorecard extends StatelessWidget {
  final Iterable<BatterInnings> allBatterInnings;

  final String Function(String id) getPlayerName;

  final Score score;
  final int? target;
  final Map<String, int> extras;

  final int ballsPerInnings;
  final int ballsPerOver;

  const _BattingScorecard(
    this.allBatterInnings, {
    required this.score,
    required this.target,
    required this.extras,
    required this.ballsPerInnings,
    required this.ballsPerOver,
    required this.getPlayerName,
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
              const SizedBox(),
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
                        getPlayerName(batterInnings.batterId).toUpperCase(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      // const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                  subtitle: Text(
                    Stringify.wicket(batterInnings.wicket,
                        retired: batterInnings.retired,
                        getPlayerName: getPlayerName),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  // isThreeLine: true,
                  //
                  // onTap: () =>
                  //     _goBattingInningsTimeline(context, batterInnings),
                  contentPadding: EdgeInsets.zero,
                  horizontalTitleGap: 10,
                  minTileHeight: 0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Text(
                    batterInnings.runs.toString(),
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Text(
                    batterInnings.numBalls.toString(),
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
                    _wBoundaryCount(context, batterInnings.boundaryCount[4]!, 4,
                        BallColors.four), // TODO .boundaryCount called twice
                    _wBoundaryCount(context, batterInnings.boundaryCount[6]!, 6,
                        BallColors.six),
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
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Text(
                      "${extras.values.fold(0, (s, e) => s + e)}",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                // Extras
                Text(
                    "(${extras["nb"]}nb ${extras["wd"]}wd ${extras["b"]}b ${extras["lb"]}lb)",
                    style: Theme.of(context).textTheme.bodySmall),
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
                child: Text(Stringify.score(score),
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.right),
              ),
              Text(
                  "(${Stringify.ballCount(ballsPerInnings, ballsPerOver)}${targetString(target)})",
                  style: Theme.of(context).textTheme.bodySmall),
            ]),
          ],
        ),
      ],
    );
  }

  String targetString(int? target) => target == null ? "" : ", Target: $target";

  Widget _wBoundaryCount(
          BuildContext context, int runs, int count, Color color) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0),
        child: CircleAvatar(
          radius: 10,
          backgroundColor: color,
          child: Text(
            count.toString(),
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      );
}

class _BowlingScorecard extends StatelessWidget {
  final Iterable<BowlerInnings> allBowlerInnings;
  final String Function(String id) getPlayerName;

  const _BowlingScorecard(
    this.allBowlerInnings, {
    required this.getPlayerName,
  });

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
                    getPlayerName(bowlerInnings.bowlerId).toUpperCase(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  // trailing: const Icon(Icons.chevron_right, size: 18),
                  // onTap: () => goBowlingTimeline(context, bowlerInnings),
                  contentPadding: EdgeInsets.zero,
                  horizontalTitleGap: 10,
                  minTileHeight: 50,
                ),
                Center(
                    child: Text(Stringify.ballCount(
                        bowlerInnings.numBalls, bowlerInnings.ballsPerOver))),
                Center(child: Text(bowlerInnings.numWickets.toString())),
                Center(child: Text(bowlerInnings.runs.toString())),
                Center(child: Text(Stringify.economy(bowlerInnings.economy)))
              ])
          ],
        ),
      ],
    );
  }

  // void goBowlingTimeline(BuildContext context, BowlerInnings bowlerInnings) {
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => BowlerInningsTimelineScreen(bowlerInnings),
  //       ));
  // }
}
