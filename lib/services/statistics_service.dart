import 'package:scorecard/modules/stats/player_statistics.dart';
import 'package:scorecard/repositories/statistics_repository.dart';

class StatisticsService {
  final StatisticsRepository _statisticsRepository;

  StatisticsService(this._statisticsRepository);

  Future<List<PlayerBattingStatistics>> getAllBattingStats() async {
    final result = await _statisticsRepository.loadAllBattingStats();
    return result;
  }

  Future<List<PlayerBowlingStatistics>> getAllBowlingStats() async {
    final result = await _statisticsRepository.loadAllBowlingStats();
    return result;
  }
}
