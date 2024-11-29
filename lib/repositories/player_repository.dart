import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/repositories/sql/db/players_table.dart';
import 'package:scorecard/repositories/sql/entity_mappers.dart';

class PlayerRepository {
  final PlayersTable playersTable;

  PlayerRepository({required this.playersTable});

  Future<void> save(Player player, {required bool update}) async {
    final entity = EntityMappers.repackPlayer(player);
    if (update) {
      await playersTable.update(entity);
    } else {
      await playersTable.create(entity);
    }
  }

  Future<Player> fetchById(String id) async {
    final entity = await playersTable.read(id);
    if (entity == null) {
      throw StateError("Player not found in DB! (id: $id)");
    }
    final player = EntityMappers.unpackPlayer(entity);
    return player;
  }

  Future<Iterable<Player>> fetchAll() async {
    final entities = await playersTable.readAll();
    final players = entities.map((e) => EntityMappers.unpackPlayer(e));
    return players;
  }
}
