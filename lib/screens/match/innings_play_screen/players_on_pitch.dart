import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/screens/match/player_score_tile.dart';
import 'package:scorecard/state_managers/innings_manager.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/util/strings.dart';

class PlayersOnPitchView extends StatelessWidget {
  final bool isHomeTeamBatting;
  const PlayersOnPitchView({super.key, required this.isHomeTeamBatting});

  @override
  Widget build(BuildContext context) {
    final inningsManager = context.watch<InningsManager>();

    List<Widget> nowPlayingWidgets = [
      Expanded(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: InkWell(
              // TODO
              // onTap: () => inningsManager.setBatter(inningsManager.batter!),
              child: PlayerScoreTile(
                player: inningsManager.batter!.batter,
                score: inningsManager.batter!.score,
                teamColor: inningsManager.innings.battingTeam.color,
                isOnline: true,
              ),
            ),
          ),
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
                player: inningsManager.bowler!.bowler,
                teamColor: inningsManager.innings.bowlingTeam.color,
                score: inningsManager.bowler!.score,
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
      children: isHomeTeamBatting
          ? nowPlayingWidgets
          : nowPlayingWidgets.reversed.toList(),
    );
  }
}
