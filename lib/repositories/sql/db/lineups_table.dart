import 'package:scorecard/repositories/sql/db/sql_crud.dart';
import 'package:scorecard/repositories/sql/keys.dart';

class LineupsEntity implements IEntity {
  final String match_id;
  final String team_id;
  final String player_id;
  final bool is_captain;

  LineupsEntity({
    required this.match_id,
    required this.team_id,
    required this.player_id,
    required this.is_captain,
  });

  LineupsEntity.deserialize(Map<String, Object?> map)
      : this(
          match_id: map["match_id"] as String,
          team_id: map["team_id"] as String,
          player_id: map["player_id"] as String,
          is_captain: map["is_captain"] as bool,
        );

  @override
  Map<String, Object?> serialize() => {
        "match_id": match_id,
        "team_id": team_id,
        "player_id": player_id,
        "is_captain": is_captain,
      };

  @override
  List get primary_key => [match_id, team_id, player_id];
}

class LineupsTable extends ICrud<LineupsEntity> {
  @override
  String get table => Tables.lineups;

  @override
  String get where => "match_id = ?, team_id = ?, player_id = ?";

  @override
  deserialize(Map<String, Object?> map) => LineupsEntity.deserialize(map);
}
