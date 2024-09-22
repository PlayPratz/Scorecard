import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/controllers/create_cricket_match_controller.dart';
import 'package:scorecard/screens/cricket_match/cricket_match_screen.dart';

class CreateCricketMatchScreen extends StatelessWidget {
  final controller = CreateCricketMatchController();

  CreateCricketMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListView(
            children: [
              Text("Let's create a new match!",
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 32),
              Text("Teams", style: Theme.of(context).textTheme.titleSmall),
              Text(
                "Which great sides will be clashing?",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              ListTile(),
              const Divider(height: 64),
              Text("Match Rules",
                  style: Theme.of(context).textTheme.titleSmall),
              Text(
                "These can't be edited once the match is created. Make sure everything is right!",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              const Center(child: Text("Overs")),
              const SizedBox(height: 4),
              ValueListenableBuilder(
                valueListenable: controller.oversPerInnings,
                builder: (context, value, child) => _NumberChooser(
                  value: value,
                  onChange: (value) => controller.oversPerInnings.value = value,
                  min: 1,
                ),
              ),
              const SizedBox(height: 32),
              const Center(child: Text("Overs Per Bowler")),
              const SizedBox(height: 4),
              ValueListenableBuilder(
                valueListenable: controller.oversPerBowler,
                builder: (context, value, child) => _NumberChooser(
                  value: value,
                  onChange: (value) => controller.oversPerBowler.value = value,
                  min: 1,
                  max: controller.oversPerInnings.value,
                ),
              ),
              const SizedBox(height: 32),
              const Center(child: Text("No Ball Penalty")),
              const SizedBox(height: 4),
              ValueListenableBuilder(
                valueListenable: controller.noBallPenalty,
                builder: (context, value, child) => _NumberChooser(
                  value: value,
                  onChange: (value) => controller.noBallPenalty.value = value,
                ),
              ),
              const SizedBox(height: 32),
              const Center(child: Text("Wide Ball Penalty")),
              const SizedBox(height: 4),
              ValueListenableBuilder(
                valueListenable: controller.wideBallPenalty,
                builder: (context, value, child) => _NumberChooser(
                  value: value,
                  onChange: (value) => controller.wideBallPenalty.value = value,
                ),
              ),
              const SizedBox(height: 32),
              const Center(child: Text("Balls Per Over")),
              const SizedBox(height: 4),
              ValueListenableBuilder(
                valueListenable: controller.ballsPerOver,
                builder: (context, value, child) => _NumberChooser(
                  value: value,
                  onChange: (value) => controller.ballsPerOver.value = value,
                  min: 1,
                ),
              ),
              const SizedBox(height: 64),
            ],
          ),
        ),
        bottomNavigationBar: const BottomAppBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FilledButton.icon(
          onPressed: null,
          label: const Text("Start"),
          icon: const Icon(Icons.play_arrow),
        ));
  }

  void _initializeMatch(BuildContext context) {
    final match = controller.scheduleMatch();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => CricketMatchScreen(match)));
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
