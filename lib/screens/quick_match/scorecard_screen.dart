import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/cache/player_cache.dart';
import 'package:scorecard/modules/quick_match/quick_match_model.dart';
import 'package:scorecard/screens/quick_match/innings_timeline_screen.dart';
import 'package:scorecard/services/quick_match_service.dart';
import 'package:scorecard/ui/ball_colors.dart';
import 'package:scorecard/ui/stringify.dart';

class ScorecardScreen extends StatelessWidget {
  final QuickMatch match;

  const ScorecardScreen(this.match, {super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ScorecardScreenController(match);
    controller.initialize(context);
    return StreamBuilder(
        stream: controller._stateStreamController.stream,
        builder: (context, snapshot) {
          final state = snapshot.data;
          return Scaffold(
              appBar: AppBar(title: const Text("Scorecard")),
              body: switch (state) {
                null ||
                _ScorecardLoadingState() =>
                  const Center(child: CircularProgressIndicator()),
                _ShowScorecardState() => ListView.builder(
                    itemBuilder: (context, index) =>
                        _InningsScorecard(state.allInnings[index]),
                    itemCount: state.allInnings.length,
                  ),
                _ShowPartnershipsState() => ListView.builder(
                    itemBuilder: (context, index) =>
                        _PartnershipList(index + 1, state.partnerships[index]),
                    itemCount: state.partnerships.length,
                  ),
              },
              bottomNavigationBar: switch (state) {
                null || _ScorecardLoadingState() => const BottomAppBar(),
                _ScorecardLoadedState() => NavigationBar(
                    // labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
                    onDestinationSelected: (index) {
                      if (index == 0) {
                        return controller.showScorecard();
                      }
                      if (index == 1) {
                        return controller.showPartnerships();
                      }
                    },
                    selectedIndex: state.index,
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.list_alt),
                        label: "Scorecard",
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.people),
                        label: "Partnerships",
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.bar_chart),
                        label: "Graphs",
                      ),
                    ],
                  ),
              });
        });
  }
}

class ScorecardScreenController {
  final QuickMatch match;
  late final List<QuickInnings> innings;

  ScorecardScreenController(this.match);

  final _stateStreamController = StreamController<_ScorecardState>();

  Future<void> initialize(BuildContext context) async {
    final matchService = context.read<QuickMatchService>();

    innings = await matchService.loadAllInnings(match);

    await Future.delayed(const Duration(milliseconds: 500));

    showScorecard();
  }

  void showScorecard() {
    _stateStreamController.add(_ShowScorecardState(innings));
  }

  void showPartnerships() {
    _stateStreamController.add(_ShowPartnershipsState(
        innings.map((i) => Partnerships.of(i)).toList()));
  }
}

sealed class _ScorecardState {}

class _ScorecardLoadingState extends _ScorecardState {}

sealed class _ScorecardLoadedState extends _ScorecardState {
  int get index;
}

class _ShowScorecardState extends _ScorecardLoadedState {
  final List<QuickInnings> allInnings;

  _ShowScorecardState(this.allInnings);

  @override
  int get index => 0;
}

class _ShowPartnershipsState extends _ScorecardLoadedState {
  final List<Partnerships> partnerships;

  _ShowPartnershipsState(this.partnerships);

  @override
  int get index => 1;
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
          // crossAxisAlignment: CrossAxisAlignment.c,
          children: [
            FilledButton.icon(
                icon: const Icon(Icons.timeline),
                label: Text(Stringify.inningsHeading(innings.inningsNumber)),
                onPressed: () => goInningsTimeline(context)),
            _BattingScorecard(
              service.getBatters(innings),
              score: innings.score,
              target: innings.target,
              extras: innings.extras,
              ballsPerInnings: innings.rules.ballsPerInnings,
              ballsPerOver: innings.rules.ballsPerOver,
              ballsBowled: innings.numBalls,
              fallOfWickets: FallOfWickets.of(innings),
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

  void goInningsTimeline(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => InningsTimelineScreen(innings)));
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
  final int ballsBowled;

  final FallOfWickets fallOfWickets;

  const _BattingScorecard(
    this.allBatterInnings, {
    required this.score,
    required this.target,
    required this.extras,
    required this.ballsPerInnings,
    required this.ballsPerOver,
    required this.ballsBowled,
    required this.fallOfWickets,
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
            horizontalInside: BorderSide(width: 0, color: Colors.black45),
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
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: batterInnings.isOut
                        ? BallColors.wicket
                        : BallColors.notOut,
                    child: const Icon(Icons.sports_motorsports, size: 20),
                  ),
                  title:
                      Text(getPlayerName(batterInnings.batterId).toUpperCase()),

                  subtitle: Text(
                    Stringify.wicket(batterInnings.wicket,
                        retired: batterInnings.retired,
                        getPlayerName: getPlayerName),
                  ),
                  titleTextStyle: Theme.of(context).textTheme.bodyMedium,
                  subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
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
                    _wBoundaryCount(context, batterInnings.boundaryCount[4]!,
                        BallColors.four), // TODO .boundaryCount called twice
                    _wBoundaryCount(context, batterInnings.boundaryCount[6]!,
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
                child: Text("TOTAL",
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(Stringify.score(score),
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.right),
              ),
              Text(
                  "(${Stringify.ballCount(ballsBowled, ballsPerOver)}${targetString(target)})",
                  style: Theme.of(context).textTheme.bodySmall),
            ]),
          ],
        ),
        const SizedBox(height: 24),
        Text("Fall of wickets", style: Theme.of(context).textTheme.titleMedium),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(),
            1: FlexColumnWidth(),
            2: FlexColumnWidth(7),
            3: FlexColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          border: const TableBorder(
            horizontalInside: BorderSide(width: 0),
          ),
          children: [
            for (final fow in fallOfWickets.all)
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(Stringify.score(fow.scoreAt)),
                ),
                Text(Stringify.postIndex(fow.postIndex)),
                Text("${getPlayerName(fow.wicket.batterId)} "
                    "(${Stringify.wicket(fow.wicket, getPlayerName: getPlayerName)})"),
              ]),
          ],
        )
      ],
    );
  }

  String targetString(int? target) => target == null ? "" : ", Target: $target";

  Widget _wBoundaryCount(BuildContext context, int count, Color color) =>
      Padding(
        padding: const EdgeInsets.only(left: 2.0, bottom: 2.0),
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
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: BallColors.newOver.withOpacity(0.4),
                    child: const Icon(Icons.sports_baseball, size: 20),
                  ),
                  title:
                      Text(getPlayerName(bowlerInnings.bowlerId).toUpperCase()),

                  titleTextStyle: Theme.of(context).textTheme.bodyMedium,
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

class _PartnershipList extends StatelessWidget {
  final Partnerships partnerships;
  final int inningsNumber;

  const _PartnershipList(this.inningsNumber, this.partnerships);

  @override
  Widget build(BuildContext context) {
    getPlayerName(String id) => PlayerCache().get(id).name.toUpperCase();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              Stringify.inningsHeading(inningsNumber),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              defaultColumnWidth: const FixedColumnWidth(110),
              columnWidths: const {
                1: FlexColumnWidth(1.5),
              },
              children: [
                for (final partnership in partnerships.all)
                  TableRow(
                    children: [
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(right: 8),
                            alignment: Alignment.centerRight,
                            child: Text(getPlayerName(partnership.batter1Id)),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 8),
                            alignment: Alignment.centerRight,
                            child: Text(Stringify.batterScore(
                                partnership.batter1Innings)),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: partnership.batter1Innings.runs,
                                child: const Divider(
                                  color: Colors.teal,
                                  thickness: 10,
                                ),
                              ),
                              Expanded(
                                flex: partnership.batter2Innings.runs,
                                child: const Divider(
                                  color: Colors.tealAccent,
                                  thickness: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 8),
                            alignment: Alignment.centerLeft,
                            child: Text(getPlayerName(partnership.batter2Id)),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 8),
                            alignment: Alignment.centerLeft,
                            child: Text(Stringify.batterScore(
                                partnership.batter2Innings)),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
