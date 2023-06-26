import 'package:flutter/material.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/statistics.dart';
import 'package:scorecard/screens/match/scorecard.dart';
import 'package:scorecard/screens/widgets/item_list.dart';
import 'package:scorecard/services/storage_service.dart';
import 'package:scorecard/styles/color_styles.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _selectedStatistic = ValueNotifier(0);

    return ValueListenableBuilder<int>(
      valueListenable: _selectedStatistic,
      builder: (context, value, child) {
        return Column(
          children: [
            _wGetScreen(value),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                StatisticsChip(
                  primaryHint: "Batters",
                  secondaryHint:
                      "Statistics on batters like runs, strike rate and average.",
                  color: ColorStyles.ballFour,
                  leading: const Icon(Icons.sports_cricket),
                  onSelected: (_) => _selectedStatistic.value = 0,
                  selected: _selectedStatistic.value == 0,
                ),
                StatisticsChip(
                  primaryHint: "Bowlers",
                  secondaryHint:
                      "Statistics on batters like runs, strike rate and average.",
                  color: ColorStyles.wicket,
                  leading: const Icon(
                    Icons.sports_baseball,
                  ),
                  onSelected: (_) => _selectedStatistic.value = 1,
                  selected: _selectedStatistic.value == 1,
                ),
                // StatisticsChip(
                //   primaryHint: "Fielders",
                //   secondaryHint:
                //       "Statistics on batters like runs, strike rate and average.",
                //   color: Colors.greenAccent.withOpacity(0.7),
                //   leading: Icon(Icons.run_circle),
                //   onSelected: (_) => _selectedStatistic.value = 2,
                //   selected: _selectedStatistic.value == 2,
                // ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _wGetScreen(int index) {
    return Expanded(
      child: ItemList(itemList: () {
        if (index == 1) {
          return _bowlingStats();
        } else {
          return _battingStats();
        }
      }()),
    );
  }

  List<Widget> _battingStats() {
    return _batterData()
        .map(
          (battingStats) => Column(
            children: [
              GenericInningsScore(
                player: battingStats.batter,
                secondary:
                    "Strike Rate ${battingStats.strikeRate.toStringAsFixed(2)} | Average ${battingStats.average.toStringAsFixed(2)}",
                trailPrimary: battingStats.runsScored.toString(),
                trailSecondary: battingStats.numBallsFaced.toString(),
              ),
              const SizedBox(height: 2),
            ],
          ),
        )
        .toList();
  }

  List<Widget> _bowlingStats() {
    return _bowlerData()
        .map(
          (bowlingStats) => Column(
            children: [
              GenericInningsScore(
                player: bowlingStats.bowler,
                secondary:
                    "${bowlingStats.oversBowled} Overs at ${bowlingStats.economy.toStringAsFixed(2)} RPO",
                trailPrimary:
                    "${bowlingStats.wicketsTaken}/${bowlingStats.runsConceded.toString()}",
                trailSecondary: "@${bowlingStats.average.toStringAsFixed(2)}",
              ),
              const SizedBox(height: 2),
            ],
          ),
        )
        .toList();
  }

  List<BattingStatistics> _batterData() {
    final matchList = StorageService.getAllMatches();
    final Map<Player, BattingStatistics> battingStatisticsMap = {};
    for (final match in matchList) {
      for (final innings in match.inningsList) {
        for (final batInn in innings.batterInnings) {
          if (!battingStatisticsMap.containsKey(batInn.batter)) {
            battingStatisticsMap[batInn.batter] =
                BattingStatistics(batInn.batter);
          }
          battingStatisticsMap[batInn.batter]!.balls.addAll(batInn.balls);
        }
      }
    }
    final battingStatisticsList = battingStatisticsMap.values.toList();

    battingStatisticsList.sort((a, b) => b.runsScored - a.runsScored);

    return battingStatisticsList;
  }

  List<BowlingStatistics> _bowlerData() {
    final matchList = StorageService.getAllMatches();
    final Map<Player, BowlingStatistics> bowlingStatisticsMap = {};
    for (final match in matchList) {
      for (final innings in match.inningsList) {
        for (final bowlInn in innings.bowlerInnings) {
          if (!bowlingStatisticsMap.containsKey(bowlInn.bowler)) {
            bowlingStatisticsMap[bowlInn.bowler] =
                BowlingStatistics(bowlInn.bowler);
          }
          bowlingStatisticsMap[bowlInn.bowler]!.balls.addAll(bowlInn.balls);
        }
      }
    }
    final bowlingStatisticsList = bowlingStatisticsMap.values.toList();

    bowlingStatisticsList.sort((a, b) {
      if (a.wicketsTaken == b.wicketsTaken) {
        return a.runsConceded - b.runsConceded;
      }
      return b.wicketsTaken - a.wicketsTaken;
    });
    return bowlingStatisticsList;
  }
}

class StatisticsChip extends StatelessWidget {
  final Color color;
  final String primaryHint;
  final String secondaryHint;
  final Widget leading;
  final bool selected;
  final Function(bool value)? onSelected;

  const StatisticsChip(
      {super.key,
      required this.color,
      required this.primaryHint,
      required this.secondaryHint,
      required this.leading,
      this.selected = false,
      this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        selected: selected,
        onSelected: onSelected,
        selectedColor: color,
        labelPadding: EdgeInsets.all(0),
        label: Row(
          children: [
            leading,
            const SizedBox(width: 4),
            Text(primaryHint),
          ],
        ),
        // label: Text(primaryHint),
      ),

      // GenericItemTile(
      //   primaryHint: primaryHint,
      //   secondaryHint: secondaryHint,
      //   leading: leading,
      //   color: color,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(48),
      //   ),
      //   contentPadding: EdgeInsets.symmetric(vertical: 32, horizontal: 18),
      // ),
    );
  }
}