import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLDBHandler {
  late final Database _db;

  Future<void> initialize() async {
    final dbpath = join(await getDatabasesPath(), "cricket.db");

    final cricketDb = File(dbpath);
    if (!await cricketDb.exists()) {
      final source = await rootBundle.load("assets/sql/cricket.db");
      await cricketDb.writeAsBytes(source.buffer.asUint8List());
    }

    _db = await openDatabase(
      dbpath,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {},
      onUpgrade: (db, oldVersion, newVersion) {},
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

  Future<List<Map<String, Object?>>> query({
    required String table,
    List<String> columns = const [],
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final result = await _db.query(
      table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    return result;
  }

  Future<List<Map<String, Object?>>> rawQuery(String sql,
      [List<Object?>? arguments]) async {
    final result = await _db.rawQuery(sql, arguments);
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
    final rowsAffected = await _db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
    return rowsAffected;
  }
}
