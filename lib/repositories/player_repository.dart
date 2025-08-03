import 'package:scorecard/handlers/ulid.dart';
import 'package:scorecard/modules/player/player_model.dart';

class PlayerRepository {
  final _repo = <String, Player>{};

  Future<List<Player>> getAllPlayers() async =>
      _repo.values.toList()..sort((a, b) => a.name.compareTo(b.name));

  Future<Player> createPlayer({required String name}) async {
    final player = Player(UlidHandler.generate(), name: name);
    savePlayer(player);
    return player;
  }

  Future<void> savePlayer(Player player) async {
    _repo[player.id] = player;
  }
}
