import 'package:scorecard/handlers/ulid_handler.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/repositories/sql/db/players_table.dart';
import 'package:scorecard/repositories/sql/entity_mappers.dart';

class PlayerRepository {
  final PlayersTable _playersTable;

  PlayerRepository(this._playersTable);

  Future<List<Player>> loadAll() async {
    final playerEntities = await _playersTable.selectAll();
    final players = playerEntities
        .map((p) => EntityMappers.unpackPlayer(p))
        .toList(growable: false);
    return players;
  }

  Future<Player> create({required String name}) async {
    final id = UlidHandler.generate();
    final player = Player(id, name: name);

    final playerEntity = EntityMappers.repackPlayer(player);

    await _playersTable.insert(playerEntity);
    return player;
  }

  Future<Player> save(Player player) async {
    final playerEntity = EntityMappers.repackPlayer(player);
    await _playersTable.update(playerEntity);
    return player;
  }

  Future<Player?> load(String id) async {
    final playerEntity = await _playersTable.select(id);

    if (playerEntity == null) {
      // Player not found
      return null;
    }

    final player = EntityMappers.unpackPlayer(playerEntity);

    return player;
  }

  Future<List<Player>> loadMultiple(Set<String> ids) async {
    final playerEntities = await _playersTable.selectMultiple(ids);
    final players = playerEntities.map((p) => EntityMappers.unpackPlayer(p));

    return players.toList();
  }
}
