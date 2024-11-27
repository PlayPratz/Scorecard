import 'package:scorecard/repositories/sql/db/sql_crud.dart';
import 'package:scorecard/repositories/sql/keys.dart';

class PostsEntity implements IEntity {
  final int? id;
  final String match_id;
  final int innings_number;
  final int? day_number;
  final int? session_number;
  final int index_over;
  final int index_ball;
  final DateTime? timestamp;
  final int type;
  final String? bowler_id;
  final String? batter_id;
  final int? runs_scored;
  final int? wicket_id;
  final int? bowling_extra_type;
  final int? bowling_extra_penalty;
  final int? batting_extra_type;
  final int? batting_extra_runs;
  final String? previous_player_id;
  final String? comment;

  // PostsEntity._({
  //   required this.id,
  //   required this.match_id,
  //   required this.innings_number,
  //   required this.day_number,
  //   required this.session_number,
  //   required this.index_over,
  //   required this.index_ball,
  //   required this.timestamp,
  //   required this.type,
  //   required this.bowler_id,
  //   required this.batter_id,
  //   required this.runs_scored,
  //   required this.wicket_id,
  //   required this.bowling_extra_type,
  //   required this.bowling_extra_penalty,
  //   required this.batting_extra_type,
  //   required this.batting_extra_runs,
  //   required this.previous_player_id,
  //   required this.comment,
  // });

  PostsEntity({
    this.id,
    required this.match_id,
    required this.innings_number,
    this.day_number,
    this.session_number,
    required this.index_over,
    required this.index_ball,
    this.timestamp,
    required this.type,
    this.bowler_id,
    this.batter_id,
    this.runs_scored,
    this.wicket_id,
    this.bowling_extra_type,
    this.bowling_extra_penalty,
    this.batting_extra_type,
    this.batting_extra_runs,
    this.previous_player_id,
    this.comment,
  });

  // PostsEntity._({
  //   this.id,
  //   required this.match_id,
  //   required this.innings_number,
  //   this.day_number,
  //   this.session_number,
  //   required this.index_over,
  //   required this.index_ball,
  //   this.timestamp,
  //   required this.type,
  //   this.bowler_id,
  //   this.batter_id,
  //   this.runs_scored,
  //   this.wicket_id,
  //   this.bowling_extra_type,
  //   this.bowling_extra_penalty,
  //   this.batting_extra_type,
  //   this.batting_extra_runs,
  //   this.previous_player_id,
  //   this.comment,
  // });

//   PostEntity.ball({
//     this.id,
//     required this.match_id,
//     required this.innings_number,
//     required this.day_number,
//     required this.session_number,
//     required this.index_over,
//     required this.index_ball,
//     this.timestamp,
//     required this.bowler_id,
//     required this.batter_id,
// })

  PostsEntity.deserialize(Map<String, Object?> map)
      : this(
          id: map["id"] as int,
          match_id: map["match_id"] as String,
          innings_number: map["innings_number"] as int,
          day_number: map["day_number"] as int?,
          session_number: map["session_number"] as int?,
          index_over: map["index_over"] as int,
          index_ball: map["index_ball"] as int,
          timestamp: map["timestamp"] as DateTime,
          type: map["type"] as int,
          bowler_id: map["bowler_id"] as String?,
          batter_id: map["batter_id"] as String?,
          runs_scored: map["runs_scored"] as int?,
          wicket_id: map["wicket_id"] as int?,
          bowling_extra_type: map["bowling_extra_type"] as int?,
          bowling_extra_penalty: map["bowling_extra_penalty"] as int?,
          batting_extra_type: map["batting_extra_type"] as int?,
          batting_extra_runs: map["batting_extra_runs"] as int?,
          previous_player_id: map["previous_player_id"] as String?,
          comment: map["comment"] as String?,
        );

  @override
  Map<String, Object?> serialize() => {
        "id": id,
        "match_id": match_id,
        "innings_number": innings_number,
        "day_number": day_number,
        "session_number": session_number,
        "index_over": index_over,
        "index_ball": index_ball,
        "timestamp": timestamp,
        "type": type,
        "bowler_id": bowler_id,
        "batter_id": batter_id,
        "runs_scored": runs_scored,
        "wicket_id": wicket_id,
        "bowling_extra_type": bowling_extra_type,
        "bowling_extra_penalty": bowling_extra_penalty,
        "batting_extra_type": batting_extra_type,
        "batting_extra_runs": batting_extra_runs,
        "previous_player_id": previous_player_id,
        "comment": comment,
      };

  @override
  List get primary_key => [id];
}

class PostsTable extends ICrud<PostsEntity> {
  @override
  String get table => Tables.posts;

  @override
  PostsEntity deserialize(Map<String, Object?> map) =>
      PostsEntity.deserialize(map);
}
