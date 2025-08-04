import 'package:scorecard/handlers/ulid.dart';
import 'package:scorecard/modules/player/player_model.dart';

class PlayerRepository {
  final _repo = <String, Player>{};

  Future<List<Player>> loadAll() async =>
      _repo.values.toList()..sort((a, b) => a.name.compareTo(b.name));

  Future<Player> create({required String name}) async {
    final player = Player(UlidHandler.generate(), name: name);
    save(player);
    return player;
  }

  Future<Player> save(Player player) async {
    _repo[player.id] = player;

    return _repo[player.id]!;
  }

  Future<Player?> load(String id) async {
    final player = _repo[id];
    return player;
  }

  Future<Map<String, Player?>> loadMultiple(Set<String> ids) async {
    final players = {for (final id in ids) id: _repo[id]};
    return players;
  }
}
