import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/screens/player/create_player.dart';
import 'package:scorecard/screens/player/player_tile.dart';
import 'package:scorecard/screens/templates/titled_page.dart';
import 'package:scorecard/screens/widgets/item_list.dart';
import 'package:scorecard/services/data/player_service.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/utils.dart';

class PlayerList extends StatelessWidget {
  final List<Player> playerList;
  final Function(Player player)? onSelectPlayer;
  final Function(Player? player)? onCreatePlayer;
  final Icon? trailingIcon;

  const PlayerList({
    Key? key,
    required this.playerList,
    this.onSelectPlayer,
    this.trailingIcon,
    this.onCreatePlayer,
  }) : super(key: key);

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

class AllPlayersList extends StatelessWidget {
  const AllPlayersList({super.key});

  @override
  Widget build(BuildContext context) {
    final playersFuture = context.read<PlayerService>().getAllPlayers();
    return FutureBuilder(
        future: playersFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            // TODO Handle loading and errors properly
            return const Center(child: CircularProgressIndicator());
          }
          final players = snapshot.data!;
          return PlayerList(
            playerList: players,
            onCreatePlayer: (player) {
              if (player != null) {
                context.read<PlayerService>().save(player);
              }
            },
            onSelectPlayer: (player) {
              Utils.goToPage(CreatePlayerForm.update(player: player), context);
            },
          );
        });
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
    context,
  );
  return player;
}

// TODO Migrate to SelectableItemList?
class SelectablePlayerList extends StatelessWidget {
  final List<Player> players;
  final SelectableItemController<Player> controller;

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
          final isSelected = controller.selectedItems.contains(player);
          return ListTile(
            selected: isSelected,
            selectedTileColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
            title: Text(player.name),
            leading: Elements.getPlayerIcon(
                player, 48, null), //TODO Handle profile pic
            trailing:
                isSelected ? const Icon(Icons.check_circle) : const SizedBox(),
            onTap: () => controller.selectItem(player),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          );
        }).toList(),
        alignToBottom: false,
      ),
    );
  }
}
