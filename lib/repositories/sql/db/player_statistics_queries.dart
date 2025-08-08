import 'package:scorecard/repositories/sql/db/sql_interface.dart';

class PlayerSingleStatEntity implements IEntity {
  final String id;
  final String name;
  final int value;

  PlayerSingleStatEntity(
      {required this.id, required this.name, required this.value});

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

class PlayerStatisticsQueries extends ISQL<PlayerSingleStatEntity> {
  @override
  PlayerSingleStatEntity deserialize(Map<String, Object?> map) =>
      throw UnimplementedError();

  @override
  String get table => throw UnimplementedError();

  Future<Iterable<PlayerSingleStatEntity>> runsByAllPlayers() async {
    final result = await sql.rawQuery(
        "SELECT b.batter_id, p.name, SUM(b.batter_runs) FROM balls b, players p "
        "WHERE b.batter_id = p.id GROUP BY b.batter_id "
        "ORDER BY SUM(b.batter_runs) DESC");

    final entities = result.map((e) => PlayerSingleStatEntity(
          id: e["batter_id"] as String,
          name: e["name"] as String,
          value: e["SUM(b.batter_runs)"] as int,
        ));
    return entities;
  }

  Future<Iterable<PlayerSingleStatEntity>> wicketsByAllPlayers() async {
    final result = await sql.rawQuery(
        "SELECT b.bowler_id, p.name, COUNT(b.wicket_type) FROM balls b, players p "
        "WHERE b.bowler_id = p.id GROUP BY b.bowler_id "
        "ORDER BY COUNT(b.wicket_type) DESC");

    final entities = result.map((e) => PlayerSingleStatEntity(
          id: e["bowler_id"] as String,
          name: e["name"] as String,
          value: e["COUNT(b.wicket_type)"] as int,
        ));

    return entities;
  }

  Future<dynamic> getStatsForPlayer(String id) async {
    final result = sql.rawQuery(
        "SELECT p.id, SUM(b.runs), COUNT(b.wicket_type) FROM balls b, players p "
        "WHERE b.batter_id = p.player_id");
  }
}
