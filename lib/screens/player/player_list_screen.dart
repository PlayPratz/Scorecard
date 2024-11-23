import 'package:flutter/material.dart';
import 'package:scorecard/modules/player/player_model.dart';

class PlayerListScreen extends StatelessWidget {
  final List<Player> players;

  final void Function(Player player)? onSelectPlayer;
  const PlayerListScreen(this.players, {super.key, this.onSelectPlayer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemCount: players.length,
        itemBuilder: (context, index) => PlayerTile(players[index]),
      ),
      bottomNavigationBar: const BottomAppBar(),
      floatingActionButton: FloatingActionButton(onPressed: () {}),
    );
  }
}

// class PlayerListController {
//   final List<Player> players;
//
//   PlayerListController(this.players);
//
// }

class PlayerTile extends StatelessWidget {
  final Player player;
  final void Function()? onSelect;
  const PlayerTile(this.player, {super.key, this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isSelectable = onSelect != null;
    return ListTile(
      leading: const Icon(Icons.sports_motorsports),
      title: Text(player.name),
      trailing: isSelectable ? const Icon(Icons.chevron_right) : null,
      onTap: onSelect,
    );
  }
}
