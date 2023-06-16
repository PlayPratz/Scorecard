import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/screens/match/player_score_tile.dart';
import 'package:scorecard/screens/player/player_list.dart';
import 'package:scorecard/state_managers/innings_manager.dart';

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
              onTap: () => inningsManager.setBatter(inningsManager.batter1!),
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: PlayerScoreTile(
                player: inningsManager.batter1!.batter,
                score: inningsManager.batter1!.score,
                teamColor: inningsManager.innings.battingTeam.color,
                isOnline: inningsManager.striker == inningsManager.batter1,
              ),
            ),
          ),
          if (inningsManager.batter2 != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: InkWell(
                // TODO
                onTap: () => inningsManager.setBatter(inningsManager.batter2!),
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: PlayerScoreTile(
                  player: inningsManager.batter2!.batter,
                  score: inningsManager.batter2!.score,
                  teamColor: inningsManager.innings.battingTeam.color,
                  isOnline: inningsManager.striker == inningsManager.batter2,
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
              child: InkWell(
                onLongPress: () async {
                  if (inningsManager.canChangeBowler) {
                    final player = await getPlayerFromList(
                        inningsManager.innings.bowlingTeam.squad, context);
                    if (player != null) {
                      inningsManager.setBowler(player);
                    }
                  }
                },
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: PlayerScoreTile(
                  player: inningsManager.bowler!.bowler,
                  teamColor: inningsManager.innings.bowlingTeam.color,
                  score: inningsManager.bowler!.score,
                ),
              ),
            ),
            const SizedBox(height: 8),
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
