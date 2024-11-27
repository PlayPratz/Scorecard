import 'package:flutter/material.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/modules/player/services/player_service.dart';
import 'package:scorecard/repositories/provider/repository_provider.dart';
import 'package:scorecard/screens/player/player_form_screen.dart';

class AllPlayersScreen extends StatefulWidget {
  const AllPlayersScreen({super.key});

  @override
  State<AllPlayersScreen> createState() => _AllPlayersScreenState();
}

class _AllPlayersScreenState extends State<AllPlayersScreen> {
  // late final Future<Iterable<Player>> _future;

  late AllPlayersState _state;

  @override
  void initState() {
    super.initState();

    _loadAllPlayers();
    // _future = RepositoryProvider().getPlayerRepository().readAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Players"),
      ),
      body: switch (_state) {
        AllPlayersLoadingState() => const Center(
            child: CircularProgressIndicator(),
          ),
        AllPlayersLoadedState() => _PlayerListBuilder(
            (_state as AllPlayersLoadedState).players,
            onSelectPlayer: (player) =>
                _goCreatePlayerScreen(context, player: player)),
      },
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _goCreatePlayerScreen(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomAppBar(),
    );
  }

  Future<void> _loadAllPlayers() async {
    setState(() {
      _state = AllPlayersLoadingState();
    });

    final players = await RepositoryProvider().getPlayerRepository().fetchAll();

    setState(() {
      _state = AllPlayersLoadedState(players.toList());
    });
  }

  void _goCreatePlayerScreen(BuildContext context, {Player? player}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PlayerFormScreen(
                  player: player,
                  onSavePlayer: (n, fn, {id}) => _onSavePlayer(n, fn, id: id),
                )));
  }

  Future<void> _onSavePlayer(String name, String? fullName,
      {String? id}) async {
    Navigator.pop(context);
    setState(() {
      _state = AllPlayersLoadingState();
    });
    await PlayerService().savePlayer(name, fullName: fullName, id: id);
    await _loadAllPlayers();
  }
}

sealed class AllPlayersState {}

class AllPlayersLoadingState extends AllPlayersState {}

class AllPlayersLoadedState extends AllPlayersState {
  final List<Player> players;

  AllPlayersLoadedState(this.players);
}

class PickPlayerScreen extends StatelessWidget {
  final List<Player> players;

  final void Function(Player player)? onSelectPlayer;
  const PickPlayerScreen(this.players, {super.key, this.onSelectPlayer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _PlayerListBuilder(players, onSelectPlayer: onSelectPlayer),
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
      subtitle: Text(player.fullName ?? ""),
      trailing: isSelectable ? const Icon(Icons.chevron_right) : null,
      onTap: onSelect != null ? () => onSelect!(player) : null,
    );
  }
}
