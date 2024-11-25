import 'package:path/path.dart';
import 'package:scorecard/modules/sql/keys.dart';
import 'package:sqflite/sqflite.dart';

class SQLDBHandler {
  late final Database _db;

  SQLDBHandler._();
  static final instance = SQLDBHandler._();

  Future<void> initialize() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), "cricket_scorecard.db"),
      onCreate: (db, version) {
        return db.execute(
            "CREATE TABLE ? (id INTEGER PRIMARY KEY, name TEXT, full_name TEXT)",
            [Tables.players]);
      },
      version: 1,
    );
  }

  Future<void> insert({
    required String table,
    required Map<String, dynamic> values,
  }) async {
    await _db.insert(table, values);
  }

  Future<Iterable<dynamic>> query({
    required String table,
    List<String> columns = const [],
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final result = await _db.query(table,
        columns: columns, where: where, whereArgs: whereArgs);
    return result;
  }

  Future<int> update({
    required String table,
    required Map<String, Object?> values,
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final result =
        await _db.update(table, values, where: where, whereArgs: whereArgs);
    return result;
  }
}
