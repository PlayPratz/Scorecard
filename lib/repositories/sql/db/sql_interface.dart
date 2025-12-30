import 'package:scorecard/handlers/sql_db_handler.dart';

abstract class IEntity {
  int get id;

  IEntity.deserialize(Map<String, Object?> map);

  /// Convert the object into a map of column names to values
  /// that can be stored in a database table
  Map<String, Object?> serialize();
  // factory deserialize(Map<String, Object> map)
}

bool? readBool(Object? object) {
  if (object == null) return null;
  return object as int != 0;
}

int? parseBool(bool? value) {
  if (value == null) return null;
  return value ? 1 : 0;
}

DateTime? readDateTime(int? micros) {
  if (micros == null) return null;
  return DateTime.fromMicrosecondsSinceEpoch(micros);
}

abstract class ISQL<T extends IEntity> {
  // Future<void> initialize();

  String get table;

  T deserialize(Map<String, Object?> map);

  /// Creates an object in the database;
  ///
  /// Call this method to INSERT a new entry into the database. To update an
  /// existing instance, use [update] instead.
  ///
  /// throws [StateError] if an object of the same ID exists.
  Future<int> insert(T object) async {
    final id = await sql.insert(table: table, values: object.serialize());

    if (id <= 0) {
      throw StateError("Unable to insert object into DB! ($object)");
    }

    return id;
  }

  /// Retrieves an object from the database of the given [id]. Returns [null]
  /// if no such objet is found.
  ///
  /// Call this function to SELECT an object of the given [id] from the database.
  /// It is assumed that the given [id] represents the Primary Key in the
  /// database.
  Future<T?> select(int id) async {
    final raw = await sql.query(table: table, where: "id = ?", whereArgs: [id]);
    final result = deserialize(raw.singleOrNull);
    return result;
  }

  Future<Iterable<T>> selectMultiple(Set<int> ids) async {
    if (ids.isEmpty) {
      throw UnsupportedError(
          "Attempted to select multiple without providing ID");
    }

    final where = "id in (${List.filled(ids.length, '?').join(',')})";
    final whereArgs = ids.toList();

    final raw =
        await sql.query(table: table, where: where, whereArgs: whereArgs);
    final result = raw.map<T>((r) => deserialize(r));
    return result;
  }

  /// Searches for an object based on the supplied [query].
  ///
  /// The implementation of this function will depend heavily on the class [T].
  /// In a broader sense, a name search can be expected.
  // Future<Iterable<T>> search(String query);

  /// Retrieves all objects from the database.
  ///
  /// TODO implement pagination.
  Future<Iterable<T>> selectAll() async {
    final raw = await sql.query(table: table);
    final result = raw.map((m) => deserialize(m));
    return result;
  }

  /// Updates an object in the database;
  ///
  /// Call this function to UPDATE an object in the database.
  ///
  /// throws [StateError] if an object with the same ID does not exist.
  Future<void> update(T object) async {
    final rowsAffected = await sql.update(
      table: table,
      values: object.serialize(),
      where: "id = ?",
      whereArgs: [object.id],
    );

    if (rowsAffected == 0) {
      throw StateError(
          "Attempted to update record which does not exist! (id: ${object.id}");
    }
  }

  /// Deletes an object of the given [id] from the database;
  ///
  /// Call this function to DELETE an object from the database.
  ///
  /// throws [StateError] if an object of the given [id] does not exist.
  Future<void> delete(int id) async {
    final rowsAffected =
        await sql.delete(table: table, where: "id = ?", whereArgs: [id]);

    if (rowsAffected == 0) {
      throw StateError(
          "Attempted to delete record which does not exist! (id: $id)");
    }
  }

  SQLDBHandler get sql => SQLDBHandler.instance;
}
