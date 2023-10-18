import 'package:flutter/material.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';

import 'package:scorecard/models/player.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/screens/widgets/elements.dart';

class PlayerTile extends StatelessWidget {
  final Player player;
  final void Function(Player player)? onSelect;
  final void Function(Player player)? onLongPress;
  final String? detail;
  final Widget? trailing;

  const PlayerTile(
    this.player, {
    Key? key,
    this.onSelect,
    this.onLongPress,
    this.detail,
    this.trailing = Elements.forwardIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GenericItemTile(
      leading: Elements.getPlayerIcon(context, player, 42),
      primaryHint: player.name,
      secondaryHint: getBatBowlStyle(context),
      trailing: trailing,
      onSelect: () {
        if (onSelect != null) {
          onSelect!(player);
        }
      },
      onLongPress: onLongPress != null ? () => onLongPress!(player) : null,
    );
  }

  String getBatBowlStyle(BuildContext context) {
    String batStyle = Strings.getArm(player.batArm) + Strings.playerBatter;
    String bowlStyle = '/' +
        Strings.getArm(player.bowlArm) +
        Strings.getBowlStyle(player.bowlStyle);
    return batStyle + bowlStyle;
  }
}
