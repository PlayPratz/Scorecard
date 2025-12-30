import 'package:scorecard/repositories/sql/db/sql_interface.dart';
import 'package:scorecard/repositories/sql/keys.dart';

class PostsEntity implements IEntity {
  // Common
  final int id;
  final String match_id;
  final int innings_id;
  final int innings_type;
  final int innings_number;

  final int? day_number;
  final int? session_number;
  final DateTime timestamp;
  final int over_index;
  final int ball_index;
  final int runs_at;
  final int wickets_at;
  final int type;

  final int? bowler_id;
  final int? batter_id;
  final int? non_striker_id;

  final String? comment;

  // NextBatter/NextBowler
  final int? previous_player_id;

  // Ball specific
  final int? total_runs;
  final int? bowler_runs;
  final int? batter_runs;
  final bool? is_boundary;

  final int? extras_no_balls;
  final int? extras_wides;
  final int? extras_byes;
  final int? extras_leg_byes;
  final int? extras_penalties;

  // Wicket
  final int? wicket_type;
  final int? wicket_batter_id;
  final int? wicket_fielder_id;

  PostsEntity._({
    required this.id,
    required this.match_id,
    required this.innings_id,
    required this.innings_type,
    required this.innings_number,
    required this.day_number,
    required this.session_number,
    required this.timestamp,
    required this.over_index,
    required this.ball_index,
    required this.runs_at,
    required this.wickets_at,
    required this.type,
    required this.comment,
    required this.bowler_id,
    required this.batter_id,
    required this.non_striker_id,
    required this.previous_player_id,
    required this.total_runs,
    required this.bowler_runs,
    required this.batter_runs,
    required this.is_boundary,
    required this.extras_no_balls,
    required this.extras_wides,
    required this.extras_byes,
    required this.extras_leg_byes,
    required this.extras_penalties,
    required this.wicket_type,
    required this.wicket_batter_id,
    required this.wicket_fielder_id,
  });

  PostsEntity.ball({
    required this.id,
    required this.match_id,
    required this.innings_id,
    required this.innings_type,
    required this.innings_number,
    required this.day_number,
    required this.session_number,
    required this.timestamp,
    required this.over_index,
    required this.ball_index,
    required this.runs_at,
    required this.wickets_at,
    required this.type,
    required this.comment,
    // Specific
    required this.bowler_id,
    required this.batter_id,
    required this.non_striker_id,
    required this.total_runs,
    required this.bowler_runs,
    required this.batter_runs,
    required this.is_boundary,
    required this.extras_no_balls,
    required this.extras_wides,
    required this.extras_byes,
    required this.extras_leg_byes,
    required this.extras_penalties,
    required this.wicket_type,
    required this.wicket_batter_id,
    required this.wicket_fielder_id,
    // null
    this.previous_player_id,
  });

  PostsEntity.bowlerRetire({
    required this.id,
    required this.match_id,
    required this.innings_id,
    required this.innings_type,
    required this.innings_number,
    required this.day_number,
    required this.session_number,
    required this.timestamp,
    required this.over_index,
    required this.ball_index,
    required this.runs_at,
    required this.wickets_at,
    required this.type,
    required this.comment,
    // Specific
    required this.bowler_id,
    required this.batter_id,
    required this.non_striker_id,
    // null
    this.batter_runs,
    this.bowler_runs,
    this.total_runs,
    this.is_boundary,
    this.wicket_type,
    this.wicket_batter_id,
    this.wicket_fielder_id,
    this.previous_player_id,
    this.extras_no_balls,
    this.extras_wides,
    this.extras_byes,
    this.extras_leg_byes,
    this.extras_penalties,
  });

  PostsEntity.nextBowler({
    required this.id,
    required this.match_id,
    required this.innings_id,
    required this.innings_type,
    required this.innings_number,
    required this.day_number,
    required this.session_number,
    required this.timestamp,
    required this.over_index,
    required this.ball_index,
    required this.runs_at,
    required this.wickets_at,
    required this.type,
    required this.comment,
    // Specific
    required this.previous_player_id,
    required this.bowler_id,
    required this.batter_id,
    required this.non_striker_id,
    // null
    this.batter_runs,
    this.bowler_runs,
    this.total_runs,
    this.is_boundary,
    this.extras_no_balls,
    this.extras_wides,
    this.extras_byes,
    this.extras_leg_byes,
    this.extras_penalties,
    this.wicket_type,
    this.wicket_batter_id,
    this.wicket_fielder_id,
  });

  PostsEntity.batterRetire({
    required this.id,
    required this.match_id,
    required this.innings_id,
    required this.innings_type,
    required this.innings_number,
    required this.day_number,
    required this.session_number,
    required this.timestamp,
    required this.over_index,
    required this.ball_index,
    required this.runs_at,
    required this.wickets_at,
    required this.type,
    required this.comment,
    // Specific
    required this.bowler_id,
    required this.batter_id,
    required this.non_striker_id,
    required this.wicket_type, // retire
    required this.wicket_batter_id,
    // null
    this.batter_runs,
    this.bowler_runs,
    this.total_runs,
    this.is_boundary,
    this.extras_no_balls,
    this.extras_wides,
    this.extras_byes,
    this.extras_leg_byes,
    this.extras_penalties,
    this.previous_player_id,
    this.wicket_fielder_id,
  });

  PostsEntity.nextBatter({
    required this.id,
    required this.match_id,
    required this.innings_id,
    required this.innings_type,
    required this.innings_number,
    required this.day_number,
    required this.session_number,
    required this.timestamp,
    required this.over_index,
    required this.ball_index,
    required this.runs_at,
    required this.wickets_at,
    required this.type,
    required this.comment,
    // Specific
    required this.previous_player_id, // previous
    required this.batter_id, // next
    required this.bowler_id,
    required this.non_striker_id,
    // null
    this.batter_runs,
    this.bowler_runs,
    this.total_runs,
    this.is_boundary,
    this.extras_no_balls,
    this.extras_wides,
    this.extras_byes,
    this.extras_leg_byes,
    this.extras_penalties,
    this.wicket_type,
    this.wicket_batter_id,
    this.wicket_fielder_id,
  });

  PostsEntity.wicketBeforeDelivery({
    required this.id,
    required this.match_id,
    required this.innings_id,
    required this.innings_type,
    required this.innings_number,
    required this.day_number,
    required this.session_number,
    required this.timestamp,
    required this.over_index,
    required this.ball_index,
    required this.runs_at,
    required this.wickets_at,
    required this.type,
    required this.comment,
    // Specific
    required this.wicket_type, // wicket type
    required this.wicket_batter_id,
    required this.wicket_fielder_id,
    required this.batter_id, // next
    required this.bowler_id,
    required this.non_striker_id,
    // null
    this.batter_runs,
    this.bowler_runs,
    this.total_runs,
    this.is_boundary,
    this.extras_no_balls,
    this.extras_wides,
    this.extras_byes,
    this.extras_leg_byes,
    this.extras_penalties,
    this.previous_player_id,
  });

  PostsEntity.penalty({
    required this.id,
    required this.match_id,
    required this.innings_id,
    required this.innings_type,
    required this.innings_number,
    required this.day_number,
    required this.session_number,
    required this.timestamp,
    required this.over_index,
    required this.ball_index,
    required this.runs_at,
    required this.wickets_at,
    required this.type,
    required this.comment,
    // Specific
    required this.extras_penalties,
    required this.total_runs,
    required this.previous_player_id, // previous
    required this.batter_id, // next
    required this.bowler_id,
    required this.non_striker_id,
    // null
    this.batter_runs,
    this.bowler_runs,
    this.is_boundary,
    this.extras_no_balls,
    this.extras_wides,
    this.extras_byes,
    this.extras_leg_byes,
    this.wicket_type,
    this.wicket_batter_id,
    this.wicket_fielder_id,
  });

  PostsEntity.deserialize(Map<String, Object?> map)
      : this._(
          id: map["id"] as int,
          match_id: map["match_id"] as String,
          innings_id: map["innings_id"] as int,
          innings_type: map["innings_type"] as int,
          innings_number: map["innings_number"] as int,
          day_number: map["day_number"] as int?,
          session_number: map["session_number"] as int?,
          timestamp: readDateTime(map["timestamp"] as int)!,
          over_index: map["over_index"] as int,
          ball_index: map["ball_index"] as int,
          runs_at: map["runs_at"] as int,
          wickets_at: map["wickets_at"] as int,
          type: map["type"] as int,
          bowler_id: map["bowler_id"] as int?,
          batter_id: map["batter_id"] as int?,
          non_striker_id: map["non_striker_id"] as int?,
          previous_player_id: map["previous_player_id"] as int?,
          batter_runs: map["batter_runs"] as int?,
          bowler_runs: map["bowler_runs"] as int?,
          total_runs: map["total_runs"] as int?,
          is_boundary: readBool(map["is_boundary"]),
          extras_no_balls: map["extras_no_balls"] as int,
          extras_wides: map["extras_wides"] as int,
          extras_byes: map["extras_byes"] as int,
          extras_leg_byes: map["extras_leg_byes"] as int,
          extras_penalties: map["extras_penalties"] as int,
          wicket_type: map["wicket_type"] as int?,
          wicket_batter_id: map["wicket_batter_id"] as int?,
          wicket_fielder_id: map["wicket_fielder_id"] as int?,
          comment: map["comment"] as String?,
        );

  @override
  Map<String, Object?> serialize() => {
        "id": id,
        "match_id": match_id,
        "innings_id": innings_id,
        "innings_type": innings_type,
        "innings_number": innings_number,
        "day_number": day_number,
        "session_number": session_number,
        "over_index": over_index,
        "ball_index": ball_index,
        "timestamp": timestamp.microsecondsSinceEpoch,
        "type": type,
        "bowler_id": bowler_id,
        "batter_id": batter_id,
        "non_striker_id": non_striker_id,
        "previous_player_id": previous_player_id,
        "total_runs": total_runs,
        "batter_runs": batter_runs,
        "bowler_runs": bowler_runs,
        "is_boundary": parseBool(is_boundary),
        "extras_no_balls": extras_no_balls,
        "extras_wides": extras_wides,
        "extras_byes": extras_byes,
        "extras_leg_byes": extras_leg_byes,
        "extras_penalties": extras_penalties,
        "wicket_type": wicket_type,
        "wicket_batter_id": wicket_batter_id,
        "wicket_fielder_id": wicket_fielder_id,
        "comment": comment,
      };
}

class PostsTable extends ISQL<PostsEntity> {
  @override
  String get table => Tables.posts;

  @override
  PostsEntity deserialize(Map<String, Object?> map) =>
      PostsEntity.deserialize(map);

  Future<Iterable<PostsEntity>> selectForMatch(String matchId) async {
    final result = await sql
        .query(table: table, where: "match_id = ?", whereArgs: [matchId]);
    final entities = result.map((e) => PostsEntity.deserialize(e));
    return entities;
  }

  Future<Iterable<PostsEntity>> selectForInnings(int id) async {
    final result = await sql.query(
      table: table,
      where: "innings_id = ?",
      whereArgs: [id],
    );
    final entities = result.map((e) => PostsEntity.deserialize(e));
    return entities;
  }
}
