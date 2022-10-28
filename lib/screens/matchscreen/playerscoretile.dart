import 'package:flutter/material.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/screens/widgets/genericitem.dart';
import 'package:scorecard/util/elements.dart';

class PlayerScoreTile extends StatelessWidget {
  final Player player;
  final String score;
  final bool isOnStrike;
  const PlayerScoreTile(
      {Key? key,
      required this.player,
      required this.score,
      this.isOnStrike = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GenericItem(
      leading: player.imagePath != null
          ? CircleAvatar(
              foregroundImage: AssetImage(player.imagePath!),
              radius: 24,
            )
          : const Icon(Icons.person_outline),
      primaryHint: player.name,
      secondaryHint: score,
      trailing: Elements.getOnlineIndicator(isOnStrike),
    );
  }
}
