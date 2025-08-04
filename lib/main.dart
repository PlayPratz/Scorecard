import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/repositories/player_repository.dart';
import 'package:scorecard/repositories/quick_innings_repository.dart';
import 'package:scorecard/repositories/quick_match_repository.dart';
import 'package:scorecard/screens/home_screen.dart';
import 'package:scorecard/services/player_service.dart';
import 'package:scorecard/services/quick_match_service.dart';

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
/// components of the same level or any component above it, but CANNOT import
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

class ScorecardApp extends StatelessWidget {
  const ScorecardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = _ScorecardAppController();
    controller.startup();
    return MaterialApp(
      title: "Scorecard",
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: const HomeScreen(),
      builder: (context, child) => StreamBuilder(
          stream: controller._stateStreamController.stream,
          initialData: _AppStartupLoadingState(),
          builder: (context, snapshot) {
            final state = snapshot.data!;
            return switch (state) {
              _AppStartupLoadingState() => const Scaffold(
                  body: Center(child: CircularProgressIndicator())),
              // TODO: Handle this case.
              _StartupFailState() => const Scaffold(
                  body: Center(
                    child: Text("Error starting app! Try restarting."),
                  ),
                ),
              // TODO: Handle this case.
              _StartupSuccessfulState() => MultiProvider(providers: [
                  Provider(
                      create: (context) => QuickMatchService(
                          state.matchRepository, state.inningsRepository)),
                  Provider(
                      create: (context) =>
                          PlayerService(state.playerRepository)),
                ], child: child),
            };
            return const HomeScreen();
          }),
    );
  }
}

class _ScorecardAppController {
  final _stateStreamController = StreamController<_ScorecardAppState>();

  Future<void> startup() async {
    final playerRepository = PlayerRepository();
    final matchRepository = QuickMatchRepository();
    final inningsRepository = QuickInningsRepository();

    await Future.delayed(const Duration(seconds: 1));

    _stateStreamController.add(
      _StartupSuccessfulState(
          playerRepository: playerRepository,
          matchRepository: matchRepository,
          inningsRepository: inningsRepository),
    );
  }
}

sealed class _ScorecardAppState {}

class _AppStartupLoadingState extends _ScorecardAppState {}

class _StartupSuccessfulState extends _ScorecardAppState {
  final PlayerRepository playerRepository;
  final QuickMatchRepository matchRepository;
  final QuickInningsRepository inningsRepository;

  _StartupSuccessfulState({
    required this.playerRepository,
    required this.matchRepository,
    required this.inningsRepository,
  });
}

class _StartupFailState extends _ScorecardAppState {}
