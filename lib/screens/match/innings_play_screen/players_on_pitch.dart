import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/screens/match/player_score_tile.dart';
import 'package:scorecard/state_managers/ball_manager.dart';
import 'package:scorecard/state_managers/innings_manager.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/util/strings.dart';

class PlayersOnPitchView extends StatelessWidget {
  const PlayersOnPitchView({super.key});

  @override
  Widget build(BuildContext context) {
    final inningsManager = context.watch<InningsManager>();
    final onPitchBatters = inningsManager.onPitchBatters;

    List<Widget> nowPlayingWidgets = [
      Expanded(
        child: Column(children: [
          ...onPitchBatters.map((batterInnings) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: InkWell(
                  onTap: () => context
                      .read<BallManager>()
                      .setBatter(batterInnings.batter),
                  child: PlayerScoreTile(
                    player: batterInnings.batter,
                    score: batterInnings.score,
                    teamColor: inningsManager.innings.battingTeam.color,
                    isOnline: batterInnings == inningsManager.onStrikeBatter,
                  ),
                ),
              ))
        ]),
      ),
      const SizedBox(width: 4),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: PlayerScoreTile(
                player: inningsManager.bowler,
                teamColor: inningsManager.innings.bowlingTeam.color,
                score: "SCORE GOES HERE",
                // score: inningsManager.innings.currentBowlerInnings.score,
              ),
            ),
            const SizedBox(height: 8),

            // THIS IS End Innings Button
            SizedBox(
              height: 64,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: OutlinedButton.icon(
                  onPressed: null,
                  onLongPress: inningsManager.endInnings,
                  style: OutlinedButton.styleFrom(primary: ColorStyles.remove),
                  icon: const Icon(Icons.cancel),
                  label: const Text(Strings.matchScreenEndInnings),
                ),
              ),
            )
          ],
        ),
      ),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: inningsManager.isHomeTeamBatting
          ? nowPlayingWidgets
          : [...nowPlayingWidgets.reversed],
    );
  }
}
