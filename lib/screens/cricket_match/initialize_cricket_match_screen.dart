import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/team/models/team_model.dart';

class InitializeCricketMatchScreen extends StatelessWidget {
  final InitializeCricketMatchScreenController controller;

  const InitializeCricketMatchScreen(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<InitializeCricketMatchScreenState>(
          stream: controller.stream,
          initialData: controller._deduceState(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final state = snapshot.data!;
            return ListView(
              children: [
                _TossChooserSection(
                  team1: state.team1,
                  team2: state.team2,
                  onChooseTeam: (team) => controller.selectedWinner = team,
                  onTossChoice: (choice) =>
                      controller.selectedTossChoice = choice,
                  selectedWinner: state.selectedWinner,
                  selectedTossChoice: state.selectedTossChoice,
                )
              ],
            );
          }),
    );
  }
}

class InitializeCricketMatchScreenController {
  final ScheduledCricketMatch match;

  InitializeCricketMatchScreenController(this.match);

  final _streamController =
      StreamController<InitializeCricketMatchScreenState>();
  Stream<InitializeCricketMatchScreenState> get stream =>
      _streamController.stream;

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

  Lineup? _selectedLineup1;
  set lineup1(Lineup lineup) {
    _selectedLineup1 = lineup;
    _dispatchState();
  }

  Lineup? _selectedLineup2;

  // final selectedWinner = ValueNotifier<Team?>(null);
  // final selectedTossChoice = ValueNotifier<TossChoice?>(null);
  // final selectedLineup1 = ValueNotifier<Lineup?>(null);
  // final selectedLineup2 = ValueNotifier<Lineup?>(null);
  //
  // InitializeCricketMatchScreenController() {
  //   selectedWinner.addListener(_dispatchState);
  //   selectedTossChoice.addListener(_dispatchState);
  //   selectedLineup1.addListener(_dispatchState);
  //   selectedLineup2.addListener(_dispatchState);
  // }

  // InitializeCricketMatchScreenState _deduceState() =>
  //     InitializeCricketMatchScreenState(
  //       selectedWinner: selectedWinner.value,
  //       selectedTossChoice: selectedTossChoice.value,
  //       lineup1: selectedLineup1.value,
  //       lineup2: selectedLineup2.value,
  //     );

  InitializeCricketMatchScreenState _deduceState() =>
      InitializeCricketMatchScreenState(
        selectedWinner: _selectedWinner,
        selectedTossChoice: _selectedTossChoice,
        lineup1: _selectedLineup1,
        lineup2: _selectedLineup2,
        team1: match.team1,
        team2: match.team2,
      );

  void _dispatchState() => _streamController.add(_deduceState());
}

class InitializeCricketMatchScreenState {
  final Team team1;
  final Team team2;

  final Team? selectedWinner;
  final TossChoice? selectedTossChoice;

  final Lineup? lineup1;
  final Lineup? lineup2;

  InitializeCricketMatchScreenState({
    required this.team1,
    required this.team2,
    required this.selectedWinner,
    required this.selectedTossChoice,
    required this.lineup1,
    required this.lineup2,
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
      children: [
        for (final team in [team1, team2])
          ChoiceChip(
            label: Text(team.name),
            selected: team == selectedWinner,
            onSelected: (x) {
              if (x) onChooseTeam(team);
            },
          ),
        const SizedBox(height: 16),
        for (final choice in TossChoice.values)
          ChoiceChip(
            label: Text(stringify(choice)),
            selected: selectedTossChoice == choice,
            onSelected: (x) {
              if (x) onTossChoice(choice);
            },
          )
      ],
    );
  }

  String stringify(TossChoice choice) => switch (choice) {
        TossChoice.bat => "Bat",
        TossChoice.field => "Field",
      };
}
