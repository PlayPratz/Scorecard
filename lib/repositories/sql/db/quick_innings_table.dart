import 'package:scorecard/repositories/sql/db/sql_interface.dart';
import 'package:scorecard/repositories/sql/keys.dart';

class QuickInningsEntity implements IEntity {
  final int id;
  final int match_id;
  final int innings_number;
  final int type;
  // final bool is_follow_on;
  // final String batting_team_id;
  // final String bowling_team_id;
  final int state;

  final int overs_limit;
  final int balls_per_over;
  final int? target_runs;

  final int runs;
  final int wickets;
  final int balls;

  final int extras_no_balls;
  final int extras_wides;
  final int extras_byes;
  final int extras_leg_byes;
  final int extras_penalties;

  final int? batter1_id;
  final int? batter2_id;
  final int? striker_id;
  final int? bowler_id;

  QuickInningsEntity({
    required this.id,
    required this.match_id,
    required this.innings_number,
    required this.type,
    required this.state,
    // required this.is_follow_on,
    // required this.batting_team_id,
    // required this.bowling_team_id,
    required this.overs_limit,
    required this.balls_per_over,
    required this.target_runs,
    required this.runs,
    required this.wickets,
    required this.balls,
    required this.extras_no_balls,
    required this.extras_wides,
    required this.extras_byes,
    required this.extras_leg_byes,
    required this.extras_penalties,
    required this.batter1_id,
    required this.batter2_id,
    required this.striker_id,
    required this.bowler_id,
  });

  QuickInningsEntity.deserialize(Map<String, Object?> map)
      : this(
          id: map["id"] as int,
          match_id: map["match_id"] as int,
          innings_number: map["innings_number"] as int,
          type: map["type"] as int,
          // batting_team_id: map["batting_team_id"] as String,
          // bowling_team_id: map["bowling_team_id"] as String,
          state: map["state"] as int,
          overs_limit: map["overs_limit"] as int,
          balls_per_over: map["balls_per_over"] as int,
          target_runs: map["target_runs"] as int?,
          runs: map["runs"] as int,
          wickets: map["wickets"] as int,
          balls: map["balls"] as int,
          extras_no_balls: map["extras_no_balls"] as int,
          extras_wides: map["extras_wides"] as int,
          extras_byes: map["extras_byes"] as int,
          extras_leg_byes: map["extras_leg_byes"] as int,
          extras_penalties: map["extras_penalties"] as int,
          batter1_id: map["batter1_id"] as int?,
          batter2_id: map["batter2_id"] as int?,
          striker_id: map["striker_id"] as int?,
          bowler_id: map["bowler_id"] as int?,
        );

  @override
  Map<String, Object?> serialize() => {
        "id": id,
        "match_id": match_id,
        "innings_number": innings_number,
        "type": type,
        // "is_follow_on": is_follow_on,
        // "batting_team_id": batting_team_id,
        // "bowling_team_id": bowling_team_id,
        "overs_limit": overs_limit,
        "balls_per_over": balls_per_over,
        "target_runs": target_runs,
        "runs": runs,
        "wickets": wickets,
        "balls": balls,
        "extras_no_balls": extras_no_balls,
        "extras_wides": extras_wides,
        "extras_byes": extras_byes,
        "extras_leg_byes": extras_leg_byes,
        "extras_penalties": extras_penalties,
        "batter1_id": batter1_id,
        "batter2_id": batter2_id,
        "striker_id": striker_id,
        "bowler_id": bowler_id,
      };
}

class QuickInningsTable extends ISQL<QuickInningsEntity> {
  @override
  QuickInningsEntity deserialize(Map<String, Object?> map) =>
      QuickInningsEntity.deserialize(map);

  @override
  String get table => Tables.quickInnings;

  Future<Iterable<QuickInningsEntity>> selectAllForMatch(int matchId) async {
    final raw = await sql.query(
      table: table,
      where: "match_id = ?",
      whereArgs: [matchId],
    );
    final result = raw.map((e) => deserialize(e));
    return result;
  }

  Future<Iterable<QuickInningsEntity>> selectLastForMatch(int matchId,
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
