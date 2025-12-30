import 'package:scorecard/repositories/sql/db/sql_interface.dart';
import 'package:scorecard/repositories/sql/keys.dart';

class BattingScoresEntity implements IEntity {
  final int id;
  final int match_id;
  final int innings_id;
  final int innings_type;
  final int innings_number;
  final int player_id;

  final int batting_at;
  final int runs_scored;
  final int balls_faced;
  final bool not_out;

  final int? wicket_type;
  final int? wicket_bowler_id;
  final int? wicket_fielder_id;

  final int fours_scored;
  final int sixes_scored;
  final int boundaries_scored;

  final double strike_rate;

  BattingScoresEntity._({
    required this.id,
    required this.match_id,
    required this.innings_id,
    required this.innings_type,
    required this.innings_number,
    required this.player_id,
    required this.batting_at,
    required this.runs_scored,
    required this.balls_faced,
    required this.not_out,
    required this.wicket_type,
    required this.wicket_bowler_id,
    required this.wicket_fielder_id,
    required this.fours_scored,
    required this.sixes_scored,
    required this.boundaries_scored,
    required this.strike_rate,
  });

  BattingScoresEntity.deserialize(Map<String, Object?> map)
      : this._(
          id: map["id"] as int,
          match_id: map["match_id"] as int,
          innings_id: map["innings_id"] as int,
          innings_type: map["innings_type"] as int,
          innings_number: map["innings_number"] as int,
          player_id: map["player_id"] as int,
          batting_at: map["batting_at"] as int,
          runs_scored: map["runs_scored"] as int,
          balls_faced: map["balls_faced"] as int,
          not_out: readBool(map["not_out"])!,
          wicket_type: map["wicket_type"] as int?,
          wicket_bowler_id: map["wicket_bowler_id"] as int?,
          wicket_fielder_id: map["wicket_fielder_id"] as int?,
          fours_scored: map["fours_scored"] as int,
          sixes_scored: map["sixes_scored"] as int,
          boundaries_scored: map["boundaries_scored"] as int,
          strike_rate: map["strike_rate"] as double,
        );

  @override
  Map<String, Object?> serialize() {
    throw UnimplementedError();
  }

  // Map<String, Object?> serialize() => {
  //   "id": id,
  //   "match_id": match_id,
  //   "innings_id": innings_id,
  //   "innings_number": innings_number,
  //   "played_id": player_id,
  //   "batting_at": batting_at,
  //   "runs_scored": runs_scored,
  //   "balls_faced": balls_faced,
  //   "not_out": not_out,
  //   "wicket_type": wicket_type,
  //   "wicket_bowler_id": wicket_bowler_id,
  //   "wicket_fielder_id": wicket_fielder_id,
  //   "fours_scored": fours_scored,
  //   "sixes_scored": sixes_scored,
  //   "boundaries_scored": boundaries_scored,
  //   "strike_rate": strike_rate,
  // };
}

class BattingScoresTable extends ISQL<BattingScoresEntity> {
  @override
  BattingScoresEntity deserialize(Map<String, Object?> map) =>
      BattingScoresEntity.deserialize(map);

  @override
  String get table => Tables.battingScores;

  Future<Iterable<BattingScoresEntity>> selectForInnings(int inningsId) async {
    final result = await sql
        .query(table: table, where: "innings_id = ?", whereArgs: [inningsId]);
    final entities = result.map((e) => BattingScoresEntity.deserialize(e));
    return entities;
  }

  Future<Iterable<BattingScoresEntity>> selectLastForInningsAndBatter(
      int inningsId, int batterId,
      {int top = 1}) async {
    if (top < 1) throw UnsupportedError("Attempted to select less than 1 row");

    final raw = await sql.query(
      table: table,
      where: "innings_id = ? AND player_id = ?",
      whereArgs: [inningsId, batterId],
      limit: top,
      orderBy: "innings_number DESC",
    );

    final result = raw.map((e) => deserialize(e));
    return result;
  }
}
