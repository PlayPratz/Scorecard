import 'package:scorecard/repositories/sql/db/sql_crud.dart';
import 'package:scorecard/repositories/sql/keys.dart';

class InningsEntity implements IEntity {
  final String match_id;
  final int innings_number;
  final int type;
  final String batting_team_id;
  final String bowling_team_id;
  final bool is_forfeited;
  final bool is_declared;
  final String? batter1_id;
  final String? batter2_id;
  //final String? striker_id; // TODO is this needed?
  final String? bowler_id;
  final int? target_runs;

  InningsEntity({
    required this.match_id,
    required this.innings_number,
    required this.type,
    required this.batting_team_id,
    required this.bowling_team_id,
    required this.is_forfeited,
    required this.is_declared,
    required this.batter1_id,
    required this.batter2_id,
    required this.bowler_id,
    required this.target_runs,
  });

  InningsEntity.deserialize(Map<String, Object?> map)
      : this(
          match_id: map["match_id"] as String,
          innings_number: map["innings_number"] as int,
          type: map["type"] as int,
          batting_team_id: map["batting_team_id"] as String,
          bowling_team_id: map["bowling_team_id"] as String,
          is_forfeited: map["is_forfeited"] as bool,
          is_declared: map["is_declared"] as bool,
          batter1_id: map["batter1_id"] as String?,
          batter2_id: map["batter2_id"] as String?,
          // striker_id: map["striker_id"] as String?,
          bowler_id: map["bowler_id"] as String?,
          target_runs: map["target_runs"] as int?,
        );

  @override
  Map<String, Object?> serialize() => {
        "match_id": match_id,
        "innings_number": innings_number,
        "type": type,
        "batting_team_id": batting_team_id,
        "bowling_team_id": bowling_team_id,
        "is_forfeited": is_forfeited,
        "is_declared": is_declared,
        "batter1_id": batter1_id,
        "batter2_is": batter2_id,
        // "striker_id": striker_id,
        "bowler_id": bowler_id,
        "target_runs": target_runs,
      };

  @override
  List get primary_key => [match_id, innings_number];
}

class InningsTable extends ICrud<InningsEntity> {
  @override
  InningsEntity deserialize(Map<String, Object?> map) {
    // TODO: implement deserialize
    throw UnimplementedError();
  }

  @override
  String get table => Tables.innings;
}
