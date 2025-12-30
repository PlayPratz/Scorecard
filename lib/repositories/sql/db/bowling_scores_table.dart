import 'package:scorecard/repositories/sql/db/sql_interface.dart';
import 'package:scorecard/repositories/sql/keys.dart';

class BowlingScoresEntity implements IEntity {
  final int id;
  final int match_id;
  final int innings_id;
  final int innings_type;
  final int innings_number;
  final int player_id;

  final int balls_bowled;
  final int overs_bowled;
  final int overs_balls_bowled;
  final int runs_conceded;
  final int wickets_taken;

  final int extras_no_balls;
  final int extras_wides;
  final int extras_total;

  final double economy;

  BowlingScoresEntity._({
    required this.id,
    required this.match_id,
    required this.innings_id,
    required this.innings_type,
    required this.innings_number,
    required this.player_id,
    required this.balls_bowled,
    required this.overs_bowled,
    required this.overs_balls_bowled,
    required this.runs_conceded,
    required this.wickets_taken,
    required this.extras_no_balls,
    required this.extras_wides,
    required this.extras_total,
    required this.economy,
  });

  BowlingScoresEntity.deserialize(Map<String, Object?> map)
      : this._(
          id: map["id"] as int,
          match_id: map["match_id"] as int,
          innings_id: map["innings_id"] as int,
          innings_type: map["innings_type"] as int,
          innings_number: map["innings_number"] as int,
          player_id: map["player_id"] as int,
          balls_bowled: map["balls_bowled"] as int,
          overs_bowled: map["overs_bowled"] as int,
          overs_balls_bowled: map["overs_balls_bowled"] as int,
          runs_conceded: map["runs_conceded"] as int,
          wickets_taken: map["wickets_taken"] as int,
          extras_no_balls: map["extras_no_balls"] as int,
          extras_wides: map["extras_wides"] as int,
          extras_total: map["extras_total"] as int,
          economy: map["economy"] as double,
        );

  @override
  Map<String, Object?> serialize() {
    throw UnimplementedError();
  }
}

class BowlingScoresTable extends ISQL<BowlingScoresEntity> {
  @override
  BowlingScoresEntity deserialize(Map<String, Object?> map) =>
      BowlingScoresEntity.deserialize(map);

  @override
  String get table => Tables.battingScores;

  Future<Iterable<BowlingScoresEntity>> selectForInnings(int inningsId) async {
    final result = await sql
        .query(table: table, where: "innings_id = ?", whereArgs: [inningsId]);
    final entities = result.map((e) => BowlingScoresEntity.deserialize(e));
    return entities;
  }

  Future<BowlingScoresEntity> selectForInningsAndBowler(
      int inningsId, int bowlerId) async {
    final result = await sql.query(
        table: table,
        where: "innings_id = ? AND player_id = bowler_id",
        whereArgs: [inningsId]);
    final entities = result.map((e) => BowlingScoresEntity.deserialize(e));
    return entities.single;
  }
}
