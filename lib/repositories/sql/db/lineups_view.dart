import 'package:scorecard/repositories/sql/db/players_in_match_table.dart';
import 'package:scorecard/repositories/sql/db/players_table.dart';
import 'package:scorecard/repositories/sql/db/sql_crud.dart';
import 'package:scorecard/repositories/sql/handlers/sql_db_handler.dart';
import 'package:scorecard/repositories/sql/keys.dart';

class LineupsExpandedEntity implements IEntity {
  final PlayersInMatchEntity lineupsEntity;
  final PlayersEntity playersEntity;

  LineupsExpandedEntity._(
      {required this.lineupsEntity, required this.playersEntity});

  factory LineupsExpandedEntity.deserialize(Map<String, Object?> map) {
    final lineupsEntity = PlayersInMatchEntity.deserialize(map);
    final players = {...map};
    players["id"] = lineupsEntity.player_id;
    final playersEntity = PlayersEntity.deserialize(players);

    return LineupsExpandedEntity._(
      lineupsEntity: lineupsEntity,
      playersEntity: playersEntity,
    );
  }

  @override
  Map<String, Object?> serialize() {
    // TODO: implement serialize
    throw UnsupportedError("Attempted to serialize LineupsExpandedEntity");
  }

  @override
  List get primary_key => lineupsEntity.primary_key;
}

class LineupsExpandedView extends ICrud<LineupsExpandedEntity> {
  @override
  LineupsExpandedEntity deserialize(Map<String, Object?> map) =>
      LineupsExpandedEntity.deserialize(map);

  Future<Iterable<LineupsExpandedEntity>> readWhere(
      {String? matchId, String? teamId, String? playerId}) async {
    final whereList = [];
    final whereArgs = [];
    if (matchId != null) {
      whereList.add("match_id = ?");
      whereArgs.add(matchId);
    }
    if (teamId != null) {
      whereList.add("team_id = ?");
      whereArgs.add(teamId);
    }
    if (playerId != null) {
      whereList.add("player_id = ?");
      whereArgs.add(playerId);
    }

    final where = whereList.join(" AND ");

    final result =
        await _sql.query(table: table, where: where, whereArgs: whereArgs);
    final entities = result.map((e) => deserialize(e));
    return entities;
  }

  SQLDBHandler get _sql => SQLDBHandler.instance;

  @override
  String get table => Views.lineups;
}
