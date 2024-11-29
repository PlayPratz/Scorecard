import 'package:scorecard/repositories/sql/handlers/sql_db_handler.dart';

abstract class IEntity {
  List<dynamic> get primary_key;

  IEntity.deserialize(Map<String, Object?> map);

  /// Convert the object into a map of column names to values
  /// that can be stored in a database table
  Map<String, Object?> serialize();
  // factory deserialize(Map<String, Object> map)
}

abstract class ICrud<T extends IEntity> {
  // Future<void> initialize();

  String get table;

  T deserialize(Map<String, Object?> map);

  /// Creates an object in the database;
  ///
  /// Call this method to INSERT a new entry into the database. To update an
  /// existing instance, use [update] instead.
  ///
  /// throws [StateError] if an object of the same ID exists.
  Future<int> create(T object) async {
    final id = await sql.insert(table: table, values: object.serialize());
    return id;
  }

  /// Retrieves an object from the database of the given [id]. Returns [Null]
  /// if no such objet is found.
  ///
  /// Call this function to SELECT an object of the given [id] from the database.
  /// It is assumed that the given [id] represents the Primary Key in the
  /// database.
  ///
  Future<T?> read(String id) async {
    if (where != "id = ?") {
      throw UnimplementedError(
          "In case of custom 'where', child Must override read()");
    }
    final raw = await sql.query(table: table, where: where, whereArgs: [id]);
    final result = deserialize(raw.singleOrNull);
    return result;
  }

  /// Searches for an object based on the supplied [query].
  ///
  /// The implementation of this function will depend heavily on the class [T].
  /// In a broader sense, a name search can be expected.
  // Future<Iterable<T>> search(String query);

  /// Retrieves all objects from the database.
  ///
  /// As can be guessed, this is an expensive operation and should be used
  /// sparingly. TODO implement pagination.
  Future<Iterable<T>> readAll() async {
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
    await sql.update(
      table: table,
      values: object.serialize(),
      where: where,
      whereArgs: object.primary_key,
    );
  }

  String get where => "id = ?";

  /// Deletes an object of the given [id] from the database;
  ///
  /// Call this function to DELETE an object from the database.
  ///
  /// throws [StateError] if an object of the given [id] does not exist.
  // Future<void> delete(String id);

  SQLDBHandler get sql => SQLDBHandler.instance;
}

// abstract class ITable<T extends IEntity> {
//   // Future<void> initialize();
//
//   /// Creates an object in the database;
//   ///
//   /// Call this method to INSERT a new entry into the database. To update an
//   /// existing instance, use [update] instead.
//   ///
//   /// throws [StateError] if an object of the same ID exists.
//   Future<void> create(T object);
//
//   /// Retrieves an object from the database of the given [id]. Returns [Null]
//   /// if no such objet is found.
//   ///
//   /// Call this function to SELECT an object of the given [id] from the database.
//   /// It is assumed that the given [id] represents the Primary Key in the
//   /// database.
//   ///
//   Future<T?> read(String id);
//
//   /// Searches for an object based on the supplied [query].
//   ///
//   /// The implementation of this function will depend heavily on the class [T].
//   /// In a broader sense, a name search can be expected.
//   // Future<Iterable<T>> search(String query);
//
//   /// Retrieves all objects from the database.
//   ///
//   /// As can be guessed, this is an expensive operation and should be used
//   /// sparingly. TODO implement pagination.
//   Future<Iterable<T>> readAll();
//
//   /// Updates an object in the database;
//   ///
//   /// Call this function to UPDATE an object in the database.
//   ///
//   /// throws [StateError] if an object with the same ID does not exist.
//   Future<void> update(T object);
//
//   /// Deletes an object of the given [id] from the database;
//   ///
//   /// Call this function to DELETE an object from the database.
//   ///
//   /// throws [StateError] if an object of the given [id] does not exist.
//   // Future<void> delete(String id);
// }
//
// abstract class IEntity {
//   IEntity.deserialize(Map<String, Object?> map);
//
//   /// Convert the object into a map of column names to values
//   /// that can be stored in a database table
//   Map<String, Object?> serialize();
//   // factory deserialize(Map<String, Object> map);
// }
