import 'package:sqflite/sqflite.dart';

class SQLDBHandler {
  late final Database db;

  void initialize() async {
    db = await openDatabase("");
  }

  Future<void> insert({
    required String table,
    required Map<String, dynamic> values,
  }) async {
    await db.insert(table, values);
  }

  Future<Iterable<dynamic>> query(
      {required String table,
      List<String> columns = const [],
      required String where}) async {
    final result = await db.query(table, columns: columns, where: where);
    return result;
  }

  Future<void> update({
    required String table,
    required Map<String, Object?> values,
    required String where,
  }) async {
    await db.update(table, values);
  }
}
