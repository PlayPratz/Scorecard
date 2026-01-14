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
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("DROP VIEW IF EXISTS batting_stats;");
          await db.execute(
              "CREATE VIEW batting_stats AS WITH batting_stats AS (SELECT bs.player_id AS id, p.name, COUNT(DISTINCT bs.match_id) AS matches, COUNT(bs.player_id) AS innings, SUM(bs.runs_scored) AS runs_scored, SUM(bs.balls_faced) AS balls_faced, COUNT(CASE WHEN bs.not_out = 0 THEN NULL ELSE 1 END) AS not_outs, COUNT(bs.wicket_type) AS outs, MAX(bs.runs_scored) AS high_score, SUM(fours_scored) AS fours_scored, SUM(sixes_scored) AS sixes_scored FROM batting_scores AS bs, players AS p WHERE p.id = bs.player_id AND bs.innings_type != 6 GROUP BY player_id) SELECT *, 100.0*runs_scored/balls_faced AS strike_rate, COALESCE(1.0*runs_scored/outs, 1.0*runs_scored) AS average FROM batting_stats ORDER BY runs_scored DESC, balls_faced ASC, outs ASC;");

          await db.execute("DROP VIEW IF EXISTS bowling_stats;");
          await db.execute(
              "CREATE VIEW bowling_stats AS WITH bowling_stats AS (SELECT bs.player_id AS id, p.name, COUNT(DISTINCT bs.match_id) AS matches, COUNT(bs.player_id) AS innings, SUM(bs.balls_bowled) AS balls_bowled, SUM(bs.runs_conceded) AS runs_conceded, SUM(bs.wickets_taken) AS wickets_taken, SUM(bs.extras_no_balls) AS extras_no_balls, SUM(bs.extras_wides) AS extras_wides FROM bowling_scores AS bs, players AS p WHERE p.id = bs.player_id AND bs.innings_type != 6 GROUP BY player_id) SELECT *, balls_bowled/6 AS overs_bowled, balls_bowled%6 AS overs_balls_bowled, 6.0*runs_conceded/balls_bowled AS economy, 1.0*runs_conceded/wickets_taken AS average, 1.0*balls_bowled/wickets_taken AS strike_rate FROM bowling_stats ORDER BY wickets_taken DESC, runs_conceded ASC, balls_bowled DESC;");
        }

        if (oldVersion < 3) {
          await db.execute("DROP VIEW IF EXISTS balls;");
          await db.execute(
              "CREATE VIEW balls AS SELECT id, match_id, innings_id, innings_type, innings_number, day_number, session_number, timestamp, type, over_index, ball_index, bowler_id, batter_id, non_striker_id, total_runs, bowler_runs, batter_runs, is_boundary, extras_no_balls, extras_wides, extras_byes, extras_leg_byes, extras_penalties, extras_total, wicket_type, wicket_batter_id, wicket_fielder_id, runs_at, wickets_at, is_counted_for_bowler, is_counted_for_batter FROM posts WHERE type=0;");
        }
      },
      singleInstance: true,
      version: 3,
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
