import 'package:flutter/services.dart';
import 'package:path/path.dart';
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
        final completeSql =
            await rootBundle.loadString("assets/sql/cricket-create.sql");
        final sqlList = completeSql.split(";");
        for (final query in sqlList) {
          final sql = query.trim();
          if (sql.isNotEmpty) await db.execute('$sql;');
        }

        await db.rawInsert('''
        INSERT INTO venues (id, name) VALUES ('default', 'default');
        ''');

        await db.rawInsert('''
INSERT INTO game_rules (type, balls_per_over, no_ball_penalty, wide_penalty, only_single_batter, last_wicket_batter, overs_per_innings, overs_per_bowler) VALUES
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1),
    (-1, -1, -1, -1, FALSE, FALSE, -1, -1);''');
      },
      singleInstance: true,
      version: 1,
    );
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

  Future<int> delete(
      {required String table,
      required String where,
      required List<Object?> whereArgs}) async {
    final rowsAffected =
        await _db.delete(table, where: where, whereArgs: whereArgs);
    return rowsAffected;
  }
}
