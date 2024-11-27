import 'package:scorecard/repositories/sql/db/sql_crud.dart';
import 'package:scorecard/repositories/sql/keys.dart';

class VenueEntity implements IEntity {
  final String id;
  final String name;

  VenueEntity({required this.id, required this.name});

  VenueEntity.deserialize(Map<String, Object?> map)
      : this(
          id: map["id"] as String,
          name: map["name"] as String,
        );

  @override
  Map<String, Object?> serialize() => {
        "id": id,
        "name": name,
      };

  @override
  List get primary_key => [id];
}

class VenuesTable extends ICrud<VenueEntity> {
  @override
  String get table => Tables.venues;

  @override
  VenueEntity deserialize(Map<String, Object?> map) =>
      VenueEntity.deserialize(map);
}
