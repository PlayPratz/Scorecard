import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';

import 'package:scorecard/models/player.dart';
import 'package:scorecard/services/data/player_service.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/elements.dart';

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
    final profileImage =
        context.read<PlayerService>().getProfilePhoto(player.id);
    return GenericItemTile(
      leading: Elements.getPlayerIcon(player, 42, null), //TODO
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
