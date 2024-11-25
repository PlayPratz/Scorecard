import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/modules/cricket_match/services/cricket_match_service.dart';
import 'package:scorecard/modules/team/models/team_model.dart';
import 'package:scorecard/modules/venue/models/venue_model.dart';
import 'package:scorecard/screens/cricket_match/cricket_match_screen_switcher.dart';
import 'package:scorecard/screens/team/team_list_screen.dart';

class CreateCricketMatchScreen extends StatelessWidget {
  final CreateCricketMatchController controller;

  const CreateCricketMatchScreen(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final teamController = TeamSelectController();
    final gameRulesController = LimitedOverGameRulesController();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Let's create a new match!"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            // Text("Let's create a new match!",
            //     style: Theme.of(context).textTheme.headlineMedium),
            // const SizedBox(height: 32),
            _TeamSelectorSection(teamController),
            const Divider(height: 64),
            _LimitedOverGameRulesSection(gameRulesController),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListenableBuilder(
            listenable: teamController,
            builder: (context, child) => FilledButton.icon(
              onPressed:
                  teamController.team1 != null && teamController.team2 != null
                      ? () => controller.scheduleMatch(
                            context,
                            team1: teamController.team1!,
                            team2: teamController.team2!,
                            rules: gameRulesController._deduceState(),
                          )
                      : null,
              label: const Text("Toss"),
              icon: const Icon(Icons.radar),
            ),
          ),
        ],
      )),
    );
  }
}

class _TeamSelectorSection extends StatelessWidget {
  final TeamSelectController controller;
  const _TeamSelectorSection(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Teams", style: Theme.of(context).textTheme.titleSmall),
        Text(
          "Which great sides will be clashing?",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        ListenableBuilder(
          listenable: controller,
          builder: (context, child) => Column(
            children: [
              _TeamSelectTile(
                controller.team1,
                onSelect: () => onSelectTeam(context, 1),
              ),
              const SizedBox(height: 8),
              _TeamSelectTile(
                controller.team2,
                onSelect: () => onSelectTeam(context, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void onSelectTeam(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamListScreen(onSelect: (team) {
          if (index == 1) {
            controller.team1 = team;
          } else if (index == 2) {
            controller.team2 = team;
          }
          Navigator.pop(context);
        }),
      ),
    );
  }
}

class _TeamSelectTile extends StatelessWidget {
  final Team? team;
  final void Function() onSelect;

  const _TeamSelectTile(this.team, {super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (team == null) {
      return ListTile(
        leading: const Icon(Icons.people),
        title: const Text("Select Team"),
        trailing: const Icon(Icons.chevron_right),
        onTap: onSelect,
      );
    }
    return ListTile(
      leading: const Icon(Icons.people),
      title: Text(team!.name),
      trailing: const Icon(Icons.chevron_right),
      tileColor: Color(team!.color).withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onSelect,
    );
  }
}

class _LimitedOverGameRulesSection extends StatelessWidget {
  final LimitedOverGameRulesController controller;

  const _LimitedOverGameRulesSection(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final rules = controller._deduceState();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Game Rules", style: Theme.of(context).textTheme.titleSmall),
            Text(
              "These can't be edited once the match is created. Make sure everything is right!",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            const Center(child: Text("Overs")),
            const SizedBox(height: 4),
            _NumberChooser(
                value: rules.oversPerInnings,
                min: 1,
                onChange: (x) => controller.overPerInnings = x),
            const SizedBox(height: 32),
            const Center(child: Text("Overs Per Bowler")),
            const SizedBox(height: 4),
            _NumberChooser(
                value: rules.oversPerBowler,
                min: 1,
                max: rules.oversPerInnings,
                onChange: (x) => controller.oversPerBowler = x),
            const SizedBox(height: 32),
            const Center(child: Text("No Ball Penalty")),
            const SizedBox(height: 4),
            _NumberChooser(
                value: rules.noBallPenalty,
                min: 1,
                onChange: (x) => controller.noBallPenalty = x),
            const SizedBox(height: 32),
            const Center(child: Text("Wide Penalty")),
            const SizedBox(height: 4),
            _NumberChooser(
                value: rules.widePenalty,
                min: 1,
                onChange: (x) => controller.widePenalty = x),
            const SizedBox(height: 32),
            const Center(child: Text("Balls Per Over")),
            const SizedBox(height: 4),
            _NumberChooser(
                value: rules.ballsPerOver,
                min: 1,
                onChange: (x) => controller.ballsPerOver = x),
            const SizedBox(height: 64),
          ],
        );
      },
    );
  }
}

class _NumberChooser extends StatelessWidget {
  final int value;

  final int min;
  final int max;

  final void Function(int value) onChange;

  const _NumberChooser({
    super.key,
    required this.value,
    required this.onChange,
    this.min = 0,
    this.max = 256,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _changeButton(context, -10, "-10"),
        _changeButton(context, -5, "-5"),
        _changeButton(context, -1, "-1"),
        Expanded(
          child: Center(
            child: Text(
              value.toString(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
        _changeButton(context, 1, "+1"),
        _changeButton(context, 5, "+5"),
        _changeButton(context, 10, "+10"),
      ],
    );
  }

  Widget _changeButton(BuildContext context, int diff, String label) =>
      IconButton.filledTonal(
        onPressed: () => _changeBy(diff),
        icon: Text(label),
      );

  void _changeBy(int diff) {
    final newValue = value + diff;
    if (newValue < min) {
      onChange(min);
    } else if (newValue > max) {
      onChange(max);
    } else {
      onChange(newValue);
    }
  }
}

class CreateCricketMatchController {
  void scheduleMatch(BuildContext context,
      {required Team team1, required Team team2, required GameRules rules}) {
    final match = _service.createCricketMatch(
      team1: team1,
      team2: team2,
      venue: Venue(name: "default"),
      rules: rules,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => CricketMatchScreenSwitcher(match)),
    );
  }

  CricketMatchService get _service => CricketMatchService();
}

class TeamSelectController with ChangeNotifier {
  Team? _team1;
  Team? _team2;

  void _dispatchState() {
    notifyListeners();
  }

  Team? get team1 => _team1;
  set team1(Team? x) {
    _team1 = x;
    if (_team2 == _team1) {
      _team2 = null;
    }
    _dispatchState();
  }

  Team? get team2 => _team2;
  set team2(Team? x) {
    _team2 = x;
    if (_team1 == _team2) {
      _team1 = null;
    }
    _dispatchState();
  }
}

class TeamSelectState {
  final Team? team;

  TeamSelectState(this.team);
}

class LimitedOverGameRulesController with ChangeNotifier {
  int _ballsPerOver = 6;
  int _noBallPenalty = 1;
  int _widePenalty = 1;
  int _oversPerInnings = 10;
  int _oversPerBowler = 10;
  bool _allowLastMan = false;
  bool _allowSingleBatter = false;

  LimitedOversRules _deduceState() => LimitedOversRules(
        ballsPerOver: _ballsPerOver,
        widePenalty: _widePenalty,
        noBallPenalty: _noBallPenalty,
        oversPerInnings: _oversPerInnings,
        oversPerBowler: _oversPerBowler,
        onlySingleBatter: _allowSingleBatter,
        allowLastMan: _allowLastMan,
      );

  void _dispatchState() {
    notifyListeners();
  }

  set ballsPerOver(int x) {
    _ballsPerOver = x;
    _dispatchState();
  }

  set noBallPenalty(int x) {
    _noBallPenalty = x;
    _dispatchState();
  }

  set widePenalty(int x) {
    _widePenalty = x;
    _dispatchState();
  }

  set overPerInnings(int x) {
    _oversPerInnings = x;
    if (_oversPerBowler > x) {
      _oversPerBowler = x;
    }
    _dispatchState();
  }

  set oversPerBowler(int x) {
    _oversPerBowler = x;
    _dispatchState();
  }

  set allowLastMan(bool x) {
    _allowLastMan = x;
    _dispatchState();
  }

  set allowSingleBatter(bool x) {
    _allowSingleBatter = x;
    if (_allowSingleBatter) {
      _allowLastMan = true;
    }
    _dispatchState();
  }
}
