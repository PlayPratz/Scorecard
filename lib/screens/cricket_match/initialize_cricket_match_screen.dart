import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/services/cricket_match_service.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/modules/team/models/team_model.dart';
import 'package:scorecard/screens/cricket_match/cricket_match_screen_switcher.dart';
import 'package:scorecard/screens/player/player_list_screen.dart';

class InitializeCricketMatchScreen extends StatelessWidget {
  final InitializeCricketMatchScreenController controller;

  const InitializeCricketMatchScreen(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: controller._stream,
        initialData: controller._deduceState(),
        builder: (context, snapshot) {
          final state = snapshot.data;
          if (state == null || state is _InitializingCricketMatchState) {
            return loadingScreen;
          } else if (state is _InitializedCricketMatchState) {
            return Text("Done");
          }
          state as _InitializeCricketMatchScreenState;
          return Scaffold(
            appBar: AppBar(
              title: const Text("Time for the toss!"),
            ),
            body: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              // reverse: true,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: _TossChooserSection(
                    team1: state.team1,
                    team2: state.team2,
                    onChooseTeam: (team) => controller.selectedWinner = team,
                    onTossChoice: (choice) =>
                        controller.selectedTossChoice = choice,
                    selectedWinner: state.selectedWinner,
                    selectedTossChoice: state.selectedTossChoice,
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(height: 32),
                Text(state.team1.name.toUpperCase()),
                const Text("Tap a player to make them the captain"),
                const SizedBox(height: 16),
                _LineupSelectSection(state.lineup1,
                    captain: state.selectedCaptain1,
                    onSelectPlayers: controller.addToLineup1,
                    onDeletePlayer: controller.removeFromLineup1,
                    onSelectCaptain: (p) => controller.selectedCaptain1 = p),
                const Divider(height: 32),
                Text(state.team2.name.toUpperCase()),
                const Text("Tap a player to make them the captain"),
                const SizedBox(height: 16),
                _LineupSelectSection(state.lineup2,
                    captain: state.selectedCaptain2,
                    onSelectPlayers: controller.addToLineup2,
                    onDeletePlayer: controller.removeFromLineup2,
                    onSelectCaptain: (p) => controller.selectedCaptain2 = p),
              ],
            ),
            bottomNavigationBar: BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: controller.canInitializeMatch
                        ? () => controller.initializeMatch(context)
                        : null,
                    label: const Text("Preview"),
                    icon: const Icon(Icons.preview),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget get loadingScreen => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: const BottomAppBar(),
      );
}

class InitializeCricketMatchScreenController {
  final ScheduledCricketMatch cricketMatch;

  InitializeCricketMatchScreenController(this.cricketMatch);

  final _streamController = StreamController<_ScreenState>();
  Stream<_ScreenState> get _stream => _streamController.stream;

  Team? _selectedWinner;
  set selectedWinner(Team team) {
    _selectedWinner = team;
    _dispatchState();
  }

  TossChoice? _selectedTossChoice;
  set selectedTossChoice(TossChoice choice) {
    _selectedTossChoice = choice;
    _dispatchState();
  }

  Player? _selectedCaptain1;
  set selectedCaptain1(Player captain) {
    _selectedCaptain1 = captain;
    _dispatchState();
  }

  Player? _selectedCaptain2;
  set selectedCaptain2(Player captain) {
    _selectedCaptain2 = captain;
    _dispatchState();
  }

  final Set<Player> _selectedPlayers1 = {};
  final Set<Player> _selectedPlayers2 = {};

  void addToLineup1(List<Player> players) {
    _selectedPlayers1.addAll(players);
    _dispatchState();
  }

  void removeFromLineup1(Player player) {
    _selectedPlayers1.remove(player);
    if (_selectedCaptain1 == player) {
      _selectedCaptain1 = null;
    }
    _dispatchState();
  }

  void addToLineup2(List<Player> players) {
    _selectedPlayers2.addAll(players);
    _dispatchState();
  }

  void removeFromLineup2(Player player) {
    _selectedPlayers2.remove(player);
    if (_selectedCaptain2 == player) {
      _selectedCaptain2 = null;
    }
    _dispatchState();
  }

  void _dispatchState() => _streamController.add(_deduceState());

  _InitializeCricketMatchScreenState _deduceState() =>
      _InitializeCricketMatchScreenState(
        team1: cricketMatch.team1,
        team2: cricketMatch.team2,
        selectedWinner: _selectedWinner,
        selectedTossChoice: _selectedTossChoice,
        selectedCaptain1: _selectedCaptain1,
        lineup1: _selectedPlayers1.toList(),
        selectedCaptain2: _selectedCaptain2,
        lineup2: _selectedPlayers2.toList(),
      );

  bool get canInitializeMatch =>
      _selectedTossChoice != null &&
      _selectedWinner != null &&
      _selectedCaptain1 != null &&
      _selectedCaptain2 != null &&
      _selectedPlayers1.isNotEmpty &&
      _selectedPlayers2.isNotEmpty;

  Future<void> initializeMatch(BuildContext context) async {
    if (!canInitializeMatch) {
      return;
    }

    _streamController.add(_InitializingCricketMatchState());

    try {
      final initializedMatch = await _service.initializeCricketMatch(
        cricketMatch,
        toss: Toss(winner: _selectedWinner!, choice: _selectedTossChoice!),
        lineup1: Lineup(
            players: _selectedPlayers1.toList(), captain: _selectedCaptain1!),
        lineup2: Lineup(
            players: _selectedPlayers2.toList(), captain: _selectedCaptain2!),
      );

      _streamController.add(_InitializedCricketMatchState(initializedMatch));
    } catch (e) {
      _streamController.add(_deduceState());
    }
  }

  void goNextScreen(
      BuildContext context, InitializedCricketMatch initializedMatch) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                CricketMatchScreenSwitcher(initializedMatch)));
  }

  CricketMatchService get _service => CricketMatchService();
}

sealed class _ScreenState {}

// This is probably the worst naming scheme one could come up with
class _InitializingCricketMatchState extends _ScreenState {}

class _InitializedCricketMatchState extends _ScreenState {
  final InitializedCricketMatch initializedMatch;
  _InitializedCricketMatchState(this.initializedMatch);
}

class _InitializeCricketMatchScreenState extends _ScreenState {
  final Team team1;
  final Team team2;

  final Player? selectedCaptain1;
  final List<Player> lineup1;

  final Player? selectedCaptain2;
  final List<Player> lineup2;

  final Team? selectedWinner;
  final TossChoice? selectedTossChoice;

  _InitializeCricketMatchScreenState({
    required this.team1,
    required this.team2,
    required this.selectedCaptain1,
    required this.lineup1,
    required this.selectedCaptain2,
    required this.lineup2,
    required this.selectedWinner,
    required this.selectedTossChoice,
  });
}

class _TossChooserSection extends StatelessWidget {
  final Team team1;
  final Team team2;
  final Team? selectedWinner;
  final TossChoice? selectedTossChoice;

  final void Function(Team team) onChooseTeam;
  final void Function(TossChoice choice) onTossChoice;

  const _TossChooserSection({
    super.key,
    required this.team1,
    required this.team2,
    required this.onChooseTeam,
    required this.onTossChoice,
    required this.selectedWinner,
    required this.selectedTossChoice,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Toss was won by", style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final team in [team1, team2])
          ChoiceChip(
            label: Text(team.name),
            selected: team == selectedWinner,
            onSelected: (x) {
              if (x) onChooseTeam(team);
            },
          ),
        const SizedBox(height: 16),
        Text("and they chose to",
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (final choice in TossChoice.values)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ChoiceChip(
                  label: Text(stringify(choice)),
                  selected: selectedTossChoice == choice,
                  onSelected: (x) {
                    if (x) onTossChoice(choice);
                  },
                ),
              )
          ],
        )
      ],
    );
  }

  String stringify(TossChoice choice) => switch (choice) {
        TossChoice.bat => "Bat",
        TossChoice.field => "Field",
      };
}

class _LineupSelectSection extends StatelessWidget {
  final List<Player> players;
  final Player? captain;

  final void Function(List<Player> player) onSelectPlayers;
  final void Function(Player player) onDeletePlayer;
  final void Function(Player player) onSelectCaptain;

  const _LineupSelectSection(this.players,
      {super.key,
      required this.captain,
      required this.onSelectPlayers,
      required this.onDeletePlayer,
      required this.onSelectCaptain});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final player in players)
          ListTile(
            title: Row(
              children: [
                Text(player.name),
                if (player == captain)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.copyright),
                  )
              ],
            ),
            onTap: () => onSelectCaptain(player),
            trailing: IconButton(
                onPressed: () => onDeletePlayer(player),
                icon: const Icon(Icons.delete)),
          ),
        ListTile(
          leading: const Icon(Icons.add),
          title: const Text("Add a Player"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _pickPlayer(context),
        ),
      ],
    );
  }

  Future<void> _pickPlayer(BuildContext context) async {
    final player = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PickPlayerScreen(
                  onSelectPlayer: (p) => Navigator.pop(context, p),
                )));

    if (player is Player) {
      onSelectPlayers([player]);
    }
  }
}
