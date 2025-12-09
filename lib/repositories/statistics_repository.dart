import 'package:scorecard/modules/stats/player_statistics.dart';
import 'package:scorecard/repositories/sql/db/structured_queries.dart';

class StatisticsRepository {
  final StructuredQueries _queries;

  StatisticsRepository(this._queries);

  Future<List<PlayerBattingStatistics>> loadAllBattingStats() async {
    final result = await _queries.allBattingStats();
    return result.toList();
  }

  Future<List<PlayerBowlingStatistics>> loadAllBowlingStats() async {
    final result = await _queries.wicketsByAllPlayers();
    return result.toList();
  }
}
