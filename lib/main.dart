import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/handlers/image_picker_handler.dart';
import 'package:scorecard/handlers/photo_handler.dart';
import 'package:scorecard/handlers/share_handler.dart';
import 'package:scorecard/repositories/cricket_match_repository.dart';
import 'package:scorecard/repositories/player_repository.dart';
import 'package:scorecard/repositories/team_repository.dart';
import 'package:scorecard/screens/home.dart';
import 'package:scorecard/screens/widgets/common_builders.dart';
import 'package:scorecard/services/cricket_match_service.dart';
import 'package:scorecard/services/player_service.dart';
import 'package:scorecard/services/team_service.dart';
import 'package:scorecard/styles/text_styles.dart';

void main() {
  runApp(const ScorecardApp());
}

final _appStartup = AppStartup();
final _initializeApp = _appStartup.initializeApp();

class ScorecardApp extends StatelessWidget {
  const ScorecardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scorecard',
      theme: ThemeData(
        // brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        // dividerTheme: const DividerThemeData(
        //   color: ColorStyles.highlight,
        //   thickness: 2,
        //   space: 2,
        // ),
        textTheme: TextStyles.theme,
        useMaterial3: true,
      ),
      home: const HomeTabView(),
      builder: (context, route) => SimplifiedFutureBuilder(
        future: _initializeApp,
        builder: ((context, snapshot) {
          return MultiProvider(
            providers: [
              Provider(create: (context) => _appStartup.playerService),
              Provider(create: (context) => _appStartup.teamService),
              Provider(create: (context) => _appStartup.cricketMatchService),
            ],
            builder: (context, child) => route!,
          );
        }),
      ),
    );
  }
}

class AppStartup {
  // Repositories
  late final PlayerRepository playerRepository;
  late final TeamRepository teamRepository;
  late final CricketMatchRepository cricketMatchRepository;

  // Services
  late final PlayerService playerService;
  late final TeamService teamService;
  late final CricketMatchService cricketMatchService;

  bool _isInitialized = false;

  Future<bool> initializeApp() async {
    if (_isInitialized) {
      return false;
    }

    // Hive DB
    await Hive.initFlutter();

    // Repositories
    await _initializeRepositories();

    // Handlers
    await _initializeHandlers();

    // Services
    await _initializeServices();

    _isInitialized = true;
    return true;
  }

  Future<void> _initializeRepositories() async {
    playerRepository = PlayerRepository();
    await playerRepository.initialize();

    teamRepository = TeamRepository();
    await teamRepository.initialize();

    cricketMatchRepository = CricketMatchRepository(
      playerRepository: playerRepository,
      teamRepository: teamRepository,
    );
    await cricketMatchRepository.initialize();
  }

  Future<void> _initializeHandlers() async {
    await ShareHandler.initialize();
    await ImagePickerHandler.initialize();
    await PhotoHandler.initialize();
  }

  Future<void> _initializeServices() async {
    playerService = PlayerService(playerRepository: playerRepository);
    await playerService.initialize();

    teamService = TeamService(teamRepository: teamRepository);
    await teamService.initialize();

    cricketMatchService =
        CricketMatchService(cricketMatchRepository: cricketMatchRepository);
    await cricketMatchService.initialize();
  }
}
