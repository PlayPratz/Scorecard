import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:scorecard/repositories/sql/keys.dart';
import 'package:sqflite/sqflite.dart';

class SQLDBHandler {
  late final Database _db;

  SQLDBHandler._();
  static final instance = SQLDBHandler._();

  Future<void> initialize() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), "cricket.db"),
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        final sql =
            await rootBundle.loadString("assets/sql/cricket-create.sql");
        await db.execute(sql);
      },
      singleInstance: true,
      version: 1,
    );
    final res = await _db.query(Tables.players);
  }

  Future<int> insert({
    required String table,
    required Map<String, dynamic> values,
  }) async {
    final id = await _db.insert(table, values);
    return id;
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
    final rowsAffected =
        await _db.update(table, values, where: where, whereArgs: whereArgs);
    return rowsAffected;
  }
}
