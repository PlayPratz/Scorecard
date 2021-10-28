import 'package:flutter/material.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/screens/createplayer.dart';
import 'package:scorecard/screens/widgets/itemlist.dart';
import 'package:scorecard/screens/widgets/playertile.dart';
import 'package:scorecard/styles/strings.dart';

class PlayerList extends StatelessWidget {
  final List<Player> playerList;
  final bool showAddButton;
  final Function(Player player)? onSelectPlayer;
  final Icon? trailingIcon;

  const PlayerList({
    Key? key,
    required this.playerList,
    required this.showAddButton,
    this.onSelectPlayer,
    this.trailingIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (showAddButton) {
      return ItemList(
        itemList: getPlayerList(),
        createItemPage: CreatePlayerForm(),
        createItemString: Strings.addNewPlayer,
      );
    }

    return ItemList(
      itemList: getPlayerList(),
    );
  }

  List<Widget> getPlayerList() {
    List<PlayerTile> playerTiles = [];
    for (Player player in playerList) {
      playerTiles.add(PlayerTile(
        player,
        onSelect: onSelectPlayer,
        trailingIcon: trailingIcon,
      ));
    }
    return playerTiles;
  }
}
