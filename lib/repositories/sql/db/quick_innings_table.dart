import 'package:scorecard/repositories/sql/db/sql_interface.dart';
import 'package:scorecard/repositories/sql/keys.dart';

class QuickInningsEntity implements IEntity {
  final int? id;
  final String match_id;
  final int innings_number;
  final int type;
  // final String batting_team_id;
  // final String bowling_team_id;
  // final bool is_forfeited;
  final bool is_declared;
  final String? batter1_id;
  final String? batter2_id;
  final String? striker_id; // TODO is this needed?
  final String? bowler_id;
  final int? target_runs;

  QuickInningsEntity({
    required this.id,
    required this.match_id,
    required this.innings_number,
    required this.type,
    // required this.batting_team_id,
    // required this.bowling_team_id,
    // required this.is_forfeited,
    required this.is_declared,
    required this.batter1_id,
    required this.batter2_id,
    required this.striker_id,
    required this.bowler_id,
    required this.target_runs,
  });

  QuickInningsEntity.deserialize(Map<String, Object?> map)
      : this(
          id: map["id"] as int,
          match_id: map["match_id"] as String,
          innings_number: map["innings_number"] as int,
          type: map["type"] as int,
          // batting_team_id: map["batting_team_id"] as String,
          // bowling_team_id: map["bowling_team_id"] as String,
          // is_forfeited: readBool(map["is_forfeited"] as int)!,
          is_declared: readBool(map["is_declared"] as int)!,
          batter1_id: map["batter1_id"] as String?,
          batter2_id: map["batter2_id"] as String?,
          striker_id: map["striker_id"] as String?,
          bowler_id: map["bowler_id"] as String?,
          target_runs: map["target_runs"] as int?,
        );

  @override
  Map<String, Object?> serialize() => {
        "id": id,
        "match_id": match_id,
        "innings_number": innings_number,
        "type": type,
        // "batting_team_id": batting_team_id,
        // "bowling_team_id": bowling_team_id,
        // "is_forfeited": is_forfeited ? 1 : 0,
        "is_declared": parseBool(is_declared),
        "batter1_id": batter1_id,
        "batter2_id": batter2_id,
        "striker_id": striker_id,
        "bowler_id": bowler_id,
        "target_runs": target_runs,
      };

  @override
  int? get primary_key => id;
}

class QuickInningsTable extends ISQL<QuickInningsEntity> {
  @override
  QuickInningsEntity deserialize(Map<String, Object?> map) =>
      QuickInningsEntity.deserialize(map);

  @override
  String get table => Tables.quickInnings;

  Future<Iterable<QuickInningsEntity>> selectAllForMatch(matchId) async {
    final raw = await sql.query(
      table: table,
      where: "match_id = ?",
      whereArgs: [matchId],
    );
    final result = raw.map((e) => deserialize(e));
    return result;
  }

  Future<Iterable<QuickInningsEntity>> selectLastForMatch(matchId,
      {int top = 1}) async {
    if (top < 1) throw UnsupportedError("Attempted to select less than 1 row");

    final raw = await sql.query(
      table: table,
      where: "match_id = ?",
      whereArgs: [matchId],
      limit: top,
      orderBy: "innings_number DESC",
    );
    final result = raw.map((e) => deserialize(e));
    return result;
  }
}
