import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/screens/player/player_form_screen.dart';
import 'package:scorecard/services/player_service.dart';

typedef PlayerCallbackFn = void Function(Player player);

typedef CreatePlayerCallbackFn = void Function(
    {required String? id, required String name, required String? fullName});

class AllPlayersScreen extends StatelessWidget {
  const AllPlayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AllPlayersInner(
      title: "All Players",
      onPickPlayer: null,
    );
  }
}

class PickFromAllPlayersScreen extends StatelessWidget {
  final PlayerCallbackFn onPickPlayer;

  const PickFromAllPlayersScreen({super.key, required this.onPickPlayer});

  @override
  Widget build(BuildContext context) {
    return _AllPlayersInner(
      title: "Pick a Player",
      onPickPlayer: onPickPlayer,
    );
  }
}

class _AllPlayersInner extends StatefulWidget {
  final String title;
  final PlayerCallbackFn? onPickPlayer;

  const _AllPlayersInner({
    required this.title,
    required this.onPickPlayer,
  });

  @override
  State<_AllPlayersInner> createState() => _AllPlayersInnerState();
}

class _AllPlayersInnerState extends State<_AllPlayersInner> {
  late _PlayerListState _state;

  late PlayerService _playerService;

  @override
  void initState() {
    super.initState();
    _playerService = context.read<PlayerService>();
    _loadAllPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: switch (_state) {
        _LoadingState() => const Center(
            child: CircularProgressIndicator(),
          ),
        _LoadedState() => _PlayerListBuilder((_state as _LoadedState).players,
            onSelectPlayer: (p) => _onSelectPlayer(context, p)),
      },
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _goCreatePlayerScreen(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomAppBar(),
    );
  }

  void _onSelectPlayer(BuildContext context, Player player) {
    if (widget.onPickPlayer == null) {
      return _goCreatePlayerScreen(context, player: player);
    } else {
      return widget.onPickPlayer!(player);
    }
  }

  void _goCreatePlayerScreen(BuildContext context, {Player? player}) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PlayerFormScreen(
                player: player,
                onSavePlayer: (n, {id}) => _onSavePlayer(n, id: id),
              )),
    );
  }

  Future<void> _onSavePlayer(String name, {String? id}) async {
    setState(() {
      _state = _LoadingState();
    });
    if (id == null) {
      await _playerService.createPlayer(name);
    } else {
      await _playerService.savePlayer(Player(id, name: name));
    }

    await _loadAllPlayers();
  }

  Future<void> _loadAllPlayers() async {
    setState(() {
      _state = _LoadingState();
    });

    final players = (await _playerService.getAllPlayers());

    setState(() {
      _state = _LoadedState(players);
    });
  }
}

sealed class _PlayerListState {}

class _LoadingState extends _PlayerListState {}

class _LoadedState extends _PlayerListState {
  final List<Player> players;
  _LoadedState(this.players);
}

class PickPlayerScreen extends StatelessWidget {
  final List<Player> players;
  final void Function(Player player)? onPickPlayer;

  const PickPlayerScreen(
    this.players, {
    super.key,
    this.onPickPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick a Player")),
      body: _PlayerListBuilder(
        players,
        onSelectPlayer: onPickPlayer,
      ),
      bottomNavigationBar: const BottomAppBar(),
    );
  }
}

// class _PlayerListScreen extends StatelessWidget {
//   final List<Player> players;
//   final void Function(Player player)? onSelectPlayer;
//   final void Function(
//       {required String? id,
//       required String name,
//       required String? fullName})? onCreatePlayer;
//
//   final String title;
//
//   const _PlayerListScreen(
//     this.players, {
//     required this.onSelectPlayer,
//     required this.onCreatePlayer,
//     required this.title,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//       ),
//       body: _PlayerListBuilder(players, onSelectPlayer: onSelectPlayer),
//       bottomNavigationBar: const BottomAppBar(),
//       floatingActionButton: onCreatePlayer != null
//           ? FloatingActionButton(
//               onPressed: () => _goCreatePlayerScreen(context))
//           : null,
//     );
//   }
// }

class _PlayerListBuilder extends StatelessWidget {
  final List<Player> players;

  final void Function(Player player)? onSelectPlayer;

  const _PlayerListBuilder(this.players, {this.onSelectPlayer});

  @override
  Widget build(BuildContext context) {
    players.sort((a, b) => a.name.compareTo(b.name));
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) =>
          _PlayerTile(players[index], onSelect: onSelectPlayer),
    );
  }
}

/// A handy tile that displays a player's details at a glance
class _PlayerTile extends StatelessWidget {
  final Player player;
  final void Function(Player player)? onSelect;
  const _PlayerTile(this.player, {this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isSelectable = onSelect != null;
    return ListTile(
      leading: const Icon(Icons.sports_motorsports),
      title: Text(player.name),
      // subtitle: Text(player.fullName ?? ""),
      trailing: isSelectable ? const Icon(Icons.chevron_right) : null,
      onTap: onSelect != null ? () => onSelect!(player) : null,
    );
  }
}
