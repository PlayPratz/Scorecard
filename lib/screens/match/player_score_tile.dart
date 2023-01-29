import 'package:flutter/material.dart';
import 'package:scorecard/styles/color_styles.dart';
import '../../models/player.dart';
import '../widgets/generic_item_tile.dart';
import '../../util/elements.dart';

class PlayerScoreTile extends StatelessWidget {
  final Player? player;
  final String score;
  final bool isOnline;
  final Color teamColor;

  const PlayerScoreTile(
      {Key? key,
      required this.player,
      required this.score,
      required this.teamColor,
      this.isOnline = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: teamColor.withOpacity(0.6),
        border: Border.all(
          color: isOnline ? ColorStyles.online : Colors.transparent,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: player != null
          ? GenericItemTile(
              leading: Elements.getPlayerIcon(player!, 36),
              primaryHint: player!.name,
              secondaryHint: score,
              trailing: null,
            )
          : null,
    );
  }
}
