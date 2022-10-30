import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../widgets/genericitem.dart';
import '../../util/elements.dart';

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
