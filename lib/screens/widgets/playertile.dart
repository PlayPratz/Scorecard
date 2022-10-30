import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../styles/strings.dart';
import '../../util/elements.dart';

class PlayerTile extends StatelessWidget {
  final Player player;
  final Function(Player player)? onSelect;
  final Icon? trailingIcon;

  const PlayerTile(this.player,
      {Key? key, this.onSelect, this.trailingIcon = Elements.forwardIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: player.imagePath != null
          ? CircleAvatar(
              foregroundImage: AssetImage(player.imagePath!),
              radius: 24,
            )
          : const Icon(Icons.person_outline),
      title: Text(player.name),
      subtitle: getBatBowlStyle(context),
      trailing: trailingIcon,
      onTap: () {
        if (onSelect != null) {
          onSelect!(player);
        }
      },
    );
  }

  Widget getBatBowlStyle(BuildContext context) {
    String batStyle = Strings.getArm(player.batArm) + Strings.playerBatter;
    String bowlStyle = player.bowlStyle != null
        ? "/" +
            Strings.getArm(player.bowlArm!) +
            Strings.getBowlStyle(player.bowlStyle!)
        // Strings.playerBowler
        : "";
    return Text(batStyle + bowlStyle,
        style: Theme.of(context).textTheme.caption);
  }
}
