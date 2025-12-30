import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/modules/quick_match/quick_match_model.dart';
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

  Future<Player> create(Player player) async {
    final playerEntity = EntityMappers.repackPlayer(player);
    final id = await _playersTable.insert(playerEntity);
    return load(id);
  }

  Future<Player> save(Player player) async {
    final playerEntity = EntityMappers.repackPlayer(player);
    await _playersTable.update(playerEntity);
    return load(player.id);
  }

  Future<Player> load(int id) async {
    final playerEntity = await _playersTable.select(id);

    if (playerEntity == null) {
      throw StateError("Unable to load Player from the DB! (id: $id)");
    }

    final player = EntityMappers.unpackPlayer(playerEntity);
    return player;
  }

  Future<List<Player>> loadMultiple(Set<int> ids) async {
    final playerEntities = await _playersTable.selectMultiple(ids);
    final players = playerEntities.map((p) => EntityMappers.unpackPlayer(p));

    return players.toList();
  }

  Future<List<Player>> loadPlayersForMatch(QuickMatch match) async {
    if (match.id == -1) {
      throw StateError("Attempted to load players for match with no ID");
    }

    final playerEntities = await _playersTable.selectForMatch(match.id);
    final players = playerEntities.map((p) => EntityMappers.unpackPlayer(p));

    return players.toList();
  }
}
