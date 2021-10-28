import 'package:flutter/material.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/styles/strings.dart';

class PlayerTile extends StatelessWidget {
  final Player player;

  const PlayerTile(this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: player.imagePath != null
            ? CircleAvatar(
                foregroundImage: AssetImage(player.imagePath!),
                radius: 24,
              )
            : const Icon(Icons.person_outline),
        title: Text(player.name),
        subtitle: getBatBowlStyle(context),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
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
