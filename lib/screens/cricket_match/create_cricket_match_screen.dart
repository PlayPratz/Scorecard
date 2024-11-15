import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/controllers/create_cricket_match_controller.dart';
import 'package:scorecard/modules/team/models/team_model.dart';

class CreateCricketMatchScreen extends StatelessWidget {
  final teamController = TeamSelectController();
  final gameRulesController = LimitedOverGameRulesController();

  CreateCricketMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            Text("Let's create a new match!",
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 32),
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
          FilledButton.icon(
            onPressed: () {},
            label: const Text("Start"),
            icon: const Icon(Icons.play_arrow),
          ),
        ],
      )),
    );
  }

  void _initializeMatch(BuildContext context) {
    // final match = controller.scheduleMatch();
    // Navigator.pushReplacement(context,
    //     MaterialPageRoute(builder: (context) => CricketMatchScreen(match)));
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
        _TeamSelectTile(
          controller.team1,
          onSelect: () {},
        ),
        _TeamSelectTile(
          controller.team2,
          onSelect: () {},
        ),
      ],
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
        onTap: () {},
      );
    }
    return ListTile(
      leading: const Icon(Icons.people),
      title: Text(team!.name),
      trailing: const Icon(Icons.chevron_right),
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
        final rules = controller.rules;
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
