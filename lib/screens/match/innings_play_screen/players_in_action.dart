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
  final bool showChaseRequirement;
  const PlayersInActionPane(
      {super.key,
      required this.isHomeTeamBatting,
      this.showChaseRequirement = false});

  @override
  Widget build(BuildContext context) {
    final inningsManager =
        context.watch<InningsManager>(); // TODO make more efficient

    List<Widget> playersInActionRow = [
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _wBatterOnPitch(context, inningsManager.batter1!),
            if (inningsManager.batter2 != null &&
                inningsManager.batter2!.batter !=
                    inningsManager.batter1!.batter)
              _wBatterOnPitch(context, inningsManager.batter2!),
          ],
        ),
      ),
      Expanded(
        child: Column(
          children: [
            if (showChaseRequirement)
              Row(
                children: [
                  Expanded(
                    child: _wRunRateBox(
                        context: context,
                        color: inningsManager.innings.battingTeam.color,
                        heading: Strings.scoreRequire,
                        value: inningsManager.innings.requiredRuns.toString()),
                  ),
                  Expanded(
                      child: _wRunRateBox(
                          context: context,
                          color: inningsManager.innings.bowlingTeam.color,
                          heading: Strings.scoreBalls,
                          value: inningsManager.innings.ballsLeft.toString())),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _wRunRateBox(
                        context: context,
                        color: inningsManager.innings.battingTeam.color,
                        heading: Strings.scoreCRR,
                        value: inningsManager.innings.currentRunRate
                            .toStringAsFixed(2)),
                  ),
                  Expanded(
                      child: _wRunRateBox(
                          context: context,
                          color: inningsManager.innings.battingTeam.color,
                          heading: Strings.scoreProjected,
                          value:
                              inningsManager.innings.projectedRuns.toString())),
                ],
              ),
            _wBowlerOnPitch(context),
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
              children: isHomeTeamBatting
                  ? playersInActionRow
                  : playersInActionRow.reversed.toList(),
            ),
          ],
        ),
      ),
    );
  }

  Card _wRunRateBox({
    required BuildContext context,
    required Color color,
    required String heading,
    required String value,
  }) =>
      Card(
        elevation: 2,
        color: color.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              FittedBox(
                child: Text(
                  heading.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge,
              )
            ],
          ),
        ),
      );

  Widget _wBatterOnPitch(BuildContext context, BatterInnings batterInnings) {
    final inningsManager = context.read<InningsManager>();
    return PlayerScoreTile(
      player: batterInnings.batter,
      score: Strings.getBatterInningsScore(batterInnings),
      teamColor: inningsManager.innings.battingTeam.color,
      isOnline: batterInnings == inningsManager.striker,
      isOut: batterInnings.isOut,
      onTap: () => inningsManager.setStrike(batterInnings),
      onLongPress: () => chooseBatter(context, batterInnings),
    );
  }

  Widget _wBowlerOnPitch(BuildContext context) {
    final inningsManager = context.read<InningsManager>();
    return PlayerScoreTile(
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
            maxLines: 1,
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
