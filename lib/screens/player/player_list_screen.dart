import 'package:flutter/material.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/modules/repository/service/repository_service.dart';
import 'package:scorecard/screens/common/loading_future_builder.dart';
import 'package:scorecard/screens/player/create_player_screen.dart';

class AllPlayersScreen extends StatefulWidget {
  const AllPlayersScreen({super.key});

  @override
  State<AllPlayersScreen> createState() => _AllPlayersScreenState();
}

class _AllPlayersScreenState extends State<AllPlayersScreen> {
  late final Future<Iterable<Player>> _future;

  @override
  void initState() {
    super.initState();

    _future = RepositoryService().getPlayerRepository().readAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: LoadingFutureBuilder(
        future: _future,
        builder: (context, data) => _PlayerListBuilder(data.toList()),
      ),
      bottomNavigationBar: const BottomAppBar(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _goCreatePlayerScreen(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _goCreatePlayerScreen(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const CreatePlayerScreen()));
  }
}

class PickPlayerScreen extends StatelessWidget {
  final List<Player> players;

  final void Function(Player player)? onSelectPlayer;
  const PickPlayerScreen(this.players, {super.key, this.onSelectPlayer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _PlayerListBuilder(players),
    );
  }
}

class _PlayerListBuilder extends StatelessWidget {
  final List<Player> players;

  final void Function(Player player)? onSelectPlayer;

  const _PlayerListBuilder(this.players, {super.key, this.onSelectPlayer});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) =>
          _PlayerTile(players[index], onSelect: onSelectPlayer),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  final Player player;
  final void Function(Player player)? onSelect;
  const _PlayerTile(this.player, {super.key, this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isSelectable = onSelect != null;
    return ListTile(
      leading: const Icon(Icons.sports_motorsports),
      title: Text(player.name),
      trailing: isSelectable ? const Icon(Icons.chevron_right) : null,
      onTap: onSelect != null ? () => onSelect!(player) : null,
    );
  }
}
