import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/screens/player/create_player.dart';
import 'package:scorecard/screens/player/player_tile.dart';
import 'package:scorecard/screens/widgets/common_builders.dart';
import 'package:scorecard/screens/widgets/item_list.dart';
import 'package:scorecard/services/data/player_service.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/utils.dart';

class PlayerList extends StatelessWidget {
  final List<Player> playerList;

  final void Function(Player player)? onSelect;
  final void Function(Player? player)? onCreate;
  final Icon? trailingIcon;

  const PlayerList({
    Key? key,
    required this.playerList,
    this.trailingIcon,
    this.onSelect,
    this.onCreate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ItemList<Player>(
        itemList: [
          for (Player player in playerList)
            PlayerTile(
              player,
              onSelect: onSelect,
              trailing: trailingIcon,
            )
        ],
        createItem: onCreate != null
            ? CreateItemEntry(
                form: const CreatePlayerForm(),
                string: Strings.addNewPlayer,
                onCreate: (item) => onCreate!(item),
              )
            : null);
  }
}

class AllPlayersList extends StatelessWidget {
  const AllPlayersList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller =
        PlayerController(playerService: context.read<PlayerService>());

    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) => SimplifiedFutureBuilder(
        future: controller.players,
        builder: (context, players) {
          return PlayerList(
            playerList: players,
            onCreate: (player) {
              if (player != null) {
                controller.save(player);
              }
            },
            onSelect: (player) async {
              final updatedPlayer = await Utils.goToPage(
                CreatePlayerForm.update(player: player),
                context,
              );
              if (updatedPlayer != null) {
                controller.save(updatedPlayer);
              }
            },
          );
        },
      ),
    );
  }
}

class PlayerController with ChangeNotifier {
  final PlayerService playerService;

  PlayerController({required this.playerService});

  Future<List<Player>> get players => playerService.getAll();

  Future<void> save(Player player) async {
    await playerService.save(player);
    notifyListeners();
  }

// Future<void> delete(Player player) async {
//   await playerService.delete(player);
//   notifyListeners();
// }
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
