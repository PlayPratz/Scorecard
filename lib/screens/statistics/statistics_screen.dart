import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/modules/player/player_statistics.dart';
import 'package:scorecard/modules/quick_match/post_ball_and_extras_model.dart';
import 'package:scorecard/services/player_service.dart';
import 'package:scorecard/ui/ball_colors.dart';
import 'package:scorecard/ui/stringify.dart';

class AllPlayerStatisticsScreen extends StatefulWidget {
  const AllPlayerStatisticsScreen({super.key});

  @override
  State<AllPlayerStatisticsScreen> createState() =>
      _AllPlayerStatisticsScreenState();
}

class _AllPlayerStatisticsScreenState extends State<AllPlayerStatisticsScreen> {
  late _StatisticsState _state;

  @override
  void initState() {
    super.initState();
    setLoading(0);
    showRunsScoredByAllPlayers();
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    return Scaffold(
      appBar: AppBar(title: const Text("Statistics")),
      body: switch (state) {
        _LoadingState() => const Center(child: CircularProgressIndicator()),
        _BattingStatsState() => ListView.builder(
          itemCount: state.battingStats.length,
          itemBuilder: (context, index) =>
              wBattingStatCard(state.battingStats[index]),
        ),
        _BowlingStatsState() => ListView.builder(
          itemCount: state.bowlingStats.length,
          itemBuilder: (context, index) =>
              wBowlingStatCard(state.bowlingStats[index]),
        ),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: state.index,
        onDestinationSelected: (value) {
          if (value == 0) showRunsScoredByAllPlayers();
          if (value == 1) showWicketsTakenByAllPlayers();
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.directions_run),
            label: "Runs",
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_baseball),
            label: "Wickets",
          ),
        ],
      ),
    );
  }

  Widget wBattingStatCard(BattingStats battingStats) => wStatsCard(
    playerName: battingStats.playerName,
    matches: battingStats.matchesPlayed,
    innings: battingStats.inningsPlayed,
    small: {
      "strike rate": battingStats.strikeRate.toStringAsFixed(2),
      "average": battingStats.average.toStringAsFixed(2),
      "outs": battingStats.outs.toString(),
      "not outs": battingStats.notOuts.toString(),
      "high score": battingStats.highScore.toString(),
    },
    big: battingStats.runsScored,
    subBig: "(${battingStats.ballsFaced})",
    avatar: const Icon(Icons.sports_motorsports),
    circles: {
      BallColors.four: battingStats.foursScored,
      BallColors.six: battingStats.sixesScored,
    },
  );

  Widget wBowlingStatCard(BowlingStats bowlingStats) => wStatsCard(
    playerName: bowlingStats.playerName,
    matches: bowlingStats.matchesPlayed,
    innings: bowlingStats.inningsPlayed,
    small: {
      "economy": Stringify.decimal(bowlingStats.economy),
      "average": Stringify.decimal(bowlingStats.average),
      "strike rate": Stringify.decimal(bowlingStats.strikeRate),
    },
    big: bowlingStats.wicketsTaken,
    subBig:
        "${Stringify.postIndex(PostIndex(bowlingStats.oversBowled, bowlingStats.oversBallsBowled))}ov",
    avatar: const Icon(Icons.sports_baseball),
    circles: {
      BallColors.noBall: bowlingStats.noBallsBowled,
      BallColors.wide: bowlingStats.widesBowled,
    },
  );

  Widget wStatsCard({
    required String playerName,
    required int matches,
    required int innings,
    required Map<String, String> small,
    required int big,
    required String subBig,
    required Widget avatar,
    required Map<Color, int> circles,
  }) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 250,
                child: ListTile(
                  title: Text(playerName.toUpperCase()),
                  titleTextStyle: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  subtitle: Text("$matches MATCHES, $innings INNINGS"),
                  leading: CircleAvatar(child: avatar),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 225,
                child: Table(
                  textBaseline: TextBaseline.alphabetic,
                  defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
                  children: [
                    for (final d in small.keys)
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(d.toUpperCase()),
                            ),
                          ),
                          Text(
                            small[d]!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                big.toString(),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Text(subBig, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final c in circles.entries)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: CircleAvatar(
                        backgroundColor: c.key,
                        radius: 12,
                        child: Text(
                          c.value.toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(),
        ],
      ),
    ),
  );

  void showRunsScoredByAllPlayers() async {
    setLoading(0);
    final runList = await context.read<PlayerService>().getAllBattingStats();
    setState(() {
      _state = _BattingStatsState(0, runList);
    });
  }

  void showWicketsTakenByAllPlayers() async {
    setLoading(1);
    final wicketList = await context.read<PlayerService>().getAllBowlingStats();
    setState(() {
      _state = _BowlingStatsState(1, wicketList);
    });
  }

  void setLoading(int index) {
    setState(() {
      _state = _LoadingState(index);
    });
  }
}

sealed class _StatisticsState {
  final int index;

  _StatisticsState(this.index);
}

class _LoadingState extends _StatisticsState {
  _LoadingState(super.index);
}

class _BattingStatsState extends _StatisticsState {
  final UnmodifiableListView<BattingStats> battingStats;
  _BattingStatsState(super.index, this.battingStats);
}

class _BowlingStatsState extends _StatisticsState {
  final UnmodifiableListView<BowlingStats> bowlingStats;
  _BowlingStatsState(super.index, this.bowlingStats);
}
