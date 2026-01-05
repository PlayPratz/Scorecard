import 'package:scorecard/handlers/sql_db_handler.dart';
import 'package:scorecard/repositories/sql/keys.dart';

class LookupConfig {
  final Map<String, int> _wicketToInt = {};
  final Map<int, String> _intToWicket = {};

  final Map<String, int> _postToInt = {};
  final Map<int, String> _intToPost = {};

  final Map<String, int> _inningsStateToInt = {};
  final Map<int, String> _intToInningsState = {};

  Future<void> initialize(SQLDBHandler sql) async {
    final wickets = await sql.query(table: Tables.lookupWicket);
    for (final e in wickets) {
      _wicketToInt[e["code"] as String] = e["type"] as int;
      _intToWicket[e["type"] as int] = e["code"] as String;
    }

    final posts = await sql.query(table: Tables.lookupPost);
    for (final e in posts) {
      _postToInt[e["code"] as String] = e["type"] as int;
      _intToPost[e["type"] as int] = e["code"] as String;
    }

    final states = await sql.query(table: Tables.lookupInningsState);
    for (final e in states) {
      _inningsStateToInt[e["code"] as String] = e["type"] as int;
      _intToInningsState[e["type"] as int] = e["code"] as String;
    }
  }

  int getWicketType(String code) => _wicketToInt[code]!;
  String parseWicketType(int type) => _intToWicket[type]!;

  int getPostType(String code) => _postToInt[code]!;
  String parsePostType(int type) => _intToPost[type]!;

  int getInningsState(String code) => _inningsStateToInt[code]!;
  String parseInningsState(int type) => _intToInningsState[type]!;
}
