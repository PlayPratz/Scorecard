import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/modules/cache/player_cache.dart';
import 'package:scorecard/modules/quick_match/post_ball_and_extras_model.dart';
import 'package:scorecard/modules/quick_match/quick_match_model.dart';
import 'package:scorecard/screens/quick_match/innings_timeline_screen.dart';
import 'package:scorecard/services/quick_match_service.dart';
import 'package:scorecard/ui/ball_colors.dart';
import 'package:scorecard/ui/stringify.dart';

class ScorecardScreen extends StatefulWidget {
  final int matchId;
  final bool exitToHome;

  const ScorecardScreen(this.matchId, {super.key, this.exitToHome = false});

  @override
  State<ScorecardScreen> createState() => _ScorecardScreenState();
}

class _ScorecardScreenState extends State<ScorecardScreen> {
  late final ScorecardScreenController controller;

  @override
  void initState() {
    super.initState();
    controller = ScorecardScreenController(widget.matchId);
    controller.initialize(context);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: controller._stateStreamController.stream,
      initialData: _ScorecardLoadingState(0),
      builder: (context, snapshot) {
        final state = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: const Text("Scorecard"),
            leading: widget.exitToHome
                ? IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.exit_to_app),
                  )
                : null,
          ),
          body: switch (state) {
            _ScorecardLoadingState() => const Center(
              child: CircularProgressIndicator(),
            ),
            _ShowScorecardState() => ListView.builder(
              itemBuilder: (context, index) =>
                  _InningsScorecard(state.allInnings[index]),
              itemCount: state.allInnings.length,
            ),
            _ShowPartnershipsState() => ListView.builder(
              itemBuilder: (context, index) =>
                  _PartnershipList(index + 1, state.allPartnerships[index]),
              itemCount: state.allPartnerships.length,
            ),
            _ShowGraphsState() => _GraphListSection(
              state.firstBalls,
              state.secondBalls,
              state.firstOvers,
              state.secondOvers,
            ),
          },
          bottomNavigationBar: switch (state) {
            _ScorecardLoadingState() => const BottomAppBar(),
            _ => NavigationBar(
              // labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
              onDestinationSelected: (index) async {
                if (index == 0) {
                  return controller.showScorecard();
                }
                if (index == 1) {
                  return controller.showPartnerships();
                }
                if (index == 2) {
                  return controller.showGraphs();
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
          },
        );
      },
    );
  }
}

class ScorecardScreenController {
  final int matchId;

  late final QuickMatchService service;
  late final List<QuickInnings> allInnings;

  ScorecardScreenController(this.matchId);

  final _stateStreamController = StreamController<_ScorecardState>();

  Future<void> initialize(BuildContext context) async {
    service = context.read<QuickMatchService>();
    allInnings = await service.getAllInningsOf(matchId);
    showScorecard();
  }

  void showScorecard() {
    _stateStreamController.add(_ShowScorecardState(allInnings));
  }

  Future<void> showPartnerships() async {
    showLoading(1);

    final partnerships1 = await service.getPartnerships(allInnings[0]);
    final partnerships2 = allInnings.length > 1
        ? await service.getPartnerships(allInnings[1])
        : null;

    _stateStreamController.add(
      _ShowPartnershipsState([
        partnerships1,
        if (partnerships2 != null) partnerships2,
      ]),
    );
  }

  Future<void> showGraphs() async {
    showLoading(2);

    final firstBalls = await service.getAllBallsOf(allInnings[0]);
    final firstOvers = service.getOversFromPosts(firstBalls);

    final secondBalls = allInnings.length > 1
        ? await service.getAllBallsOf(allInnings[1])
        : const Iterable.empty().cast<Ball>();

    final secondOvers = service.getOversFromPosts(secondBalls);

    _stateStreamController.add(
      _ShowGraphsState(
        firstBalls: firstBalls,
        secondBalls: secondBalls,
        firstOvers: firstOvers,
        secondOvers: secondOvers,
      ),
    );
  }

  void showLoading(int index) {
    _stateStreamController.add(_ScorecardLoadingState(index));
  }
}

sealed class _ScorecardState {
  int get index;
}

class _ScorecardLoadingState extends _ScorecardState {
  final int _index;

  @override
  int get index => _index;

  _ScorecardLoadingState(this._index);
}

class _ShowScorecardState extends _ScorecardState {
  final List<QuickInnings> allInnings;

  _ShowScorecardState(this.allInnings);

  @override
  int get index => 0;
}

class _ShowPartnershipsState extends _ScorecardState {
  final List<Iterable<Partnership>> allPartnerships;

  _ShowPartnershipsState(this.allPartnerships);

  @override
  int get index => 1;
}

class _ShowGraphsState extends _ScorecardState {
  final Iterable<Ball> firstBalls;
  final Iterable<Ball> secondBalls;

  final Map<int, Over> firstOvers;
  final Map<int, Over> secondOvers;

  _ShowGraphsState({
    required this.firstBalls,
    required this.secondBalls,
    required this.firstOvers,
    required this.secondOvers,
  });

  @override
  int get index => 2;
}

class _InningsScorecard extends StatelessWidget {
  final QuickInnings innings;
  // final int? winnerInningsNumber;

  const _InningsScorecard(this.innings);

  @override
  Widget build(BuildContext context) {
    final future = _loadBattersAndBowlers(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: FutureBuilder(
          future: future,
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.done) {
              final data = asyncSnapshot.data!;
              return Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.timeline),
                    label: Text(
                      Stringify.quickInningsHeading(innings.inningsNumber),
                    ),
                    onPressed: () => goInningsTimeline(context),
                  ),
                  _BattingScorecard(
                    data.batters,
                    score: innings.score,
                    target: innings.target,
                    extras: innings.extras,
                    overLimit: innings.ballLimit,
                    ballsPerOver: innings.ballsPerOver,
                    ballsBowled: innings.balls,
                    fallOfWickets: data.fallOfWickets,
                  ),
                  const SizedBox(height: 24),
                  _BowlingScorecard(
                    data.bowlers,
                    ballsPerOver: innings.ballsPerOver,
                  ),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Future<_InningsScorecardData> _loadBattersAndBowlers(
    BuildContext context,
  ) async {
    final service = context.read<QuickMatchService>();

    final batters = await service.getBatters(innings);
    final bowlers = await service.getBowlers(innings);
    final fallOfWickets = await service.getWicketsOf(innings);

    return _InningsScorecardData(batters, bowlers, fallOfWickets);
  }

  void goInningsTimeline(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InningsTimelineScreen(innings)),
    );
  }
}

class _InningsScorecardData {
  final Iterable<BattingScore> batters;
  final Iterable<BowlingScore> bowlers;
  final Iterable<FallOfWicket> fallOfWickets;

  const _InningsScorecardData(this.batters, this.bowlers, this.fallOfWickets);
}

class _BattingScorecard extends StatelessWidget {
  final Iterable<BattingScore> allBattingScores;

  final Score score;
  final int? target;
  final Extras extras;

  final int overLimit;
  final int ballsPerOver;
  final int ballsBowled;

  final Iterable<FallOfWicket> fallOfWickets;

  const _BattingScorecard(
    this.allBattingScores, {
    required this.score,
    required this.target,
    required this.extras,
    required this.overLimit,
    required this.ballsPerOver,
    required this.ballsBowled,
    required this.fallOfWickets,
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
          columnWidths: const {0: FlexColumnWidth()},
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
                  child: Text(
                    "Batting",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Text("R", textAlign: TextAlign.center),
                const Text("B", textAlign: TextAlign.center),
                const Text("SR", textAlign: TextAlign.center),
                const SizedBox(),
              ],
            ),
            for (final battingScore in allBattingScores)
              wBatterTile(battingScore, context),
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
                  child: Text(
                    "Extras",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Text(
                      "${extras.total}",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                // Extras
                Text(
                  "(${extras.noBalls}nb ${extras.wides}wd ${extras.byes}b ${extras.legByes}lb ${extras.penalties}p)",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            TableRow(
              children: [
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    "TOTAL",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    Stringify.score(score),
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.right,
                  ),
                ),
                Text(
                  "(${Stringify.ballCount(ballsBowled, ballsPerOver)}${targetString(target)})",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (fallOfWickets.isNotEmpty)
          Text(
            "Fall of Wickets",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        if (fallOfWickets.isNotEmpty)
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(7),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            border: const TableBorder(horizontalInside: BorderSide(width: 0)),
            children: [
              for (final fow in fallOfWickets)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(Stringify.score(fow.scoreAt)),
                    ),
                    Text(Stringify.postIndex(fow.postIndex)),
                    Text(
                      "${getPlayerName(fow.wicket.batterId)} "
                      "(${Stringify.wicket(fow.wicket, getPlayerName: getPlayerName)})",
                    ),
                  ],
                ),
            ],
          ),
      ],
    );
  }

  TableRow wBatterTile(BattingScore battingScore, BuildContext context) {
    return TableRow(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 16,
            backgroundColor: battingScore.isNotOut
                ? BallColors.notOut
                : BallColors.wicket,
            child: const Icon(Icons.sports_motorsports, size: 20),
          ),
          title: Text(getPlayerName(battingScore.batterId).toUpperCase()),

          subtitle: Text(
            Stringify.wicket(battingScore.wicket, getPlayerName: getPlayerName),
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
            battingScore.runsScored.toString(),
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Text(
            battingScore.ballsFaced.toString(),
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Text(
            battingScore.strikeRate.toStringAsFixed(1),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _wBoundaryCount(context, battingScore.fours, BallColors.four),
            _wBoundaryCount(context, battingScore.sixes, BallColors.six),
          ],
        ),
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
  final Iterable<BowlingScore> allBowlingScores;
  final int ballsPerOver;

  const _BowlingScorecard(this.allBowlingScores, {required this.ballsPerOver});

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
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
                  child: Text(
                    "Bowling",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Center(child: Text('O')),
                const Center(child: Text('W')),
                const Center(child: Text('R')),
                const Center(child: Text('Econ')),
              ],
            ),
            for (final bowlingScore in allBowlingScores)
              TableRow(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: BallColors.newOver.withOpacity(0.4),
                      child: const Icon(Icons.sports_baseball, size: 20),
                    ),
                    title: Text(
                      getPlayerName(bowlingScore.bowlerId).toUpperCase(),
                    ),

                    titleTextStyle: Theme.of(context).textTheme.bodyMedium,
                    // trailing: const Icon(Icons.chevron_right, size: 18),
                    // onTap: () => goBowlingTimeline(context, bowlerInnings),
                    contentPadding: EdgeInsets.zero,
                    horizontalTitleGap: 10,
                    minTileHeight: 50,
                  ),
                  Center(
                    child: Text(
                      Stringify.ballCount(
                        bowlingScore.ballsBowled,
                        ballsPerOver,
                      ),
                    ),
                  ),
                  Center(child: Text(bowlingScore.wicketsTaken.toString())),
                  Center(child: Text(bowlingScore.runsConceded.toString())),
                  Center(child: Text(Stringify.decimal(bowlingScore.economy))),
                ],
              ),
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
  final Iterable<Partnership> partnerships;
  final int inningsNumber;

  const _PartnershipList(this.inningsNumber, this.partnerships);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              Stringify.quickInningsHeading(inningsNumber),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            for (final partnership in partnerships)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 4.0,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          getPlayerName(partnership.batter1Id).toUpperCase(),
                        ),
                        const Spacer(),
                        if (partnership.batter2Id != null)
                          Text(
                            getPlayerName(partnership.batter2Id!).toUpperCase(),
                          ),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: partnership.batter1Runs,
                            child: const Divider(
                              color: Colors.teal,
                              thickness: 10,
                            ),
                          ),
                          Expanded(
                            flex: partnership.batter2Runs,
                            child: Divider(
                              color: BallColors.notOut,
                              thickness: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Stringify.batterScore(
                                partnership.batter1Runs,
                                partnership.batter1Balls,
                                false,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              Stringify.batterScore(
                                partnership.runs,
                                partnership.balls,
                                false,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              Stringify.batterScore(
                                partnership.batter2Runs,
                                partnership.batter2Balls,
                                false,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GraphListSection extends StatelessWidget {
  final Iterable<Ball> firstBalls;
  final Iterable<Ball> secondBalls;

  final Map<int, Over> firstOvers;
  final Map<int, Over> secondOvers;

  const _GraphListSection(
    this.firstBalls,
    this.secondBalls,
    this.firstOvers,
    this.secondOvers,
  );

  @override
  Widget build(BuildContext context) {
    const firstColor = Colors.teal;
    final secondColor = BallColors.notOut;

    const radius = 6.0;
    return ListView(
      children: [
        Row(
          children: [
            Expanded(
              child: ListTile(
                leading: const CircleAvatar(
                  radius: radius,
                  backgroundColor: firstColor,
                ),
                minLeadingWidth: 0,
                title: Text(Stringify.quickInningsHeading(1)),
              ),
            ),
            if (secondBalls.isNotEmpty)
              Expanded(
                child: ListTile(
                  leading: CircleAvatar(
                    radius: radius,
                    backgroundColor: secondColor,
                  ),
                  minLeadingWidth: 0,
                  title: Text(Stringify.quickInningsHeading(2)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: Text("Worm", style: Theme.of(context).textTheme.titleMedium),
        ),
        const SizedBox(height: 16),
        _WormGraph(
          firstBalls: firstBalls,
          secondBalls: secondBalls,
          firstColor: firstColor,
          secondColor: secondColor,
        ),
        const SizedBox(height: 32),
        Center(
          child: Text(
            "Manhattan",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 16),
        _ManhattanGraph(
          firstOvers: firstOvers,
          secondOvers: secondOvers,
          firstColor: firstColor,
          secondColor: secondColor,
        ),
      ],
    );
  }
}

class _WormGraph extends StatelessWidget {
  final Iterable<Ball> firstBalls;
  final Iterable<Ball> secondBalls;

  final Color firstColor;
  final Color secondColor;

  const _WormGraph({
    required this.firstBalls,
    required this.secondBalls,
    required this.firstColor,
    required this.secondColor,
  });
  @override
  Widget build(BuildContext context) {
    double i = 0;
    double j = 0;
    return SizedBox(
      height: 256,
      child: LineChart(
        LineChartData(
          titlesData: const FlTitlesData(topTitles: AxisTitles()),
          lineBarsData: [
            LineChartBarData(
              color: firstColor,
              spots: runsForInnings(
                firstBalls,
              ).map((r) => FlSpot(i++, r)).toList(),
            ),
            if (secondBalls.isNotEmpty)
              LineChartBarData(
                color: secondColor,
                spots: runsForInnings(
                  secondBalls,
                ).map((r) => FlSpot(j++, r)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  List<double> runsForInnings(Iterable<Ball> balls) {
    final runs = <double>[0];
    double score = 0;
    for (final ball in balls) {
      score = score + ball.totalRuns;
      runs.add(score);
    }
    return runs;
  }
}

class _ManhattanGraph extends StatelessWidget {
  final Map<int, Over> firstOvers;
  final Map<int, Over> secondOvers;

  final Color firstColor;
  final Color secondColor;

  const _ManhattanGraph({
    required this.firstOvers,
    required this.secondOvers,
    required this.firstColor,
    required this.secondColor,
  });

  @override
  Widget build(BuildContext context) {
    final count = max(firstOvers.length, secondOvers.length);

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          barGroups: [
            for (int i = 1; i <= count; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  if (firstOvers.containsKey(i))
                    BarChartRodData(
                      toY: firstOvers[i]!.scoreIn.runs.toDouble(),
                      color: firstColor,
                    ),
                  if (secondOvers.containsKey(i))
                    BarChartRodData(
                      toY: secondOvers[i]!.scoreIn.runs.toDouble(),
                      color: secondColor,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

String getPlayerName(int id) => PlayerCache.get(id).name;
