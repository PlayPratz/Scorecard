import 'package:flutter/material.dart';
import 'package:scorecard/modules/player/player_model.dart';

class PlayerListScreen extends StatelessWidget {
  const PlayerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

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
