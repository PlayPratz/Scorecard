import 'package:scorecard/repositories/sql/db/sql_crud.dart';
import 'package:scorecard/repositories/sql/keys.dart';

class TeamsEntity implements IEntity {
  final String id;
  final String name;
  final String short;
  final int color;

  TeamsEntity({
    required this.id,
    required this.name,
    required this.short,
    required this.color,
  });

  TeamsEntity.deserialize(Map<String, Object?> map)
      : this(
          id: map["id"] as String,
          name: map["name"] as String,
          short: map["short"] as String,
          color: map["color"] as int,
        );

  @override
  Map<String, Object?> serialize() => {
        "id": id,
        "name": name,
        "short": short,
        "color": color,
      };

  @override
  List get primary_key => [id];
}

class TeamsTable extends ICrud<TeamsEntity> {
  @override
  String get table => Tables.teams;

  @override
  TeamsEntity deserialize(Map<String, Object?> map) =>
      TeamsEntity.deserialize(map);
}
