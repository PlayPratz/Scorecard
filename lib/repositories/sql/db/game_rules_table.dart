import 'package:scorecard/repositories/sql/db/sql_crud.dart';
import 'package:scorecard/repositories/sql/keys.dart';

class GameRulesEntity implements IEntity {
  // Common
  final int? id;
  final int type;
  final int balls_per_over;
  final int no_ball_penalty;
  final int wide_penalty;
  final bool only_single_batter;
  final bool last_wicket_batter;

  // Unlimited Overs (Type 0)
  final int? days_of_play;
  final int? sessions_per_day;
  final int? innings_per_side;

  // Limited Overs (Type 1)
  final int? overs_per_innings;
  final int? overs_per_bowler;

  GameRulesEntity({
    required this.id,
    required this.type,
    required this.balls_per_over,
    required this.no_ball_penalty,
    required this.wide_penalty,
    required this.only_single_batter,
    required this.last_wicket_batter,
    this.days_of_play,
    this.sessions_per_day,
    this.innings_per_side,
    this.overs_per_innings,
    this.overs_per_bowler,
  });

  // GameRulesEntity._({
  //   required this.id,
  //   required this.type,
  //   required this.balls_per_over,
  //   required this.no_ball_penalty,
  //   required this.wide_penalty,
  //   required this.only_single_batter,
  //   required this.allow_last_man,
  //   required this.days_of_play,
  //   required this.sessions_per_day,
  //   required this.innings_per_side,
  //   required this.overs_per_innings,
  //   required this.overs_per_bowler,
  // });

  // GameRulesEntity.limitedOvers({
  //   required this.id,
  //   required this.balls_per_over,
  //   required this.no_ball_penalty,
  //   required this.wide_penalty,
  //   required this.only_single_batter,
  //   required this.allow_last_man,
  //   required this.overs_per_innings,
  //   required this.overs_per_bowler,
  // })  : type = 1,
  //       innings_per_side = null,
  //       sessions_per_day = null,
  //       days_of_play = null;
  //
  // GameRulesEntity.unlimitedOvers({
  //   required this.id,
  //   required this.balls_per_over,
  //   required this.no_ball_penalty,
  //   required this.wide_penalty,
  //   required this.only_single_batter,
  //   required this.allow_last_man,
  //   required this.days_of_play,
  //   required this.sessions_per_day,
  //   required this.innings_per_side,
  // })  : type = 0,
  //       overs_per_innings = null,
  //       overs_per_bowler = null;

  GameRulesEntity.deserialize(Map<String, Object?> map)
      : this(
          id: map["id"] as int,
          type: map["type"] as int,
          balls_per_over: map["balls_per_over"] as int,
          no_ball_penalty: map["no_ball_penalty"] as int,
          wide_penalty: map["wide_penalty"] as int,
          only_single_batter: readBool(map["only_single_batter"] as int)!,
          last_wicket_batter: readBool(map["last_wicket_batter"] as int)!,
          days_of_play: map["days_of_play"] as int?,
          sessions_per_day: map["sessions_per_day"] as int?,
          innings_per_side: map["innings_per_side"] as int?,
          overs_per_innings: map["overs_per_innings"] as int?,
          overs_per_bowler: map["overs_per_bowler"] as int?,
        );

  @override
  Map<String, Object?> serialize() => {
        "id": id,
        "type": type,
        "balls_per_over": balls_per_over,
        "no_ball_penalty": no_ball_penalty,
        "wide_penalty": wide_penalty,
        "only_single_batter": only_single_batter ? 1 : 0,
        "last_wicket_batter": last_wicket_batter ? 1 : 0,
        "days_of_play": days_of_play,
        "sessions_per_day": sessions_per_day,
        "innings_per_side": innings_per_side,
        "overs_per_innings": overs_per_innings,
        "overs_per_bowler": overs_per_bowler,
      };

  @override
  List get primary_key => [id];
}

// abstract class GameRulesEntity implements IEntity {
//   // Common
//   final int id;
//   final int balls_per_over;
//   final int no_ball_penalty;
//   final int wide_penalty;
//   final bool only_single_batter;
//   final bool allow_last_man;
//
//   GameRulesEntity(
//       {required this.id,
//       required this.balls_per_over,
//       required this.no_ball_penalty,
//       required this.wide_penalty,
//       required this.only_single_batter,
//       required this.allow_last_man});
//
//   int get type;
//
//   @override
//   Map<String, Object?> serialize() => {
//     "type": type,
//     "balls_per_over": balls_per_over,
//     "no_ball_penalty": no_ball_penalty,
//     "wide_penalty": wide_penalty,
//     "only_single_batter": only_single_batter,
//     "allow_last_man": allow_last_man,
//   };
// }
//
// class UnlimitedOversGameRulesEntity extends GameRulesEntity {
//   final int? days_of_play;
//   final int? sessions_per_day;
//   final int? innings_per_side;
//
//   UnlimitedOversGameRulesEntity(
//       {required super.id,
//       required super.balls_per_over,
//       required super.no_ball_penalty,
//       required super.wide_penalty,
//       required super.only_single_batter,
//       required super.allow_last_man,
//       required this.days_of_play,
//       required this.sessions_per_day,
//       required this.innings_per_side});
//
//   @override
//   int get type => 0;
//
//   @override
//   Map<String, Object?> serialize() {
//     // TODO: implement serialize
//     throw UnimplementedError();
//   }
// }
//
// class LimitedOversGameRulesEntity extends GameRulesEntity {
//   final int overs_per_innings;
//   final int overs_per_bowler;
//
//   LimitedOversGameRulesEntity(
//       {required super.id,
//       required super.balls_per_over,
//       required super.no_ball_penalty,
//       required super.wide_penalty,
//       required super.only_single_batter,
//       required super.allow_last_man,
//       required this.overs_per_innings,
//       required this.overs_per_bowler});
//
//   @override
//   int get type => 1;
//
//   @override
//   Map<String, Object?> serialize() {
//     final map = super.serialize();
//     map.addAll({
//
//     });
//   }
//
// }

class GameRulesTable extends ICrud<GameRulesEntity> {
  @override
  String get table => Tables.gameRules;

  @override
  GameRulesEntity deserialize(Map<String, Object?> map) =>
      GameRulesEntity.deserialize(map);
}
