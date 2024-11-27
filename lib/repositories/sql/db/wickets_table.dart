import 'package:scorecard/repositories/sql/db/sql_crud.dart';
import 'package:scorecard/repositories/sql/keys.dart';

class WicketEntity implements IEntity {
  final int? id;
  final String match_id;
  final int type;
  final String batter_id;
  final String? bowler_id;
  final String? fielder_id;

  WicketEntity({
    required this.id,
    required this.match_id,
    required this.type,
    required this.batter_id,
    required this.bowler_id,
    required this.fielder_id,
  });

  WicketEntity.deserialize(Map<String, Object?> map)
      : this(
          id: map["id"] as int?,
          match_id: map["match_id"] as String,
          type: map["type"] as int,
          batter_id: map["batter_id"] as String,
          bowler_id: map["bowler_id"] as String?,
          fielder_id: map["fielder_id"] as String?,
        );

  @override
  Map<String, Object?> serialize() => {
        "id": id,
        "match_id": match_id,
        "type": type,
        "batter_id": batter_id,
        "bowler_id": bowler_id,
        "fielder_id": fielder_id,
      };

  @override
  List get primary_key => [id];
}

class WicketsTable extends ICrud<WicketEntity> {
  @override
  String get table => Tables.wickets;

  @override
  WicketEntity deserialize(Map<String, Object?> map) =>
      WicketEntity.deserialize(map);
}
