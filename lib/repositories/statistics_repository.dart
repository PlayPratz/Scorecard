import 'package:scorecard/modules/stats/player_statistics.dart';
import 'package:scorecard/repositories/sql/db/player_statistics_queries.dart';

class StatisticsRepository {
  final PlayerStatisticsQueries _queries;

  StatisticsRepository(this._queries);

  Future<List<PlayerBattingStatistics>> getRunsScoredByAllPlayers() async {
    final result = await _queries.allBattingStats();
    return result.toList();
  }

  Future<List<PlayerBowlingStatistics>> geWicketsTakenByAllPlayers() async {
    final result = await _queries.wicketsByAllPlayers();
    return result.toList();
  }
}
