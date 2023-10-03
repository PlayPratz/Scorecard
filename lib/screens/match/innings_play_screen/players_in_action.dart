import 'package:flutter/material.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/screens/match/innings_play_screen/player_pickers.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/strings.dart';

class PlayersInActionPane extends StatelessWidget {
  final Innings innings;
  final bool isHomeTeamBatting;

  final Function(BatterInnings batter) onTapBatter;
  final Function(BatterInnings batter) onLongTapBatter;
  final Function(BowlerInnings bowler) onTapBowler;

  const PlayersInActionPane({
    super.key,
    required this.innings,
    required this.isHomeTeamBatting,
    required this.onTapBatter,
    required this.onLongTapBatter,
    required this.onTapBowler,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> playersInActionRow = [
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _wBatterInAction(
              context,
              innings.playersInAction.batter1!,
            ),
            if (innings.playersInAction.batter2 != null)
              _wBatterInAction(context, innings.playersInAction.batter2!),
          ],
        ),
      ),
      Expanded(
        child: _wBowlerInAction(context),
      ),
    ];
    return Card(
      surfaceTintColor: innings.battingTeam.color,
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

  Widget _wBatterInAction(
    BuildContext context,
    BatterInnings batterInnings,
  ) {
    return PlayerScoreTile(
      player: batterInnings.batter,
      score: Strings.getBatterInningsScore(batterInnings),
      teamColor: innings.battingTeam.color,
      isOnline: batterInnings == innings.playersInAction.striker,
      isOut: batterInnings.isOut,
      onTap: () => onTapBatter(batterInnings),
      onLongPress: () => onLongTapBatter(batterInnings), //TODO
    );
  }

  Widget _wBowlerInAction(BuildContext context) {
    final bowlerInnings = innings.playersInAction.bowler!;
    return PlayerScoreTile(
      player: bowlerInnings.bowler,
      teamColor: innings.bowlingTeam.color,
      score: Strings.getBowlerInningsScore(bowlerInnings),
      onLongPress: () => onTapBowler(bowlerInnings),
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
            style: Theme.of(context).textTheme.labelLarge,
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
