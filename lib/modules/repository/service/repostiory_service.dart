import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/modules/team/models/team_model.dart';
import 'package:scorecard/repositories/generic_repository.dart';
import 'package:scorecard/repositories/ram_repository.dart';

abstract class IRepositoryService {
  void initialize();
  // void register(IRepository repository);
  // IRepository get(Type T);
  // void deregister(IRepository repository);
  IRepository<Player> getPlayerRepository();
  IRepository<Team> getTeamRepository();
  IRepository<CricketMatch> getCricketMatchRepository();
  void shutdown();
}

class RAMRepositoryService implements IRepositoryService {
  final _playerRepository = RAMPlayerRepository();
  final _teamRepository = RAMTeamRepository();
  final _cricketMatchRepository = RAMCricketMatchRepository();

  @override
  void initialize() {}

  @override
  IRepository<Player> getPlayerRepository() => _playerRepository;
  @override
  IRepository<Team> getTeamRepository() => _teamRepository;
  @override
  IRepository<CricketMatch> getCricketMatchRepository() =>
      _cricketMatchRepository;

  @override
  void shutdown() {}
}
