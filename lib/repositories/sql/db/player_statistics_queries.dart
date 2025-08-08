import 'package:scorecard/handlers/sql_db_handler.dart';
import 'package:scorecard/modules/stats/player_statistics.dart';

class PlayerStatisticsQueries {
  SQLDBHandler get sql => SQLDBHandler.instance;

  // Future<PlayerBattingStatistics?> battingStatisticsOf(Player player) async {
  //   final raw = await sql.rawQuery(
  //       "SELECT SUM(batter_runs) as runs, COUNT(batter_id) as balls_faced "
  //       "FROM balls WHERE batter_id = ?",
  //       [player.id]);
  //
  //   if (raw.isEmpty) return null;
  //
  //   final result = raw.single;
  //
  //   final entity = PlayerBattingStatistics(
  //     id: player.id,
  //     name: player.name,
  //     runs: result["runs"] as int,
  //     numBalls: result["balls_faced"] as int,
  //     numWickets: -1,
  //   );
  //
  //   return entity;
  // }

  Future<Iterable<PlayerBattingStatistics>> allBattingStats() async {
    final raw = await sql.rawQuery(
        "SELECT p.id, p.name, SUM(b.batter_runs) as runs, "
        "COUNT(CASE WHEN b.bowling_extra_type = 0 THEN NULL ELSE 1 END) as balls_faced, "
        "COUNT(CASE WHEN b.batter_id = b.wicket_batter_id THEN 1 ELSE NULL END) as wickets "
        "from players p, balls b WHERE p.id = b.batter_Id GROUP BY batter_id "
        "ORDER BY runs DESC, balls_faced ASC, wickets ASC");

    final entities = raw.map((e) => PlayerBattingStatistics(
          id: e["id"] as String,
          name: e["name"] as String,
          runs: e["runs"] as int,
          numBalls: e["balls_faced"] as int,
          numWickets: e["wickets"] as int,
        ));

    return entities;
  }

  Future<Iterable<PlayerBowlingStatistics>> wicketsByAllPlayers() async {
    final raw = await sql.rawQuery("SELECT p.id, p.name, "
        "COUNT(CASE WHEN b.bowling_extra_type IS NULL THEN 1 ELSE NULL END) as balls_bowled, "
        "COUNT(CASE WHEN b.bowling_extra_type = 1 THEN 1 ELSE NULL END) as no_balls_bowled, "
        "COUNT(CASE WHEN b.bowling_extra_type = 0 THEN 1 ELSE NULL END) as wides_bowled, "
        "COUNT(CASE WHEN b.wicket_type < 5 THEN 1 ELSE NULL END) as wickets_taken, "
        "SUM(bowler_runs) as runs_conceded "
        "FROM balls b, players p "
        "WHERE p.id = b.bowler_id GROUP BY b.bowler_id "
        "ORDER BY wickets_taken DESC, runs_conceded ASC, balls_bowled DESC");

    final entities = raw.map(
      (e) => PlayerBowlingStatistics(
        id: e["id"] as String,
        name: e["name"] as String,
        numBalls: e["balls_bowled"] as int,
        numNoBalls: e["no_balls_bowled"] as int,
        numWides: e["wides_bowled"] as int,
        numWickets: e["wickets_taken"] as int,
        runs: e["runs_conceded"] as int,
      ),
    );

    return entities;
  }

  Future<dynamic> getStatsForPlayer(String id) async {
    final result = sql.rawQuery(
        "SELECT p.id, SUM(b.runs), COUNT(b.wicket_type) FROM balls b, players p "
        "WHERE b.batter_id = p.player_id");
  }
}
