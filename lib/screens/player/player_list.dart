import 'package:flutter/material.dart';
import 'package:scorecard/screens/templates/titled_page.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/utils.dart';

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

Future<Player?> getPlayerFromList(
    List<Player> playerList, BuildContext context) async {
  Player? player = await Utils.goToPage(
      TitledPage(
        title: Strings.choosePlayer,
        child: PlayerList(
          playerList: playerList,
          onSelectPlayer: (player) => Utils.goBack(context, player),
          onCreatePlayer: (player) => Utils.goBack(context, player),
        ),
      ),
      context);
  return player;
}

class SelectablePlayerList extends StatelessWidget {
  final List<Player> players;
  final SelectablePlayerController controller;

  const SelectablePlayerList(
      {super.key, required this.players, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) => ItemList(
        itemList: players
            //Not using PlayerTile because need "selected" param
            .map((player) {
          final isSelected = controller.selectedPlayers.contains(player);
          return ListTile(
            selected: isSelected,
            selectedTileColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
            title: Text(player.name),
            leading: Elements.getPlayerIcon(player, 48),
            trailing:
                isSelected ? const Icon(Icons.check_circle) : const SizedBox(),
            onTap: () => controller.selectPlayer(player),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          );
        }).toList(),
      ),
    );
  }
}

// TODO should move to new file?
class SelectablePlayerController with ChangeNotifier {
  final selectedPlayers = <Player>[];

  void selectPlayer(Player player) {
    if (selectedPlayers.contains(player)) {
      selectedPlayers.remove(player);
    } else {
      selectedPlayers.add(player);
    }
    notifyListeners();
  }
}
