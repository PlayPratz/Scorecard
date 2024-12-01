import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/modules/player/services/player_service.dart';
import 'package:scorecard/screens/player/player_form_screen.dart';

class AllPlayersScreen extends StatefulWidget {
  const AllPlayersScreen({super.key});

  @override
  State<AllPlayersScreen> createState() => _AllPlayersScreenState();
}

class _AllPlayersScreenState extends State<AllPlayersScreen> {
  late _PlayerListState _state;

  @override
  void initState() {
    super.initState();

    _loadAllPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Players"),
      ),
      body: switch (_state) {
        _LoadingState() => const Center(
            child: CircularProgressIndicator(),
          ),
        _LoadedState() => _PlayerListBuilder((_state as _LoadedState).players,
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
    setState(() {
      _state = _LoadingState();
    });
    await PlayerService().savePlayer(name, fullName: fullName, id: id);
    await _loadAllPlayers();
  }

  Future<void> _loadAllPlayers() async {
    setState(() {
      _state = _LoadingState();
    });

    final players = (await PlayerService().getAllPlayers()).toList();

    setState(() {
      _state = _LoadedState(players);
    });
  }
}

class PlayerListController {
  List<Player>? players;

  PlayerListController(this.players);

  final _streamController = StreamController<_PlayerListState>();
  Stream<_PlayerListState> get _stream => _streamController.stream;

  Future<void> _loadAllPlayers() async {
    if (players != null) {
      _streamController.add(_LoadedState(players!));
      return;
    }
    _streamController.add(_LoadingState());

    players = (await PlayerService().getAllPlayers()).toList();

    _streamController.add(_LoadedState(players!));
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
    _streamController.add(_LoadingState());
    players = null;
    await PlayerService().savePlayer(name, fullName: fullName, id: id);
    await _loadAllPlayers();
  }
}

sealed class _PlayerListState {}

class _LoadingState extends _PlayerListState {}

class _LoadedState extends _PlayerListState {
  final List<Player> players;

  _LoadedState(this.players);
}

class PickPlayerScreen extends StatelessWidget {
  final List<Player>? players;

  final void Function(Player player)? onSelectPlayer;
  const PickPlayerScreen({this.players, super.key, this.onSelectPlayer});

  @override
  Widget build(BuildContext context) {
    final controller = PlayerListController(players);
    controller._loadAllPlayers();
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder(
          stream: controller._stream,
          initialData: _LoadingState(),
          builder: (context, snapshot) {
            final state = snapshot.data;
            if (state is _LoadedState) {
              return _PlayerListBuilder(state.players,
                  onSelectPlayer: onSelectPlayer);
            }
            return const Center(child: CircularProgressIndicator());
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: players == null
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => controller._goCreatePlayerScreen(context))
          : null,
      bottomNavigationBar: const BottomAppBar(),
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
