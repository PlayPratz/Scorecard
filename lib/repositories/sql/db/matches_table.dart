import 'package:scorecard/repositories/sql/db/sql_crud.dart';
import 'package:scorecard/repositories/sql/handlers/sql_db_handler.dart';
import 'package:scorecard/repositories/sql/keys.dart';

class MatchesEntity implements IEntity {
  final String id;
  final int stage;
  final String team1_id;
  final String team2_id;
  final String venue_id;
  final DateTime starts_at;
  final int game_rules_id;
  final int game_rules_type;
  final String? toss_winner_id;
  final int? toss_choice;
  final int? result_type;
  final String? result_winner_id;
  final String? result_loser_id;
  final int? result_margin_1;
  final int? result_margin_2;
  final String? potm_id;

  MatchesEntity({
    required this.id,
    required this.stage,
    required this.team1_id,
    required this.team2_id,
    required this.venue_id,
    required this.starts_at,
    required this.game_rules_id,
    required this.game_rules_type,
    this.toss_winner_id,
    this.toss_choice,
    this.result_type,
    this.result_winner_id,
    this.result_loser_id,
    this.result_margin_1,
    this.result_margin_2,
    this.potm_id,
  });

  // MatchesEntity._({
  //   required this.id,
  //   required this.stage,
  //   required this.team1_id,
  //   required this.team2_id,
  //   required this.venue_id,
  //   required this.starts_at,
  //   required this.game_rules_id,
  //   required this.game_rules_type,
  //   required this.toss_winner_id,
  //   required this.toss_choice,
  //   required this.result_type,
  //   required this.result_winner_id,
  //   required this.result_loser_id,
  //   required this.result_margin_1,
  //   required this.result_margin_2,
  //   required this.potm_id,
  // });

  // MatchesEntity.scheduled({
  //   required this.id,
  //   required this.team1_id,
  //   required this.team2_id,
  //   required this.venue_id,
  //   required this.starts_at,
  //   required this.game_rules_id,
  //   required this.game_rules_type,
  // })  : stage = 1,
  //       toss_winner_id = null,
  //       toss_choice = null,
  //       result_type = null,
  //       result_winner_id = null,
  //       result_loser_id = null,
  //       result_margin_1 = null,
  //       result_margin_2 = null,
  //       potm_id = null;
  //
  // MatchesEntity.initialized({
  //   required this.id,
  //   required this.team1_id,
  //   required this.team2_id,
  //   required this.venue_id,
  //   required this.starts_at,
  //   required this.game_rules_id,
  //   required this.game_rules_type,
  //   required this.toss_winner_id,
  //   required this.toss_choice,
  // })  : stage = 2,
  //       result_type = null,
  //       result_winner_id = null,
  //       result_loser_id = null,
  //       result_margin_1 = null,
  //       result_margin_2 = null,
  //       potm_id = null;
  //
  // MatchesEntity.ongoing({
  //   required this.id,
  //   required this.team1_id,
  //   required this.team2_id,
  //   required this.venue_id,
  //   required this.starts_at,
  //   required this.game_rules_id,
  //   required this.game_rules_type,
  //   required this.toss_winner_id,
  //   required this.toss_choice,
  // })  : stage = 3,
  //       result_type = null,
  //       result_winner_id = null,
  //       result_loser_id = null,
  //       result_margin_1 = null,
  //       result_margin_2 = null,
  //       potm_id = null;
  //
  // MatchesEntity.completed({
  //   required this.id,
  //   required this.team1_id,
  //   required this.team2_id,
  //   required this.venue_id,
  //   required this.starts_at,
  //   required this.game_rules_id,
  //   required this.game_rules_type,
  //   required this.toss_winner_id,
  //   required this.toss_choice,
  //   required this.result_type,
  //   required this.result_winner_id,
  //   required this.result_loser_id,
  //   required this.result_margin_1,
  //   required this.result_margin_2,
  //   required this.potm_id,
  // }) : stage = 4;

  MatchesEntity.deserialize(Map<String, Object?> map)
      : this(
          id: map["id"] as String,
          stage: map["stage"] as int,
          team1_id: map["team1_id"] as String,
          team2_id: map["team2_id"] as String,
          venue_id: map["venue_id"] as String,
          starts_at: map["starts_at"] as DateTime,
          game_rules_id: map["game_rules_id"] as int,
          game_rules_type: map["game_rules_type"] as int,
          toss_winner_id: map["toss_winner_id"] as String?,
          toss_choice: map["toss_choice"] as int?,
          result_type: map["result_type"] as int?,
          result_winner_id: map["result_winner_id"] as String?,
          result_loser_id: map["result_loser_id"] as String?,
          result_margin_1: map["result_margin_1"] as int?,
          result_margin_2: map["result_margin_2"] as int?,
          potm_id: map["potm_id"] as String,
        );

  @override
  Map<String, Object?> serialize() => {
        "id": id,
        "stage": stage,
        "team1_id": team1_id,
        "team2_id": team2_id,
        "venue_id": venue_id,
        "starts_at": starts_at,
        "game_rules_id": game_rules_id,
        "game_rules_type": game_rules_type,
        "toss_winner_id": toss_winner_id,
        "toss_choice_id": toss_choice,
        "result_type": result_type,
        "result_winner_id": result_winner_id,
        "result_loser_id": result_loser_id,
        "result_margin_1": result_margin_1,
        "result_margin_2": result_margin_2,
        "potm_id": potm_id,
      };

  @override
  List get primary_key => [id];
}

class MatchesTable extends ICrud<MatchesEntity> {
  @override
  Future<MatchesEntity?> read(String id) async {
    final raw = await _sql
        .query(table: Views.matchesExpanded, where: "id = ?", whereArgs: [id]);
    final map = raw.singleOrNull;
    final result = MatchesEntity.deserialize(map);
    return result;
  }

  @override
  Future<Iterable<MatchesEntity>> readAll() async {
    final raw = await _sql.query(table: Tables.matches);
    final result = raw.map((m) => MatchesEntity.deserialize(m));
    return result;
  }

  @override
  Future<void> update(MatchesEntity object) async {
    await _sql.update(
        table: Tables.matches,
        values: object.serialize(),
        where: "id = ?",
        whereArgs: [object.id]);
  }

  SQLDBHandler get _sql => SQLDBHandler.instance;

  @override
  MatchesEntity deserialize(Map<String, Object?> map) =>
      MatchesEntity.deserialize(map);

  @override
  String get table => Tables.matches;
}
