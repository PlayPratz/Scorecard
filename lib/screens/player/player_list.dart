import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/screens/player/create_player.dart';
import 'package:scorecard/screens/player/player_tile.dart';
import 'package:scorecard/screens/widgets/common_builders.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';
import 'package:scorecard/screens/widgets/item_list.dart';
import 'package:scorecard/services/player_service.dart';
import 'package:scorecard/screens/widgets/elements.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/utils.dart';

class PlayerList extends StatelessWidget {
  final List<Player> playerList;

  final void Function(Player player)? onSelect;
  final void Function(Player player)? onLongPress;
  final void Function(Player? player)? onCreate;
  final Icon? trailingIcon;

  const PlayerList({
    super.key,
    required this.playerList,
    this.trailingIcon,
    this.onSelect,
    this.onLongPress,
    this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return ItemList<Player>(
      itemList: [
        for (Player player in playerList)
          PlayerTile(
            player,
            onSelect: onSelect,
            onLongPress: onLongPress,
            trailing: trailingIcon,
          )
      ],
      createItem: onCreate != null
          ? CreateItemEntry(
              form: const CreatePlayerForm.create(),
              string: Strings.addNewPlayer,
              onCreate: (item) => onCreate!(item),
            )
          : null,
      alignToBottom: false,
    );
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
            onLongPress: (player) async {
              showModalBottomSheet(
                  context: context,
                  builder: (context) => SizedBox(
                        height: 256,
                        child: Material(
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              GenericItemTile(
                                primaryHint: Strings.share,
                                secondaryHint: Strings.sharePlayerHint,
                                trailing: const Icon(
                                  Icons.ios_share,
                                  color: ColorStyles.online,
                                ),
                                onSelect: () async {
                                  context.read<PlayerService>().share([player]);
                                  Utils.goBack(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ));
            },
            trailingIcon: Elements.forwardIcon,
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

class SelectablePlayerList extends StatelessWidget {
  final UnmodifiableListView<Player> players;
  final SelectableItemController<Player> controller;

  final Widget Function(Player player)? buildTrailing;

  const SelectablePlayerList({
    super.key,
    required this.players,
    required this.controller,
    this.buildTrailing,
  });

  @override
  Widget build(BuildContext context) {
    return SelectableItemList(
      items: players,
      controller: controller,
      onBuild: (player) => ListTile(
        selected: false,
        title: Text(player.name),
        leading: Elements.getPlayerIcon(context, player, 48),
        onTap: () => controller.selectItem(player),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onBuildSelected: (player) => ListTile(
        selected: true,
        selectedTileColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
        title: Text(player.name),
        leading: Elements.getPlayerIcon(context, player, 48),
        trailing: buildTrailing != null
            ? buildTrailing!(player)
            : const Icon(Icons.check_circle),
        onTap: () => controller.selectItem(player),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
