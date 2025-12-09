import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/provider/settings_provider.dart';
import 'package:scorecard/repositories/player_repository.dart';
import 'package:scorecard/repositories/quick_match_repository.dart';
import 'package:scorecard/repositories/sql/db/structured_queries.dart';
import 'package:scorecard/repositories/sql/db/players_table.dart';
import 'package:scorecard/repositories/sql/db/posts_table.dart';
import 'package:scorecard/repositories/sql/db/quick_innings_table.dart';
import 'package:scorecard/repositories/sql/db/quick_matches_table.dart';
import 'package:scorecard/handlers/sql_db_handler.dart';
import 'package:scorecard/repositories/statistics_repository.dart';
import 'package:scorecard/screens/home_screen.dart';
import 'package:scorecard/services/player_service.dart';
import 'package:scorecard/services/quick_match_service.dart';
import 'package:scorecard/services/settings_service.dart';
import 'package:scorecard/services/statistics_service.dart';

/// Welcome to [Scorecard]! You must be new here. The architecture and structure
/// of this application might be a little overwhelming. To help you out,
/// here's the naming scheme followed by classes in this application:
///
/// [Models] are analogous to POJOs and represent a container to hold data. They
/// strictly DO NOT comprise of any business logic. At best, they can contain
/// helper functions that perform basic operations like concatenation of data,
/// or adding multiple numbers in a list.
///
/// [Handlers] are classes that serve as wrappers for THIRD-PARTY LIBRARIES.
/// This is to ensure that in case we switch to another library in the future,
/// changes will be required in only one class.
///
/// [Repositories] are only for STORING and RETRIEVING DATA. They are
/// essentially an abstraction of a database.
///
/// [Caches] are used for storing temporary objects. Suppose instantiating a
/// certain class is a heavy asynchronous operation (like DB, IO or Network),
/// it makes sense to cache the object for as long as it is needed.
///
/// [Providers] are used to propagate changes across the app. The most common
/// example is the theme of an app. It's a change that must spread across the
/// app instantly. A provider exposes a listenable interface that can be
/// listened to for propagating data.
///
/// [Services] are STATELESS classes that perform major Business Logic
/// operations. They are initialized once and used throughout the app. Services
/// are responsible for all procedural work in the app, like fulfilling
/// the pre-requisites of any operation or validating inputs.
///
/// [Controllers] are STATE controllers that manipulate the state of UI. Any
/// operation that is triggered by user-input MUST go through a controller. The
/// operation could vary from just changing the striker to creating a new match.
/// After each such interaction, the Controller is responsible for invoking the
/// required business logic (via a Service) and also to push state changes back
/// to the UI.
///
/// [Screens] are complete screens that are visible to the user. Needless to
/// say, they can comprise of multiple widgets. As of now, every screen
/// utilizes the [Scaffold] widget as its root.
///
/// The above list is ordered such that every [Component] may import other
/// components of the same level or any component above it, but SHOULD NOT import
/// any component below it. To clarify, a Model can only see other Models, but
/// MUST NOT import a Handler, Repository, Service, Controller and of course,
/// Screen. Similarly, a Service can import Repositories, Handlers, Models and
/// even other Services, but not Controllers and Screens.
///
/// Of course this rule is to give a general idea, and usually a Screen won't
/// gain much by importing another screen. Services and Models are the only
/// components which may gain from importing other classes of the same kind.

void main() {
  runApp(const ScorecardApp());
}

class ScorecardApp extends StatefulWidget {
  const ScorecardApp({super.key});

  @override
  State<ScorecardApp> createState() => _ScorecardAppState();
}

class _ScorecardAppState extends State<ScorecardApp> {
  final controller = _ScorecardAppController();

  @override
  void initState() {
    super.initState();
    controller.startup();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: controller._stateStreamController.stream,
        initialData: _AppStartupLoadingState(),
        builder: (context, snapshot) {
          final state = snapshot.data!;

          final brightness = state is _StartupSuccessfulState &&
                  state.theme == ScorecardTheme.dark
              ? Brightness.dark
              : Brightness.light;
          final baseTheme = ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.teal,
            brightness: brightness,
          );
          final textTheme = GoogleFonts.ubuntuTextTheme(baseTheme.textTheme);
          final theme = baseTheme.copyWith(textTheme: textTheme);

          return MaterialApp(
            title: "Scorecard",
            theme: theme,
            home: const HomeScreen(),
            builder: (context, child) {
              return switch (state) {
                _AppStartupLoadingState() => const Scaffold(
                    body: Center(child: CircularProgressIndicator())),
                _StartupFailState() => const Scaffold(
                    body: Center(
                      child: Text("Error starting app! Try restarting."),
                    ),
                  ),
                _StartupSuccessfulState() => MultiProvider(
                    providers: [
                      Provider(create: (context) => state.settingsService),
                      Provider(create: (context) => state.playerService),
                      Provider(create: (context) => state.quickMatchService),
                      Provider(create: (context) => state.statisticsService),
                    ],
                    child: child,
                  ),
              };
            },
          );
        });
  }
}

class _ScorecardAppController {
  late final PlayerRepository playerRepository;
  late final QuickMatchRepository quickMatchRepository;
  late final StatisticsRepository statisticsRepository;

  late final PlayerService playerService;
  late final QuickMatchService quickMatchService;
  late final SettingsService settingsService;
  late final StatisticsService statisticsService;

  late final SettingsProvider settingsProvider;

  final _stateStreamController = StreamController<_ScorecardState>();
  void _dispatchState() => _stateStreamController.add(
        _StartupSuccessfulState(
          settingsService: settingsService,
          playerService: playerService,
          quickMatchService: quickMatchService,
          statisticsService: statisticsService,
          theme: settingsProvider.theme,
        ),
      );

  Future<void> startup() async {
    // To display dates and times in local format
    await initializeDateFormatting();
    // Repositories
    await _initializeRepositories();
    // Services
    await _initializeServices();

    _dispatchState();
  }

  Future<void> _initializeRepositories() async {
    // Initialize the DB
    await SQLDBHandler.instance.initialize();

    // Instantiate all tables and views
    final playersTable = PlayersTable();
    final quickMatchesTable = QuickMatchesTable();
    final quickInningsTable = QuickInningsTable();
    final postsTable = PostsTable();

    final playerStatisticsQueries = StructuredQueries();

    // Instantiate all repositories
    playerRepository = PlayerRepository(playersTable);
    quickMatchRepository = QuickMatchRepository(
      quickMatchesTable,
      quickInningsTable,
      postsTable,
    );
    statisticsRepository = StatisticsRepository(playerStatisticsQueries);
  }

  Future<void> _initializeServices() async {
    // Settings Service
    settingsProvider = SettingsProvider();
    settingsService = SettingsService(settingsProvider);
    await settingsService.initialize();
    settingsProvider.addListener(_dispatchState);

    // Players Service
    playerService = PlayerService(playerRepository);
    // await playerService.initialize();

    // Quick Match Service
    quickMatchService = QuickMatchService(quickMatchRepository, playerService);
    // await quickMatchService.initialize();

    //Statistics Service
    statisticsService = StatisticsService(statisticsRepository);
  }
}

sealed class _ScorecardState {}

class _AppStartupLoadingState extends _ScorecardState {}

class _StartupSuccessfulState extends _ScorecardState {
  final SettingsService settingsService;
  final PlayerService playerService;
  final QuickMatchService quickMatchService;
  final StatisticsService statisticsService;

  final ScorecardTheme theme;

  _StartupSuccessfulState({
    required this.settingsService,
    required this.playerService,
    required this.quickMatchService,
    required this.statisticsService,
    required this.theme,
  });
}

class _StartupFailState extends _ScorecardState {}
