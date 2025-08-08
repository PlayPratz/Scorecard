import 'package:scorecard/repositories/sql/db/sql_interface.dart';
import 'package:scorecard/handlers/sql_db_handler.dart';
import 'package:scorecard/repositories/sql/keys.dart';

class QuickMatchesEntity implements IEntity {
  final String id;
  final int type;
  final int stage;
  // final String team1_id;
  // final String team2_id;
  // final String venue_id;
  final DateTime starts_at;
  // final int rules_id;
  // final String? toss_winner_id;
  // final int? toss_choice;
  // final int? result_type;
  // final String? result_winner_id;
  // final String? result_loser_id;
  // final int? result_margin_1;
  // final int? result_margin_2;
  // final String? potm_id;
  final int rules_balls_per_over;
  final int rules_balls_per_innings;
  final int rules_no_ball_penalty;
  final int rules_wide_penalty;
  final bool rules_only_single_batter;

  QuickMatchesEntity({
    required this.id,
    required this.type,
    required this.stage,
    // required this.team1_id,
    // required this.team2_id,
    // required this.venue_id,
    required this.starts_at,
    // required this.rules_id,
    required this.rules_balls_per_over,
    required this.rules_balls_per_innings,
    required this.rules_no_ball_penalty,
    required this.rules_wide_penalty,
    required this.rules_only_single_batter,
    // this.toss_winner_id,
    // this.toss_choice,
    // this.result_type,
    // this.result_winner_id,
    // this.result_loser_id,
    // this.result_margin_1,
    // this.result_margin_2,
    // this.potm_id,
  });

  QuickMatchesEntity.deserialize(Map<String, Object?> map)
      : this(
          id: map["id"] as String,
          type: map["type"] as int,
          stage: map["stage"] as int,
          // team1_id: map["team1_id"] as String,
          // team2_id: map["team2_id"] as String,
          // venue_id: map["venue_id"] as String,
          starts_at: readDateTime(map["starts_at"] as int)!,
          // rules_id: map["rules_id"] as int,
          rules_balls_per_over: map["rules_balls_per_over"] as int,
          rules_balls_per_innings: map["rules_balls_per_innings"] as int,
          rules_no_ball_penalty: map["rules_no_ball_penalty"] as int,
          rules_wide_penalty: map["rules_wide_penalty"] as int,
          rules_only_single_batter:
              readBool(map["rules_only_single_batter"] as int)!,
          // toss_winner_id: map["toss_winner_id"] as String?,
          // toss_choice: map["toss_choice"] as int?,
          // result_type: map["result_type"] as int?,
          // result_winner_id: map["result_winner_id"] as String?,
          // result_loser_id: map["result_loser_id"] as String?,
          // result_margin_1: map["result_margin_1"] as int?,
          // result_margin_2: map["result_margin_2"] as int?,
          // potm_id: map["potm_id"] as String?,
        );

  @override
  Map<String, Object?> serialize() => {
        "id": id,
        "type": type,
        "stage": stage,
        // "team1_id": team1_id,
        // "team2_id": team2_id,
        // "venue_id": venue_id,
        "starts_at": starts_at.microsecondsSinceEpoch,
        // "rules_id": rules_id,
        "rules_balls_per_over": rules_balls_per_over,
        "rules_balls_per_innings": rules_balls_per_innings,
        "rules_no_ball_penalty": rules_no_ball_penalty,
        "rules_wide_penalty": rules_wide_penalty,
        "rules_only_single_batter": rules_only_single_batter ? 1 : 0,
        // "toss_winner_id": toss_winner_id,
        // "toss_choice": toss_choice,
        // "result_type": result_type,
        // "result_winner_id": result_winner_id,
        // "result_loser_id": result_loser_id,
        // "result_margin_1": result_margin_1,
        // "result_margin_2": result_margin_2,
        // "potm_id": potm_id,
      };

  @override
  String get primary_key => id;
}

class QuickMatchesTable extends ISQL<QuickMatchesEntity> {
  @override
  Future<QuickMatchesEntity?> select(String id) async {
    final raw = await _sql
        .query(table: Tables.quickMatches, where: "id = ?", whereArgs: [id]);
    final map = raw.singleOrNull;
    final result = QuickMatchesEntity.deserialize(map);
    return result;
  }

  @override
  Future<Iterable<QuickMatchesEntity>> selectAll() async {
    final raw =
        await _sql.query(table: Tables.quickMatches, orderBy: "starts_at DESC");
    final result = raw.map((m) => QuickMatchesEntity.deserialize(m));
    return result;
  }

  @override
  Future<void> update(QuickMatchesEntity object) async {
    await _sql.update(
        table: Tables.quickMatches,
        values: object.serialize(),
        where: "id = ?",
        whereArgs: [object.id]);
  }

  SQLDBHandler get _sql => SQLDBHandler.instance;

  @override
  QuickMatchesEntity deserialize(Map<String, Object?> map) =>
      QuickMatchesEntity.deserialize(map);

  @override
  String get table => Tables.quickMatches;
}
