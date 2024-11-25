import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/repositories/generic_repository.dart';
import 'package:scorecard/repositories/sql/handlers/sql_db_handler.dart';
import 'package:scorecard/repositories/sql/keys.dart';

class SQLPlayerRepository implements IRepository<Player> {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> create(Player object) async {
    await _sql.insert(table: Tables.players, values: _serialize(object));
  }

  @override
  Future<Player?> read(String id) async {
    final result = await _sql
        .query(table: Tables.players, where: "id = ?", whereArgs: [id]);
    final player = result.map((e) => _deserialize(e));
    return player.singleOrNull;
  }

  @override
  Future<Iterable<Player>> readAll() async {
    final result = await _sql.query(table: Tables.players);
    final players = result.map((e) => _deserialize(e));
    return players;
  }

  @override
  Future<Iterable<Player>> search(String query) async {
    // TODO: implement search
    throw UnimplementedError();
  }

  @override
  Future<void> update(Player object) async {
    final result = await _sql.update(
      table: Tables.players,
      values: _serialize(object),
      where: "id = ?",
      whereArgs: [object.id],
    );
    if (result <= 0) {
      throw StateError(
          "Attempted to update player that does not exist! ID: ${object.id}");
    }
  }

  @override
  Future<void> delete(String id) async {}

  SQLDBHandler get _sql => SQLDBHandler.instance;

  Map<String, Object?> _serialize(Player player) => {
        "id": player.id,
        "name": player.name,
        "full_name": player.fullName,
      };

  Player _deserialize(Map<String, Object?> map) => Player(
      id: map["id"] as String,
      name: map["name"] as String,
      fullName: map["full_name"] as String?);
}
