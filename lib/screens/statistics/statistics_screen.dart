import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/modules/player/player_statistics.dart';
import 'package:scorecard/services/player_service.dart';
import 'package:scorecard/ui/ball_colors.dart';

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
      appBar: AppBar(
        title: const Text("Statistics"),
      ),
      body: switch (state) {
        _LoadingState() => const Center(child: CircularProgressIndicator()),
        _BattingStatsState() => ListView.builder(
            itemCount: state.battingStats.length,
            itemBuilder: (context, index) => ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.sports_motorsports),
              ),
              title: Text(state.battingStats[index].playerName),
              trailing: Text(state.battingStats[index].runsScored.toString()),
              leadingAndTrailingTextStyle:
                  Theme.of(context).textTheme.titleLarge,
              subtitle: Text("${state.battingStats[index].ballsFaced} balls, "
                  "${state.battingStats[index].outs} outs, "
                  "SR ${state.battingStats[index].strikeRate.toStringAsFixed(2)}"),
            ),
          ),
        _BowlingStatsState() => ListView.builder(
            itemCount: state.bowlingStats.length,
            itemBuilder: (context, index) => ListTile(
              leading: const CircleAvatar(
                backgroundColor: BallColors.newOver,
                child: Icon(Icons.sports_baseball),
              ),
              title: Text(state.bowlingStats[index].playerName),
              trailing: Text(state.bowlingStats[index].wicketsTaken.toString()),
              leadingAndTrailingTextStyle:
                  Theme.of(context).textTheme.titleLarge,
              subtitle: Text("${state.bowlingStats[index].ballsBowled} balls, "
                  "${state.bowlingStats[index].runsConceded} runs, "),
            ),
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
              icon: Icon(Icons.directions_run), label: "Runs"),
          NavigationDestination(
              icon: Icon(Icons.sports_baseball), label: "Wickets"),
        ],
      ),
    );
  }

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
