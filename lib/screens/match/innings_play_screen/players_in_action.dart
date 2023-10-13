import 'package:flutter/material.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/strings.dart';

class PlayersInActionPane extends StatelessWidget {
  final Innings innings;
  final bool isHomeTeamBatting;

  final void Function(BatterInnings batter) onTapBatter;
  final void Function(BatterInnings batter) onLongTapBatter;
  final void Function(BowlerInnings bowler) onTapBowler;

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
              innings.playersInAction.batter1,
            ),
            if (innings.playersInAction.batter2 != null)
              _wBatterInAction(context, innings.playersInAction.batter2!),
          ],
        ),
      ),
      // Expanded(
      //   child: Column(
      //     children: [
      //       _wBowlerInAction(context),
      //       GenericItemTile(
      //         primaryHint: "This Over",
      //         secondaryHint: "This Over",
      //         trailing: null,
      //       ),
      //     ],
      //   ),
      // ),
      Expanded(child: _wBowlerInAction(context))
    ];
    return Card(
      surfaceTintColor: innings.battingTeam.team.color,
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
    // TODO get this from event instead of this duplicate logic
    final isOut = batterInnings.isOut ||
        (innings.balls.isNotEmpty &&
            innings.balls.last.isWicket &&
            innings.balls.last.wicket!.batter == batterInnings.batter);
    return PlayerScoreTile(
      player: batterInnings.batter,
      score: Column(
        //TODO Remove duplicate code from Scorecard.dart
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            batterInnings.runs.toString(),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            batterInnings.ballsFaced.toString(),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.merge(const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
      description: Text(
        "SR ${batterInnings.strikeRate.toStringAsFixed(0)}",
        style: Theme.of(context).textTheme.bodySmall,
      ), //TODO move
      teamColor: innings.battingTeam.team.color,
      isOnline: batterInnings == innings.playersInAction.striker,
      isOut: isOut,
      onTap: () => onTapBatter(batterInnings),
      onLongPress: () => onLongTapBatter(batterInnings),
    );
  }

  Widget _wBowlerInAction(BuildContext context) {
    final bowlerInnings = innings.playersInAction.bowler;
    return PlayerScoreTile(
      player: bowlerInnings.bowler,
      score: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            Strings.getBowlerFigures(bowlerInnings),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            Strings.getBowlerOversBowled(bowlerInnings),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ), //TODO Move
      description: Text(
        "ECON ${bowlerInnings.economy.toStringAsFixed(1)}", //TODO move
        style: Theme.of(context).textTheme.bodySmall,
      ),
      teamColor: innings.bowlingTeam.team.color,
      onLongPress: () => onTapBowler(bowlerInnings),
    );
  }
}

class PlayerScoreTile extends StatelessWidget {
  final Player? player;
  final Widget? score;
  final Widget? description;
  final bool isOnline;
  final Color teamColor;
  final bool isOut;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PlayerScoreTile({
    Key? key,
    required this.player,
    required this.score,
    required this.description,
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
    this.description,
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
          leading:
              Elements.getPlayerIcon(player!, 32, null), //TODO player photo
          horizontalTitleGap: 8,
          // visualDensity: const VisualDensity(vertical: -2),
          title: Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                player!.name.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge,
                maxLines: 1,
              ),
            ),
          ),
          subtitle: description,
          trailing: score,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}
