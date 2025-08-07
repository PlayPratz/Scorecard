import 'package:scorecard/repositories/sql/db/sql_interface.dart';

class PlayerStatEntity implements IEntity {
  final String id;
  final String name;
  final int value;

  PlayerStatEntity({required this.id, required this.name, required this.value});

  // PlayerStatEntity.deserialize(Map<String, Object?> map)
  //     : id = map["id"] as String,
  //       name = map["name"] as String,
  //       value = map["value"] as int;

  @override
  Map<String, Object?> serialize() => {
        "id": id,
        "name": name,
        "value": value,
      };

  @override
  List get primary_key => throw UnimplementedError();
}

class PlayerStatisticsQueries extends ISQL<PlayerStatEntity> {
  @override
  PlayerStatEntity deserialize(Map<String, Object?> map) =>
      throw UnimplementedError();

  @override
  String get table => throw UnimplementedError();

  Future<Iterable<PlayerStatEntity>> runsByAllPlayers() async {
    final result = await sql.rawQuery(
        "SELECT po.batter_id, pl.name, SUM(po.batter_runs) FROM posts po, players pl "
        "WHERE pl.id = po.batter_id GROUP BY po.batter_id "
        "ORDER BY SUM(po.batter_runs) DESC");

    final entities = result.map((e) => PlayerStatEntity(
          id: e["batter_id"] as String,
          name: e["name"] as String,
          value: e["SUM(po.batter_runs)"] as int,
        ));
    return entities;
  }

  Future<Iterable<PlayerStatEntity>> wicketsByAllPlayers() async {
    final result = await sql.rawQuery(
        "SELECT po.bowler_id, pl.name, COUNT(po.wicket_type) FROM posts po, players pl "
        "WHERE pl.id = po.bowler_id AND po.wicket_type NOT NULL GROUP BY po.bowler_id "
        "ORDER BY COUNT(po.wicket_type) DESC");

    final entities = result.map((e) => PlayerStatEntity(
          id: e["bowler_id"] as String,
          name: e["name"] as String,
          value: e["COUNT(po.wicket_type)"] as int,
        ));

    return entities;
  }
}
