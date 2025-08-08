import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/modules/stats/player_statistics.dart';
import 'package:scorecard/services/statistics_service.dart';
import 'package:scorecard/ui/ball_colors.dart';

class AllPlayerStatisticsScreen extends StatefulWidget {
  const AllPlayerStatisticsScreen({super.key});

  @override
  State<AllPlayerStatisticsScreen> createState() =>
      _AllPlayerStatisticsScreenState();
}

class _AllPlayerStatisticsScreenState extends State<AllPlayerStatisticsScreen> {
  late final StatisticsService statisticsService;

  int _index = 0;
  late _StatisticsState _state;

  @override
  void initState() {
    super.initState();
    setLoading(0);
    statisticsService = context.read<StatisticsService>();
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
        _RunsState() => ListView.builder(
            itemCount: state.runsByPlayers.length,
            itemBuilder: (context, index) => ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.sports_motorsports),
              ),
              title: Text(state.runsByPlayers[index].name),
              trailing: Text(state.runsByPlayers[index].runs.toString()),
              leadingAndTrailingTextStyle:
                  Theme.of(context).textTheme.titleLarge,
              subtitle: Text("${state.runsByPlayers[index].numBalls} balls, "
                  "${state.runsByPlayers[index].numWickets} outs, "
                  "SR ${state.runsByPlayers[index].strikeRate.toStringAsFixed(2)}"),
            ),
          ),
        _WicketsState() => ListView.builder(
            itemCount: state.wicketsByPlayers.length,
            itemBuilder: (context, index) => ListTile(
              leading: const CircleAvatar(
                backgroundColor: BallColors.newOver,
                child: Icon(Icons.sports_baseball),
              ),
              title: Text(state.wicketsByPlayers[index].name),
              trailing:
                  Text(state.wicketsByPlayers[index].numWickets.toString()),
              leadingAndTrailingTextStyle:
                  Theme.of(context).textTheme.titleLarge,
              subtitle: Text("${state.wicketsByPlayers[index].numBalls} balls, "
                  "${state.wicketsByPlayers[index].runs} runs, "
                  "${state.wicketsByPlayers[index].numNoBalls}nb, "
                  "${state.wicketsByPlayers[index].numNoBalls}wd"),
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
    final runList = await statisticsService.getAllBattingStats();
    setState(() {
      _state = _RunsState(0, runList);
    });
  }

  void showWicketsTakenByAllPlayers() async {
    setLoading(1);
    final wicketList = await statisticsService.getAllBowlingStats();
    setState(() {
      _state = _WicketsState(1, wicketList);
    });
  }

  void setLoading(int index) {
    _index = index;
    setState(() {
      _state = _LoadingState(_index);
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

class _RunsState extends _StatisticsState {
  final List<PlayerBattingStatistics> runsByPlayers;
  _RunsState(super.index, this.runsByPlayers);
}

class _WicketsState extends _StatisticsState {
  final List<PlayerBowlingStatistics> wicketsByPlayers;
  _WicketsState(super.index, this.wicketsByPlayers);
}
