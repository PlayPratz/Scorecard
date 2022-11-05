import 'package:flutter/material.dart';

import '../../models/player.dart';
import '../../util/strings.dart';
import 'create_player.dart';
import '../widgets/item_list.dart';
import 'player_tile.dart';

class PlayerList extends StatelessWidget {
  final List<Player> playerList;
  final Function(Player player)? onSelectPlayer;
  final Function(Player? player)? onCreatePlayer;
  final Icon? trailingIcon;

  const PlayerList(
      {Key? key,
      required this.playerList,
      this.onSelectPlayer,
      this.trailingIcon,
      this.onCreatePlayer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ItemList(
        itemList: getPlayerList(),
        createItem: onCreatePlayer != null
            ? CreateItemEntry(
                page: const CreatePlayerForm(),
                string: Strings.addNewPlayer,
                onCreateItem: onCreatePlayer != null
                    ? (item) => onCreatePlayer!(item)
                    : null,
              )
            : null);
  }

  List<Widget> getPlayerList() {
    List<PlayerTile> playerTiles = [];
    for (Player player in playerList) {
      playerTiles.add(PlayerTile(
        player,
        onSelect: onSelectPlayer,
        trailing: trailingIcon,
      ));
    }
    return playerTiles;
  }
}
