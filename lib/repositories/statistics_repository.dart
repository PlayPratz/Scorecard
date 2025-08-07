import 'package:scorecard/modules/quick_match/wicket_model.dart';
import 'package:scorecard/modules/stats/player_statistics.dart';
import 'package:scorecard/repositories/sql/db/player_statistics_queries.dart';

class StatisticsRepository {
  final PlayerStatisticsQueries _queries;

  StatisticsRepository(this._queries);

  Future<List<RunsByPlayer>> getRunsScoredByAllPlayers() async {
    final result = await _queries.runsByAllPlayers();
    final runsByPlayers =
        result.map((r) => RunsByPlayer(r.id, name: r.name, runs: r.value));
    return runsByPlayers.toList();
  }

  Future<List<WicketsByPlayer>> geWicketsTakenByAllPlayers() async {
    final result = await _queries.wicketsByAllPlayers();
    final wicketsByPlayer = result
        .map((r) => WicketsByPlayer(r.id, name: r.name, numWickets: r.value));

    return wicketsByPlayer.toList();
  }
}
