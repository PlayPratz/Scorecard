import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/modules/team/models/team_model.dart';
import 'package:scorecard/repositories/generic_repository.dart';
import 'package:scorecard/repositories/player_repository.dart';
import 'package:scorecard/repositories/ram_repository.dart';
import 'package:scorecard/repositories/sql/handlers/sql_db_handler.dart';

abstract class IRepositoryProvider {
  IRepositoryProvider._();

  void initialize();
  // void register(IRepository repository);
  // IRepository get(Type T);
  // void deregister(IRepository repository);
  IRepository<Player> getPlayerRepository();
  IRepository<Team> getTeamRepository();
  IRepository<CricketMatch> getCricketMatchRepository();
  void shutdown();
}

class RepositoryProvider implements IRepositoryProvider {
  RepositoryProvider._();
  static final _instance = RepositoryProvider._();
  factory RepositoryProvider() => _instance;

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
    await _teamRepository.initialize();

    // Cricket Match Repository
    _cricketMatchRepository = RAMCricketMatchRepository();
    await _cricketMatchRepository.initialize();
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
