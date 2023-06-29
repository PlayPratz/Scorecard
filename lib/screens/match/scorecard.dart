import 'package:flutter/material.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/statistics.dart';
import 'package:scorecard/screens/match/innings_play_screen/recent_balls.dart';
import 'package:scorecard/screens/match/match_tile.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/utils.dart';
import '../../models/cricket_match.dart';
import '../../models/innings.dart';
import '../templates/titled_page.dart';

class Scorecard extends StatelessWidget {
  final CricketMatch match;
  const Scorecard({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = match.homeTeam.shortName +
        Strings.separatorVersus +
        match.awayTeam.shortName;

    return TitledPage(
      title: title,
      child: SingleChildScrollView(
        child: _ScorecardMatchPanel(match: match),
      ),
    );
  }
}

class _ScorecardMatchPanel extends StatelessWidget {
  final CricketMatch match;
  const _ScorecardMatchPanel({required this.match});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MatchTile(match: match, showSummaryLine: true),
        ...match.inningsList
            .map((innings) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Card(
                    elevation: 2,
                    surfaceTintColor: innings.battingTeam.color,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const SizedBox(width: 8),
                              TeamChip(team: innings.battingTeam),
                              const Spacer(),
                              ElevatedButton.icon(
                                onPressed: () => Utils.goToPage(
                                    InningsTimelineScreen(innings: innings),
                                    context),
                                icon: const Icon(Icons.timeline),
                                label: const Text(Strings.goToTimeline),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _wBattingPanel(context, innings),
                          const SizedBox(height: 16),
                          _wBowlingPanel(context, innings),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ))
            .toList()
      ],
    );
  }
}

Widget _wBowlingPanel(BuildContext context, Innings innings) {
  return _innerPanel(
      context,
      Strings.scorecardBowling,
      innings.bowlingTeam.color,
      innings.bowlerInnings
          .map((bowlInn) => BowlerInningsScore(bowlerInnings: bowlInn))
          .toList());
}

Widget _wBattingPanel(BuildContext context, Innings innings) {
  return _innerPanel(
    context,
    Strings.scorecardBatting,
    innings.battingTeam.color,
    innings.batterInnings
        .map((batInn) => BatterInningsScore(battingStats: batInn))
        .toList(),
  );
}

Widget _innerPanel(BuildContext context, String heading, Color color,
    List<Widget> playerTiles) {
  return Card(
    surfaceTintColor: color,
    color: color.withOpacity(0.3),
    elevation: 4,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            heading.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 16),
        ...playerTiles.map((tile) => Column(
              children: [const Divider(color: Colors.black12), tile],
            )),
      ],
    ),
  );
}

class BowlerInningsScore extends StatelessWidget {
  final BowlingStats bowlerInnings;
  const BowlerInningsScore({super.key, required this.bowlerInnings});

  @override
  Widget build(BuildContext context) {
    final average = bowlerInnings.average;

    return GenericInningsScore(
        player: bowlerInnings.bowler,
        secondary:
            "${Strings.getBowlerOversBowled(bowlerInnings)} Overs at ${bowlerInnings.economy.toStringAsFixed(2)} RPO",
        highlights: const SizedBox(),
        score: Column(
          children: [
            Text(
                "${bowlerInnings.wicketsTaken.toString()}/${bowlerInnings.runsConceded.toString()}"),
            Text(
              average == double.infinity
                  ? ""
                  : "@${average.toStringAsFixed(2)}",
            )
          ],
        ));
  }
}

class BatterInningsScore extends StatelessWidget {
  final BattingStats battingStats;
  const BatterInningsScore({super.key, required this.battingStats});

  @override
  Widget build(BuildContext context) {
    return GenericInningsScore(
        player: battingStats.batter,
        score: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              battingStats.runs.toString(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(width: 4),
            Text(
              battingStats.ballsFaced.toString(),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.merge(const TextStyle(color: Colors.white70)),
            ),
          ],
        ),
        secondary: Strings.getWicketDescription(battingStats.wicket),
        highlights: Row(
          children: [
            CircleAvatar(
                backgroundColor: ColorStyles.ballFour.withOpacity(0.7),
                foregroundColor: Colors.white,
                radius: 16,
                child: Text(battingStats.fours.toString())),
            const SizedBox(width: 8),
            CircleAvatar(
                backgroundColor: ColorStyles.ballSix.withOpacity(0.7),
                radius: 16,
                foregroundColor: Colors.white,
                child: Text(battingStats.sixes.toString())),
          ],
        ));
  }
}

class GenericInningsScore extends StatelessWidget {
  final Player player;
  final String secondary;
  final Widget highlights;
  final Widget score;

  const GenericInningsScore({
    super.key,
    required this.player,
    required this.secondary,
    required this.highlights,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Elements.getPlayerIcon(player, 36),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  secondary,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.merge(const TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          highlights,
          const SizedBox(width: 8),
          SizedBox(width: 48, child: score)
        ],
      ),
    );
  }
}
