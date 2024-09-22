import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/controllers/create_cricket_match_controller.dart';
import 'package:scorecard/screens/cricket_match/cricket_match_screen.dart';

class CreateCricketMatchScreen extends StatelessWidget {
  final controller = CreateCricketMatchController();

  CreateCricketMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Text("Let's create a new match!",
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 32),
          const Text("Overs"),
          ValueListenableBuilder(
            valueListenable: controller.oversPerInnings,
            builder: (context, value, child) => _NumberChooser(
              value: value,
              onChange: (value) => controller.oversPerInnings.value = value,
              min: 1,
            ),
          ),
          const Text("Overs Per Bowler"),
          ValueListenableBuilder(
            valueListenable: controller.oversPerBowler,
            builder: (context, value, child) => _NumberChooser(
              value: value,
              onChange: (value) => controller.oversPerBowler.value = value,
              min: 1,
              max: controller.oversPerInnings.value,
            ),
          ),
          const Text("No Ball Penalty"),
          ValueListenableBuilder(
            valueListenable: controller.noBallPenalty,
            builder: (context, value, child) => _NumberChooser(
              value: value,
              onChange: (value) => controller.noBallPenalty.value = value,
            ),
          ),
          const Text("Wide Ball Penalty"),
          ValueListenableBuilder(
            valueListenable: controller.wideBallPenalty,
            builder: (context, value, child) => _NumberChooser(
              value: value,
              onChange: (value) => controller.wideBallPenalty.value = value,
            ),
          ),
          const Text("Balls Per Over Penalty"),
          ValueListenableBuilder(
            valueListenable: controller.ballsPerOver,
            builder: (context, value, child) => _NumberChooser(
              value: value,
              onChange: (value) => controller.ballsPerOver.value = value,
              min: 1,
            ),
          ),
        ],
      ),
    );
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
      children: [
        IconButton(
          onPressed: () => _changeBy(-10),
          icon: const Text("-10"),
          color: Theme.of(context).primaryColorDark,
        ),
        IconButton(
            onPressed: () => _changeBy(-5),
            icon: const Text("-5"),
            color: Theme.of(context).primaryColor),
        IconButton(
            onPressed: () => _changeBy(-1),
            icon: const Text("-1"),
            color: Theme.of(context).primaryColorLight),
        Text(value.toString()),
        IconButton(
            onPressed: () => _changeBy(1),
            icon: const Text("+1"),
            color: Theme.of(context).primaryColorLight),
        IconButton(
            onPressed: () => _changeBy(5),
            icon: const Text("+5"),
            color: Theme.of(context).primaryColor),
        IconButton(
            onPressed: () => _changeBy(10),
            icon: const Text("+10"),
            color: Theme.of(context).primaryColorDark),
      ],
    );
  }

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
