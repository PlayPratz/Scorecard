import 'package:scorecard/repositories/sql/db/sql_crud.dart';
import 'package:scorecard/repositories/sql/handlers/sql_db_handler.dart';
import 'package:scorecard/repositories/sql/keys.dart';

class PlayersInMatchEntity implements IEntity {
  final String match_id;
  final String team_id;
  final String player_id;
  final bool is_captain;
  final String opponent_team_id;
  final bool is_match_completed;
  // Batting
  final int? batter_number;
  final int? runs_scored;
  final int? balls_faced;
  final bool? is_out;
  final bool? is_retired;
  final double? strike_rate;
  // Bowling
  final int? runs_conceded;
  final int? wickets_taken;
  final int? maidens_bowled;
  final int? balls_bowled;
  final double? economy;

  PlayersInMatchEntity({
    required this.match_id,
    required this.team_id,
    required this.player_id,
    required this.is_captain,
    required this.opponent_team_id,
    required this.is_match_completed,
    required this.batter_number,
    required this.runs_scored,
    required this.balls_faced,
    required this.is_out,
    required this.is_retired,
    required this.strike_rate,
    required this.runs_conceded,
    required this.wickets_taken,
    required this.maidens_bowled,
    required this.balls_bowled,
    required this.economy,
  });

  PlayersInMatchEntity.deserialize(Map<String, Object?> map)
      : this(
          match_id: map["match_id"] as String,
          team_id: map["team_id"] as String,
          player_id: map["player_id"] as String,
          is_captain: readBool(map["is_captain"] as int)!,
          opponent_team_id: map["opponent_team_id"] as String,
          is_match_completed:
              readBool(map["is_match_completed"] as int?) ?? false, // TODO
          batter_number: map["batter_number"] as int?,
          runs_scored: map["runs_scored"] as int?,
          balls_faced: map["balls_faced"] as int?,
          is_out: readBool(map["is_out"] as int?),
          is_retired: readBool(map["is_retired"] as int?),
          strike_rate: map["strike_rate"] as double?,
          runs_conceded: map["runs_conceded"] as int?,
          wickets_taken: map["wickets_taken"] as int?,
          maidens_bowled: map["maidens_bowled"] as int?,
          balls_bowled: map["balls_bowled"] as int?,
          economy: map["economy"] as double?,
        );

  @override
  Map<String, Object?> serialize() => {
        "match_id": match_id,
        "team_id": team_id,
        "player_id": player_id,
        "is_captain": is_captain ? 1 : 0,
        "opponent_team_id": opponent_team_id,
        "is_match_completed": is_match_completed ? 1 : 0,
        "batter_number": batter_number,
        "runs_scored": runs_scored,
        "balls_faced": balls_faced,
        "is_out": is_out == null
            ? null
            : is_out!
                ? 1
                : 0,
        "is_retired": is_retired == null
            ? null
            : is_retired!
                ? 1
                : 0,
        "strike_rate": strike_rate,
        "runs_conceded": runs_conceded,
        "wickets_taken": wickets_taken,
        "maidens_bowled": maidens_bowled,
        "balls_bowled": balls_bowled,
        "economy": economy,
      };

  @override
  List get primary_key => [match_id, team_id, player_id];
}

class PlayersInMatchTable extends ICrud<PlayersInMatchEntity> {
  @override
  String get table => Tables.playersInMatch;

  @override
  String get where => "match_id = ?, team_id = ?, player_id = ?";

  @override
  Future<PlayersInMatchEntity?> read(String id) async {
    throw UnsupportedError(
        "Attempted to call PlayersInMatchTable.read(). Use readWhere() instead.");
  }

  Future<Iterable<PlayersInMatchEntity>> readWhere(
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
  deserialize(Map<String, Object?> map) =>
      PlayersInMatchEntity.deserialize(map);
}
