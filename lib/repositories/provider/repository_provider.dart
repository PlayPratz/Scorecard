import 'package:scorecard/modules/venue/models/venue_model.dart';
import 'package:scorecard/repositories/cricket_match_repository.dart';
import 'package:scorecard/repositories/player_repository.dart';
import 'package:scorecard/repositories/sql/db/game_rules_table.dart';
import 'package:scorecard/repositories/sql/db/innings_table.dart';
import 'package:scorecard/repositories/sql/db/lineups_view.dart';
import 'package:scorecard/repositories/sql/db/players_in_match_table.dart';
import 'package:scorecard/repositories/sql/db/matches_expanded_view.dart';
import 'package:scorecard/repositories/sql/db/matches_table.dart';
import 'package:scorecard/repositories/sql/db/players_table.dart';
import 'package:scorecard/repositories/sql/db/posts_table.dart';
import 'package:scorecard/repositories/sql/db/teams_table.dart';
import 'package:scorecard/repositories/sql/db/venues_table.dart';
import 'package:scorecard/repositories/sql/handlers/sql_db_handler.dart';
import 'package:scorecard/repositories/team_repository.dart';
import 'package:scorecard/repositories/venue_repository.dart';

abstract class IRepositoryProvider {
  Future<void> initialize();

  TeamRepository getTeamRepository();
  PlayerRepository getPlayerRepository();
  VenueRepository getVenueRepository();
  CricketMatchRepository getCricketMatchRepository();
}

class RepositoryProvider implements IRepositoryProvider {
  late final PlayerRepository _playerRepository;
  late final TeamRepository _teamRepository;
  late final VenueRepository _venueRepository;
  late final CricketMatchRepository _cricketMatchRepository;

  @override
  Future<void> initialize() async {
    // Initialize the DB
    await SQLDBHandler.instance.initialize();

    // Instantiate all tables and views
    final playersTable = PlayersTable();
    final teamsTable = TeamsTable();
    final venuesTable = VenuesTable();
    final gameRulesTable = GameRulesTable();
    final matchesTable = MatchesTable();
    final matchesExpandedView = MatchesExpandedView();
    final playersInMatchTable = PlayersInMatchTable();
    final lineupsExpandedView = LineupsExpandedView();
    final inningsTable = InningsTable();
    final postsTable = PostsTable();

    // Instantiate all repositories
    _playerRepository = PlayerRepository(playersTable: playersTable);
    _teamRepository = TeamRepository(teamsTable: teamsTable);
    _venueRepository = VenueRepository(venuesTable: venuesTable);
    _cricketMatchRepository = CricketMatchRepository(
      cricketMatchesTable: matchesTable,
      cricketMatchesExpandedView: matchesExpandedView,
      gameRulesTable: gameRulesTable,
      playersInMatchTable: playersInMatchTable,
      lineupsExpandedView: lineupsExpandedView,
      inningsTable: inningsTable,
      postsTable: postsTable,
    );
  }

  RepositoryProvider._();
  static final instance = RepositoryProvider._();
  factory RepositoryProvider() => instance;

  @override
  CricketMatchRepository getCricketMatchRepository() => _cricketMatchRepository;

  @override
  getPlayerRepository() => _playerRepository;

  @override
  getTeamRepository() => _teamRepository;

  @override
  VenueRepository getVenueRepository() => _venueRepository;
}
