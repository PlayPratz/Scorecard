import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/screens/match/innings_play_screen/player_pickers.dart';
import 'package:scorecard/screens/player/player_list.dart';
import 'package:scorecard/state_managers/innings_manager.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/strings.dart';

class PlayersInActionPane extends StatelessWidget {
  final bool isHomeTeamBatting;

  final bool showChaseReq;
  const PlayersInActionPane(
      {super.key, required this.isHomeTeamBatting, this.showChaseReq = false});

  @override
  Widget build(BuildContext context) {
    final inningsManager =
        context.watch<InningsManager>(); // TODO make more efficient

    List<Widget> playersInActionRow = [
      Expanded(
        child: Column(children: [
          _wBatterOnPitch(context, inningsManager, inningsManager.batter1!),
          if (inningsManager.batter2 != null &&
              inningsManager.batter2!.batter != inningsManager.batter1!.batter)
            _wBatterOnPitch(context, inningsManager, inningsManager.batter2!),
        ]),
      ),
      Expanded(
        child: Column(
          children: [
            PlayerScoreTile(
              player: inningsManager.bowler!.bowler,
              teamColor: inningsManager.innings.bowlingTeam.color,
              score: Strings.getBowlerInningsScore(inningsManager.bowler!),
              onLongPress: () async {
                if (inningsManager.canChangeBowler) {
                  final player = await getPlayerFromList(
                      inningsManager.innings.bowlingTeam.squad, context);
                  if (player != null) {
                    inningsManager.setBowler(player, isMidOverChange: true);
                  }
                }
              },
            ),
            if (showChaseReq)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: _wChaseRequire(
                          context: context,
                          color: inningsManager.innings.battingTeam.color,
                          heading: "Require",
                          value: inningsManager.innings.requiredRuns)),
                  Expanded(
                      child: _wChaseRequire(
                          context: context,
                          color: inningsManager.innings.bowlingTeam.color,
                          heading: "Balls",
                          value: inningsManager.innings.ballsLeft)),
                ],
              )
          ],
        ),
      ),
    ];
    return Card(
      surfaceTintColor: inningsManager.innings.battingTeam.color,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Players in Action".toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: isHomeTeamBatting
                  ? playersInActionRow
                  : playersInActionRow.reversed.toList(),
            ),
          ],
        ),
      ),
    );
  }

  Card _wChaseRequire(
          {required Color color,
          required String heading,
          required int value,
          required BuildContext context}) =>
      Card(
        elevation: 4,
        color: color.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(heading.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(
                value.toString(),
                style: Theme.of(context).textTheme.titleLarge,
              )
            ],
          ),
        ),
      );

  Widget _wBatterOnPitch(BuildContext context, InningsManager inningsManager,
      BatterInnings batterInnings) {
    return PlayerScoreTile(
      player: batterInnings.batter,
      score: Strings.getBatterInningsScore(batterInnings),
      teamColor: inningsManager.innings.battingTeam.color,
      isOnline: batterInnings == inningsManager.striker,
      isOut: batterInnings.isOut,
      onTap: () => inningsManager.setStrike(batterInnings),
      onLongPress: () => chooseBatter(
          context, inningsManager..batterToReplace = batterInnings),
    );
  }
}

class PlayerScoreTile extends StatelessWidget {
  final Player? player;
  final String score;
  final bool isOnline;
  final Color teamColor;
  final bool isOut;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PlayerScoreTile({
    Key? key,
    required this.player,
    required this.score,
    required this.teamColor,
    this.isOut = false,
    this.isOnline = false,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  const PlayerScoreTile.wicket({
    super.key,
    required this.player,
    required this.score,
    this.onTap,
    this.onLongPress,
  })  : isOut = true,
        teamColor = Colors.transparent,
        isOnline = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: teamColor,
      color: isOut
          ? ColorStyles.wicket.withOpacity(0.3)
          : teamColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isOnline ? ColorStyles.online : Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Visibility(
        visible: player != null,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: onTap,
          onLongPress: onLongPress,
          leading: Elements.getPlayerIcon(player!, 32),
          horizontalTitleGap: 8,
          visualDensity: const VisualDensity(vertical: -2),
          title: Text(
            player!.name.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          subtitle: Text(
            score,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    );
  }
}
