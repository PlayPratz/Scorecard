import 'dart:collection';

import 'package:scorecard/handlers/sql_db_handler.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/repositories/sql/keys.dart';

abstract class IPlayerRepository {
  Future<UnmodifiableListView<Player>> loadAll();

  /// Save the given player
  Future<Player> save(Player player);

  /// Load the player of the given ID
  Future<Player> load(int id);
}

class SQLPlayerRepository implements IPlayerRepository {
  final SQLDBHandler _sql;

  SQLPlayerRepository(this._sql);

  @override
  Future<Player> load(int id) async {
    final entity = await _sql
        .query(table: Tables.players, where: "id = ?", whereArgs: [id]);
    final player = _unpackPlayer(entity.single);
    return player;
  }

  @override
  Future<UnmodifiableListView<Player>> loadAll() async {
    final entities = await _sql.query(table: Tables.players);
    return UnmodifiableListView(entities.map(_unpackPlayer));
  }

  @override
  Future<Player> save(Player player) async {
    if (player.id == null) {
      return _create(player);
    }

    await _sql.update(
      table: Tables.players,
      values: _repackPlayer(player),
      where: "id = ?",
      whereArgs: [player.id],
    );

    return load(player.id!);
  }

  Future<Player> _create(Player player) async {
    final map = _repackPlayer(player);
    final id = await _sql.insert(table: Tables.players, values: map);
    return load(id);
  }

  Map<String, Object?> _repackPlayer(Player player) => {
        "id": player.id,
        "handle": player.handle,
        "name": player.name,
        "full_name": player.fullName,
        "date_of_birth": player.dateOfBirth?.millisecondsSinceEpoch,
      };

  Player _unpackPlayer(Map<String, Object?> map) => Player(
        id: map["id"] as int,
        handle: map["handle"] as String,
        name: map["name"] as String,
        fullName: map["full_name"] as String?,
        dateOfBirth: map["date_of_birth"] != null
            ? DateTime.fromMillisecondsSinceEpoch(map["date_of_birth"] as int)
            : null,
      );
}
