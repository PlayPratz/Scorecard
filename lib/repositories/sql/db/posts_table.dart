import 'package:scorecard/repositories/sql/db/sql_interface.dart';
import 'package:scorecard/repositories/sql/keys.dart';

class PostsEntity implements IEntity {
  // Common
  final int? id;
  final String match_id;
  final int innings_id;
  final int innings_number;
  final int? day_number;
  final int? session_number;
  final int index_over;
  final int index_ball;
  final DateTime timestamp;
  final int type;
  final String? bowler_id;
  final String? batter_id;
  final bool is_counted_for_bowler;
  final bool is_counted_for_batter;
  final String? comment;

  // NextBatter/NextBowler
  final String? previous_id;

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
  final String? wicket_batter_id;
  final String? wicket_fielder_id;

  PostsEntity._({
    this.id,
    required this.match_id,
    required this.innings_id,
    required this.innings_number,
    required this.day_number,
    required this.session_number,
    required this.index_over,
    required this.index_ball,
    required this.timestamp,
    required this.type,
    required this.comment,
    required this.bowler_id,
    required this.batter_id,
    required this.previous_id,
    required this.total_runs,
    required this.bowler_runs,
    required this.batter_runs,
    required this.is_boundary,
    required this.extras_no_balls,
    required this.extras_wides,
    required this.extras_byes,
    required this.extras_leg_byes,
    required this.extras_penalties,
    required this.is_counted_for_bowler,
    required this.is_counted_for_batter,
    required this.wicket_type,
    required this.wicket_batter_id,
    required this.wicket_fielder_id,
  });

  PostsEntity.ball({
    required this.id,
    required this.match_id,
    required this.innings_id,
    required this.innings_number,
    required this.day_number,
    required this.session_number,
    required this.index_over,
    required this.index_ball,
    required this.timestamp,
    required this.type,
    required this.comment,
    // Specific
    required this.bowler_id,
    required this.batter_id,
    required this.total_runs,
    required this.bowler_runs,
    required this.batter_runs,
    required this.is_boundary,
    required this.extras_no_balls,
    required this.extras_wides,
    required this.extras_byes,
    required this.extras_leg_byes,
    required this.extras_penalties,
    required this.is_counted_for_bowler,
    required this.is_counted_for_batter,
    required this.wicket_type,
    required this.wicket_batter_id,
    required this.wicket_fielder_id,
    // null
    this.previous_id,
  });

  PostsEntity.bowlerRetire({
    required this.id,
    required this.match_id,
    required this.innings_id,
    required this.innings_number,
    required this.day_number,
    required this.session_number,
    required this.index_over,
    required this.index_ball,
    required this.timestamp,
    required this.type,
    required this.is_counted_for_bowler,
    required this.is_counted_for_batter,
    required this.comment,
    // Specific
    required this.bowler_id,
    // null
    this.batter_id,
    this.batter_runs,
    this.bowler_runs,
    this.total_runs,
    this.is_boundary,
    this.wicket_type,
    this.wicket_batter_id,
    this.wicket_fielder_id,
    this.previous_id,
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
    required this.innings_number,
    required this.day_number,
    required this.session_number,
    required this.index_over,
    required this.index_ball,
    required this.timestamp,
    required this.type,
    required this.is_counted_for_bowler,
    required this.is_counted_for_batter,
    required this.comment,
    // Specific
    required this.bowler_id, // next bowler
    required this.previous_id, // previous bowler
    // null
    this.batter_id,
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
    required this.innings_number,
    required this.day_number,
    required this.session_number,
    required this.index_over,
    required this.index_ball,
    required this.timestamp,
    required this.type,
    required this.is_counted_for_bowler,
    required this.is_counted_for_batter,
    required this.comment,
    // Specific
    required this.wicket_type, // retire
    required this.wicket_batter_id,
    // null
    this.batter_id,
    this.bowler_id,
    this.batter_runs,
    this.bowler_runs,
    this.total_runs,
    this.is_boundary,
    this.extras_no_balls,
    this.extras_wides,
    this.extras_byes,
    this.extras_leg_byes,
    this.extras_penalties,
    this.previous_id,
    this.wicket_fielder_id,
  });

  PostsEntity.nextBatter({
    required this.id,
    required this.match_id,
    required this.innings_id,
    required this.innings_number,
    required this.day_number,
    required this.session_number,
    required this.index_over,
    required this.index_ball,
    required this.timestamp,
    required this.type,
    required this.is_counted_for_bowler,
    required this.is_counted_for_batter,
    required this.comment,
    // Specific
    required this.batter_id, // next
    required this.previous_id, // previous
    // null
    this.bowler_id,
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
    required this.innings_number,
    required this.day_number,
    required this.session_number,
    required this.index_over,
    required this.index_ball,
    required this.timestamp,
    required this.type,
    required this.is_counted_for_bowler,
    required this.is_counted_for_batter,
    required this.comment,
    // Specific
    required this.wicket_type, // wicket type
    required this.wicket_batter_id,
    required this.wicket_fielder_id,
    // null
    this.bowler_id,
    this.batter_id,
    this.batter_runs,
    this.bowler_runs,
    this.total_runs,
    this.is_boundary,
    this.extras_no_balls,
    this.extras_wides,
    this.extras_byes,
    this.extras_leg_byes,
    this.extras_penalties,
    this.previous_id,
  });

  PostsEntity.penalty({
    required this.id,
    required this.match_id,
    required this.innings_id,
    required this.innings_number,
    required this.day_number,
    required this.session_number,
    required this.index_over,
    required this.index_ball,
    required this.timestamp,
    required this.type,
    required this.is_counted_for_bowler,
    required this.is_counted_for_batter,
    required this.comment,
    // Specific
    required this.extras_penalties,
    required this.total_runs,
    // null
    this.bowler_id,
    this.batter_id,
    this.batter_runs,
    this.bowler_runs,
    this.is_boundary,
    this.extras_no_balls,
    this.extras_wides,
    this.extras_byes,
    this.extras_leg_byes,
    this.previous_id,
    this.wicket_type,
    this.wicket_batter_id,
    this.wicket_fielder_id,
  });

  PostsEntity.deserialize(Map<String, Object?> map)
      : this._(
          id: map["id"] as int,
          innings_id: map["innings_id"] as int,
          match_id: map["match_id"] as String,
          innings_number: map["innings_number"] as int,
          day_number: map["day_number"] as int?,
          session_number: map["session_number"] as int?,
          index_over: map["index_over"] as int,
          index_ball: map["index_ball"] as int,
          timestamp: readDateTime(map["timestamp"] as int)!,
          type: map["type"] as int,
          bowler_id: map["bowler_id"] as String?,
          batter_id: map["batter_id"] as String?,
          previous_id: map["previous_id"] as String?,
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
          wicket_batter_id: map["wicket_batter_id"] as String?,
          wicket_fielder_id: map["wicket_fielder_id"] as String?,
          is_counted_for_bowler: readBool(map["is_counted_for_bowler"] as int)!,
          is_counted_for_batter: readBool(map["is_counted_for_batter"] as int)!,
          comment: map["comment"] as String?,
        );

  @override
  Map<String, Object?> serialize() => {
        "id": id,
        "innings_id": innings_id,
        "match_id": match_id,
        "innings_number": innings_number,
        "day_number": day_number,
        "session_number": session_number,
        "index_over": index_over,
        "index_ball": index_ball,
        "timestamp": timestamp.microsecondsSinceEpoch,
        "type": type,
        "bowler_id": bowler_id,
        "batter_id": batter_id,
        "previous_id": previous_id,
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
        "is_counted_for_bowler": is_counted_for_bowler,
        "is_counted_for_batter": is_counted_for_batter,
        "comment": comment,
      };

  @override
  int? get primary_key => id;
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
    final postsEntities = result.map((e) => PostsEntity.deserialize(e));
    return postsEntities;
  }

  Future<Iterable<PostsEntity>> selectForInnings(int id) async {
    final result = await sql.query(
      table: table,
      where: "innings_id = ?",
      whereArgs: [id],
    );
    final postsEntities = result.map((e) => PostsEntity.deserialize(e));
    return postsEntities;
  }

  Future<void> deleteById(int id) async {
    await sql.delete(table: table, where: where, whereArgs: [id]);
  }
}
