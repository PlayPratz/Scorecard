import 'package:flutter/material.dart';

import '../../models/player.dart';
import '../../styles/strings.dart';
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Elements.getPlayerIcon(player, 48),
      title: Text(player.name),
      subtitle: getBatBowlStyle(context),
      trailing: trailing,
      onTap: () {
        if (onSelect != null) {
          onSelect!(player);
        }
      },
    );
  }

  Widget getBatBowlStyle(BuildContext context) {
    String batStyle = Strings.getArm(player.batArm) + Strings.playerBatter;
    String bowlStyle = '/' +
        Strings.getArm(player.bowlArm) +
        Strings.getBowlStyle(player.bowlStyle);
    return Text(batStyle + bowlStyle,
        style: Theme.of(context).textTheme.caption);
  }
}
