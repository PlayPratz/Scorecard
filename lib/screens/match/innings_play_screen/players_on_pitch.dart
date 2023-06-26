import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/screens/match/innings_play_screen/player_pick.dart';
import 'package:scorecard/screens/match/innings_play_screen/player_score_tile.dart';
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
          _wBatterOnPitch(context, inningsManager, inningsManager.batter1!),
          if (inningsManager.batter2 != null &&
              inningsManager.batter2!.batter != inningsManager.batter1!.batter)
            _wBatterOnPitch(context, inningsManager, inningsManager.batter2!),
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
                      inningsManager.setBowler(player, isMidOverChange: true);
                    }
                  }
                },
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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

  Padding _wBatterOnPitch(BuildContext context, InningsManager inningsManager,
      BatterInnings batterInnings) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () => inningsManager.setStrike(batterInnings),
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onLongPress: () => chooseBatter(
            context, inningsManager..batterToReplace = batterInnings),
        child: PlayerScoreTile(
          player: batterInnings.batter,
          score: batterInnings.score,
          teamColor: inningsManager.innings.battingTeam.color,
          isOnline: batterInnings == inningsManager.striker,
          isOut: batterInnings.isOut,
        ),
      ),
    );
  }
}
