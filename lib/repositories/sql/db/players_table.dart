import 'package:scorecard/repositories/sql/db/sql_interface.dart';
import 'package:scorecard/repositories/sql/keys.dart';

class PlayersEntity implements IEntity {
  final String id;
  final String name;
  // final String? full_name;

  PlayersEntity({
    required this.id,
    required this.name,
    // required this.full_name,
  });

  PlayersEntity.deserialize(Map<String, Object?> map)
      : this(
          id: map["id"] as String,
          name: map["name"] as String,
          // full_name: map["full_name"] as String?,
        );

  @override
  Map<String, Object?> serialize() => {
        "id": id,
        "name": name,
        // "full_name": full_name,
      };

  @override
  List get primary_key => [id];
}

class PlayersTable extends ISQL<PlayersEntity> {
  @override
  String get table => Tables.players;

  @override
  PlayersEntity deserialize(Map<String, Object?> map) =>
      PlayersEntity.deserialize(map);

  // TODO Find better place
  Future<Iterable<PlayersEntity>> selectForMatch(String matchId) async {
    final raw = await sql.rawQuery(
      'SELECT * from PLAYERS WHERE id IN('
      'SELECT batter_id FROM posts WHERE match_id = ? UNION '
      'SELECT bowler_id FROM posts WHERE match_id = ? UNION '
      'SELECT wicket_fielder_id FROM posts WHERE match_id = ? AND wicket_fielder_id IS NOT NULL)',
      [matchId, matchId, matchId],
    );

    final result = raw.map((m) => deserialize(m));
    return result;
  }
}
