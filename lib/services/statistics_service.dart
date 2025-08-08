import 'package:scorecard/modules/stats/player_statistics.dart';
import 'package:scorecard/repositories/statistics_repository.dart';

class StatisticsService {
  final StatisticsRepository _statisticsRepository;

  StatisticsService(this._statisticsRepository);

  Future<List<PlayerBattingStatistics>> getRunsScoredByAllPlayers() async {
    final result = await _statisticsRepository.getRunsScoredByAllPlayers();
    return result;
  }

  Future<List<PlayerBowlingStatistics>> getWicketsTakenByAllPlayers() async {
    final result = await _statisticsRepository.geWicketsTakenByAllPlayers();
    return result;
  }
}
