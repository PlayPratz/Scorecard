import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/modules/sql/handlers/sql_db_handler.dart';
import 'package:scorecard/modules/team/models/team_model.dart';
import 'package:scorecard/repositories/generic_repository.dart';
import 'package:scorecard/repositories/player_repository.dart';
import 'package:scorecard/repositories/ram_repository.dart';

abstract class IRepositoryService {
  IRepositoryService._();

  void initialize();
  // void register(IRepository repository);
  // IRepository get(Type T);
  // void deregister(IRepository repository);
  IRepository<Player> getPlayerRepository();
  IRepository<Team> getTeamRepository();
  IRepository<CricketMatch> getCricketMatchRepository();
  void shutdown();
}

// TODO This is probably not stateless, need to rework.
class RepositoryService implements IRepositoryService {
  RepositoryService._();
  static final _instance = RepositoryService._();
  factory RepositoryService() => _instance;

  late final IRepository<Player> _playerRepository;
  late final IRepository<Team> _teamRepository;
  late final IRepository<CricketMatch> _cricketMatchRepository;

  @override
  Future<void> initialize() async {
    await SQLDBHandler.instance.initialize();

    // Player Repository
    _playerRepository = SQLPlayerRepository();
    await _playerRepository.initialize();

    // Team Repository
    _teamRepository = RAMTeamRepository();

    // Cricket Match Repository
    _cricketMatchRepository = RAMCricketMatchRepository();
  }

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
