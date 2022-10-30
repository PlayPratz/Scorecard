import 'package:flutter/material.dart';
import 'package:scorecard/styles/colorstyles.dart';
import '../../models/player.dart';
import '../widgets/genericitem.dart';
import '../../util/elements.dart';

class PlayerScoreTile extends StatelessWidget {
  final Player player;
  final String score;
  final bool isOnline;
  const PlayerScoreTile(
      {Key? key,
      required this.player,
      required this.score,
      this.isOnline = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: isOnline ? ColorStyles.online : Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: GenericItem(
        leading: Elements.getPlayerIcon(player, 24),
        primaryHint: player.name,
        secondaryHint: score,
        trailing: null,
      ),
    );
  }
}
