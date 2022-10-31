import 'package:flutter/material.dart';
import 'package:scorecard/screens/widgets/genericitem.dart';

import '../../models/player.dart';
import '../../util/strings.dart';
import '../../util/elements.dart';

class PlayerTile extends StatelessWidget {
  final Player player;
  final Function(Player player)? onSelect;
  final String? detail;
  final Widget? trailing;

  const PlayerTile(this.player,
      {Key? key,
      this.onSelect,
      this.detail,
      this.trailing = Elements.forwardIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GenericItemTile(
      leading: Elements.getPlayerIcon(player, 48),
      primaryHint: player.name,
      secondaryHint: getBatBowlStyle(context),
      trailing: trailing,
      onSelect: () {
        if (onSelect != null) {
          onSelect!(player);
        }
      },
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
